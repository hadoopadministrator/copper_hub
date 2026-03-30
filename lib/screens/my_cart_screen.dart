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

  // ---------------- LOAD CART ----------------
  Future<void> _loadCart() async {
    setState(() => _isLoading = true);

    _userId ??= await AuthStorage.getUserId();

    if (_userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final response = await _api.getCart(userId: _userId!);
    print("GET CART RESPONSE: $response");

    if (response['success']) {
      final List list = response['data'];

      print("RAW CART LIST: $list");
      setState(() {
        _cartItems = list.map((e) {
          print("ITEM JSON: $e");
          return CartItemModel.fromJson(e);
        }).toList();

        print("PARSED ITEMS: $_cartItems"); // optional
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response['message'])));
    }
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

  // ---------------- ACTIONS ----------------
  Future<void> _increaseQty(CartItemModel item) async {
    final limits = getQtyLimitsFromSlab(item.slabName);
    final maxQty = limits.max == 0 ? null : limits.max;

    if (maxQty != null && item.quantity >= maxQty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Maximum limit is $maxQty KG")));
      return;
    }

    final oldQty = item.quantity;
    final newQty = oldQty + 1;

    final index = _cartItems.indexOf(item);

    // instant UI update
    setState(() {
      _cartItems[index] = item.copyWith(quantity: newQty);
    });

    // silent API call
    final res = await _api.updateCartQty(
      userId: _userId!,
      slabId: item.slabId,
      qty: newQty.toInt(),
    );

    if (!res['success']) {
      setState(() {
        _cartItems[index] = item.copyWith(quantity: oldQty);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  Future<void> _decreaseQty(CartItemModel item) async {
    final limits = getQtyLimitsFromSlab(item.slabName);
    final minQty = limits.min;

    if (item.quantity <= minQty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Minimum limit is $minQty KG")));
      return;
    }

    final oldQty = item.quantity;
    final newQty = oldQty - 1;

    final index = _cartItems.indexOf(item);

    setState(() {
      _cartItems[index] = item.copyWith(quantity: newQty);
    });

    final res = await _api.updateCartQty(
      userId: _userId!,
      slabId: item.slabId,
      qty: newQty.toInt(),
    );

    if (!res['success']) {
      setState(() {
        _cartItems[index] = item.copyWith(quantity: oldQty);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  Future<void> _removeItem(CartItemModel item) async {
    final index = _cartItems.indexOf(item);
    final removedItem = _cartItems[index];

    // Instant UI update: remove item locally
    setState(() {
      _cartItems.removeAt(index);
    });

    final res = await _api.removeCartItem(
      userId: _userId!,
      slabId: item.slabId,
    );
    //  rollback
    if (!res['success']) {
      setState(() {
        _cartItems.insert(index, removedItem);
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['message'])));
    }
  }

  // ---------------- TOTALS ----------------
  double get totalQty => _cartItems.fold(0.0, (sum, e) => sum + e.quantity);

  double get grandTotal =>
      _cartItems.fold(0.0, (sum, e) => sum + e.totalAmount);

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
                          borderRadius: BorderRadius.circular(8),
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
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xffe8003e),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    onPressed: () => _removeItem(item),
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // -------- Price + Amount --------
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Price: ₹ ${item.pricePerKg.toStringAsFixed(2)} / KG',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '₹ ${item.totalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // -------- Quantity --------
                            Row(
                              children: [
                                const Text(
                                  'Quantity (KG)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                _qtyButton(
                                  icon: Icons.remove,
                                  onTap: () => _decreaseQty(item),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  item.quantity.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                _qtyButton(
                                  icon: Icons.add,
                                  onTap: () => _increaseQty(item),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  color: AppColors.white,
                  child: Column(
                    children: [
                      Text(
                        'Total Quantity: $totalQty KG',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Grand Total: ₹ ${grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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
  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff6c747e),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.white, size: 22),
      ),
    );
  }
}
