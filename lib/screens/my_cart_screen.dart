import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/routes/app_routes.dart';
import 'package:wealth_bridge_impex/services/cart_database_service.dart';
import 'package:wealth_bridge_impex/models/cart_item_model.dart';
import 'package:wealth_bridge_impex/utils/app_colors.dart';
import 'package:wealth_bridge_impex/widgets/custom_button.dart';

class MyCartScreen extends StatefulWidget {
  const MyCartScreen({super.key});

  @override
  State<MyCartScreen> createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  final CartDatabaseService _db = CartDatabaseService.instance;

  List<CartItemModel> _cartItems = [];
  bool _isLoading = true;

  // ---------------- DB LOAD ----------------
  Future<void> _loadCart() async {
    final items = await _db.getCartItems();
    setState(() {
      _cartItems = items;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // ---------------- ACTIONS ----------------
  Future<void> _increaseQty(CartItemModel item) async {
    final newQty = item.qty + 1;
    await _db.updateQty(item.id!, newQty,);
    _loadCart();
  }
  Future<void> _decreaseQty(CartItemModel item) async {
    if (item.qty <= 1) return;

    final newQty = item.qty - 1;
    await _db.updateQty(item.id!, newQty,);
    _loadCart();
  }
  Future<void> _removeItem(int id) async {
    await _db.deleteItem(id);
    _loadCart();
  }

  // ---------------- TOTALS ----------------
  double get totalQty => _cartItems.fold(0.0, (sum, e) => sum + e.qty);
  double get grandTotal => _cartItems.fold(0.0, (sum, e) => sum + e.amount);

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text(
          'My Cart',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
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
                                  'Slab: ${item.slab}',
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
                                    onPressed: () => _removeItem(item.id!),
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
                                  'Price: ₹ ${item.buyPrice.toStringAsFixed(2)} / KG',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '₹ ${item.amount.toStringAsFixed(2)}',
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
                                  item.qty % 1 == 0
                                      ? item.qty.toInt().toString()
                                      : item.qty.toString(),
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
                        'Total Quantity: ${totalQty % 1 == 0 ? totalQty.toInt() : totalQty} KG',
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
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content: Text('Coming soon'),
                          //     duration: Duration(seconds: 2),
                          //   ),
                          // );
                           Navigator.pushNamed(
                              context,
                              AppRoutes.checkOut,
                              // arguments: _cartItems,
                            );
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
