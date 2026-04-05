import 'dart:async';

import 'package:copper_hub/models/cart_item_model.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/widgets/custom_button.dart';

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({super.key});

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  final ApiService _api = ApiService();

  List<CartItemModel> _cartItems = [];
  bool _isLoading = true;
  int? _userId;

  double _totalWeight = 0;
  double _grandTotal = 0;

  Timer? _cartDebounce;
  Timer? _refreshDebounce;

  // ---------------- SAFE SNACKBAR ----------------
  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------- LOAD CART ----------------
  Future<void> _loadCart({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoading = true);
    _userId ??= await AuthStorage.getUserId();

    if (_userId == null) {
      if (showLoader) setState(() => _isLoading = false);
      return;
    }

    final response = await _api.getCart(userId: _userId!);

    if (!mounted) return;
    if (response['success']) {
      final List list = response['data'];

      setState(() {
        _cartItems = list.map((e) {
          return CartItemModel.fromJson(e);
        }).toList();

        _totalWeight = (response['totalWeight'] ?? 0).toDouble();
        _grandTotal = (response['grandTotal'] ?? 0).toDouble();
        _isLoading = false;
      });
    } else {
      if (showLoader) setState(() => _isLoading = false);
      _showSnack(response['message']);
    }
  }

  void _refreshCart() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 300), () {
      _loadCart(showLoader: false);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  ({int min, int? max}) getQtyLimitsFromSlab(String slabName) {
    final clean = slabName.replaceAll('KG', '').trim();

    // fractional slabs
    if (clean.startsWith('0.25') || clean.startsWith('0.5')) {
      return (min: 1, max: null);
    }

    // range slabs
    if (clean.contains('-')) {
      final parts = clean.split('-');
      return (min: int.parse(parts[0].trim()), max: int.parse(parts[1].trim()));
    }

    // plus slabs
    if (clean.contains('+')) {
      return (min: int.parse(clean.replaceAll('+', '').trim()), max: null);
    }

    return (min: 1, max: null);
  }

  // ---------------- DEBOUNCE API ----------------
  void _debounceCartUpdate({required int slabId, required int qty}) {
    _cartDebounce?.cancel();

    _cartDebounce = Timer(const Duration(milliseconds: 500), () async {
      final res = await _api.updateCartQty(
        userId: _userId!,
        slabId: slabId,
        qty: qty,
      );
      if (!mounted) return;
      if (!res['success']) {
        _showSnack(res['message']);
      } else {
        _refreshCart();
      }
    });
  }

  void _debounceRemove(int slabId, CartItemModel removedItem, int index) {
    _cartDebounce?.cancel();

    _cartDebounce = Timer(const Duration(milliseconds: 400), () async {
      final res = await _api.removeCartItem(userId: _userId!, slabId: slabId);
      if (!mounted) return;
      if (!res['success']) {
        setState(() {
          _cartItems.insert(index, removedItem);
        });

        _showSnack(res['message']);
      } else {
        _refreshCart();
      }
    });
  }

  // ---------------- ACTIONS ----------------
  Future<void> _increaseQty(CartItemModel item) async {
    final limits = getQtyLimitsFromSlab(item.slabName);
    final maxQty = limits.max == 0 ? null : limits.max;

    if (maxQty != null && item.quantity >= maxQty) {
      _showSnack("Maximum limit is $maxQty KG");
      return;
    }

    final oldQty = item.quantity;
    final newQty = oldQty + 1;
    final index = _cartItems.indexOf(item);

    // instant UI update
    setState(() {
      _cartItems[index] = item.copyWith(quantity: newQty);
      _updateSummary();
    });

    // silent API call
    _debounceCartUpdate(slabId: item.slabId, qty: newQty.toInt());
  }

  Future<void> _decreaseQty(CartItemModel item) async {
    final limits = getQtyLimitsFromSlab(item.slabName);
    final minQty = limits.min;

    if (item.quantity <= minQty) {
      _showSnack("Minimum limit is $minQty KG");
      return;
    }

    final oldQty = item.quantity;
    final newQty = oldQty - 1;
    final index = _cartItems.indexOf(item);

    setState(() {
      _cartItems[index] = item.copyWith(quantity: newQty);
      _updateSummary();
    });

    _debounceCartUpdate(slabId: item.slabId, qty: newQty.toInt());
  }

  void _updateSummary() {
    double totalWeight = 0;
    double grandTotal = 0;

    for (var item in _cartItems) {
      // Parse slab weight
      final clean = item.slabName.replaceAll('KG', '').trim();

      double slabWeight = 1; // default

      if (clean.startsWith('0.25')) {
        slabWeight = 0.25;
      } else if (clean.startsWith('0.5')) {
        slabWeight = 0.5;
      } else if (clean.contains('-')) {
        // range slab, take min value as unit weight
        slabWeight = double.tryParse(clean.split('-')[0].trim()) ?? 1;
      } else if (clean.contains('+')) {
        // plus slab, take value as weight
        slabWeight = double.tryParse(clean.replaceAll('+', '').trim()) ?? 1;
      } else {
        slabWeight = double.tryParse(clean) ?? 1;
      }

      totalWeight += item.quantity * slabWeight;
      grandTotal += item.totalAmount;
    }

    setState(() {
      _totalWeight = totalWeight;
      _grandTotal = grandTotal;
    });
  }

  Future<void> _removeItem(CartItemModel item) async {
    final index = _cartItems.indexOf(item);
    final removedItem = _cartItems[index];

    // Instant UI update: remove item locally
    setState(() {
      _cartItems.removeAt(index);
    });

    _debounceRemove(item.slabId, removedItem, index);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty', style: TextStyle(fontSize: 18)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // -------- Slab + Remove --------
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Slab: ${item.slabName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                _qtyButton(
                                  icon: Icons.close,
                                  color: AppColors.red,
                                  onTap: () => _removeItem(item),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // -------- Price + Amount --------
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹ ${item.pricePerKg.toStringAsFixed(2)} / KG',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '₹ ${item.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // -------- Quantity --------
                            Row(
                              children: [
                                Text(
                                  'Qty',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    _qtyButton(
                                      icon: Icons.remove,
                                      onTap: () => _decreaseQty(item),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        item.quantity.toInt().toString(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    _qtyButton(
                                      icon: Icons.add,
                                      onTap: () => _increaseQty(item),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // -------- Summary --------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Quantity',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '$_totalWeight KG',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Grand Total',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '₹ ${_grandTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green, // highlight
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        width: double.infinity,
                        text: 'Proceed to Checkout',
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.byCheckOut);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // -------- Qty Button --------
  Widget _qtyButton({
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? AppColors.textSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.white),
      ),
    );
  }
}
