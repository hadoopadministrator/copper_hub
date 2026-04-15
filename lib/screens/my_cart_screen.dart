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
      setState(() => _isLoading = false);
      return;
    }

    final response = await _api.getCart(userId: _userId!);

    if (!mounted) return;

    if (response['success']) {
      final List list = response['data'];

      setState(() {
        _cartItems = list.map((e) => CartItemModel.fromJson(e)).toList();

        _updateSummary();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      _showSnack(response['message']);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // ---------------- WEIGHT ----------------
  double getActualWeight(CartItemModel item) {
    if (item.minWeight < 1) {
      return item.quantity * item.minWeight;
    }
    return item.quantity.toDouble();
  }

  // ---------------- SUMMARY ----------------
  void _updateSummary() {
    double totalWeight = 0;
    double grandTotal = 0;

    for (var item in _cartItems) {
      final weight = getActualWeight(item);

      final amount = item.quantity * item.pricePerKg;

      totalWeight += weight;
      grandTotal += amount;
    }

    setState(() {
      _totalWeight = totalWeight;
      _grandTotal = grandTotal;
    });
  }

  // ---------------- DEBOUNCE UPDATE ----------------
  void _debounceUpdate(int slabId, int qty) {
    _cartDebounce?.cancel();

    _cartDebounce = Timer(const Duration(milliseconds: 500), () {
      _api.updateCartQty(userId: _userId!, slabId: slabId, qty: qty);
    });
  }

  // ---------------- LIMITS ----------------
  ({int min, int? max}) getQtyLimits(CartItemModel item) {
    if (item.minWeight < 1) {
      return (min: 1, max: null);
    }

    return (
      min: item.minWeight.toInt(),
      max: item.maxWeight == 0 ? null : item.maxWeight.toInt(),
    );
  }

  // ---------------- ACTIONS ----------------
  Future<void> _increaseQty(CartItemModel item) async {
    final limits = getQtyLimits(item);

    if (limits.max != null && item.quantity >= limits.max!) {
      _showSnack("Max limit reached");
      return;
    }

    final index = _cartItems.indexOf(item);
    final newQty = item.quantity + 1;

    final amount = newQty * item.pricePerKg;

    setState(() {
      _cartItems[index] = item.copyWith(quantity: newQty, totalAmount: amount);
    });

    _updateSummary();
    _debounceUpdate(item.slabId, newQty);
  }

  Future<void> _decreaseQty(CartItemModel item) async {
    final limits = getQtyLimits(item);

    if (item.quantity <= limits.min) {
      _showSnack("Minimum limit is ${limits.min}");
      return;
    }

    final index = _cartItems.indexOf(item);
    final newQty = item.quantity - 1;

    final amount = newQty * item.pricePerKg;

    setState(() {
      _cartItems[index] = item.copyWith(quantity: newQty, totalAmount: amount);
    });

    _updateSummary();
    _debounceUpdate(item.slabId, newQty);
  }

  Future<void> _removeItem(CartItemModel item) async {
    final index = _cartItems.indexOf(item);
    final removedItem = _cartItems[index];

    // instant UI
    setState(() {
      _cartItems.removeAt(index);
    });

    _updateSummary();

    final res = await _api.removeCartItem(
      userId: _userId!,
      slabId: item.slabId,
    );

    if (!res['success']) {
      // rollback
      setState(() {
        _cartItems.insert(index, removedItem);
      });

      _updateSummary();
      _showSnack(res['message']);
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // -------- Slab + Remove --------
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Slab: ${item.slabName}',
                                    style: textTheme.bodyLarge?.copyWith(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '₹ ${item.pricePerKg.toStringAsFixed(2)} / KG',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '₹ ${item.totalAmount.toStringAsFixed(2)}',
                                    style: textTheme.bodyLarge?.copyWith(
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
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
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
                                          style: textTheme.titleLarge?.copyWith(
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
                        ),
                      );
                    },
                  ),
                ),
                // -------- Summary --------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
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
                              Text(
                                'Total Quantity',
                                style: textTheme.bodySmall,
                              ),
                              Text(
                                '$_totalWeight KG',
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Grand Total', style: textTheme.bodySmall),
                              Text(
                                '₹ ${_grandTotal.toStringAsFixed(2)}',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.greenDark,
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
      splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color ?? AppColors.textSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color:  AppColors.white ,
        ),
      ),
    );
  }
}
