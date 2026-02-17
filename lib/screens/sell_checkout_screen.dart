import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/models/cart_item_model.dart';
import 'package:wealth_bridge_impex/services/cart_database_service.dart';
import 'package:wealth_bridge_impex/services/payment_service.dart';
import 'package:wealth_bridge_impex/utils/app_colors.dart';
import 'package:wealth_bridge_impex/utils/input_decoration.dart';
import 'package:wealth_bridge_impex/widgets/custom_button.dart';
import 'package:wealth_bridge_impex/widgets/custom_dropdown.dart';
import 'package:wealth_bridge_impex/widgets/summary_row_card.dart';

class SellCheckoutScreen extends StatefulWidget {
  const SellCheckoutScreen({super.key});

  @override
  State<SellCheckoutScreen> createState() => _SellCheckoutScreenState();
}

class _SellCheckoutScreenState extends State<SellCheckoutScreen> {
  final PaymentService paymentService = PaymentService();
  late TextEditingController _qtyController;
  late int _quantity;
  List<CartItemModel> cartItems = [];
  bool _loading = true;
  String selectedLot = 'Lot 1 - 60 KG';

  String _selectedOption = 'Physical Delivery';

  final List<String> _options = [
    'Physical Delivery',
    'Digital Wallet',
    'Self Pickup',
  ];
  @override
  void initState() {
    super.initState();
    _quantity = 1; // default value
    _qtyController = TextEditingController(text: _quantity.toString());
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await CartDatabaseService.instance.getCartItems();
    setState(() {
      cartItems = items;
      _loading = false;
    });
  }

  void _incrementQty() {
    setState(() {
      _quantity++;
      _qtyController.text = _quantity.toString();
    });
  }

  void _decrementQty() {
    if (_quantity <= 1) return;
    setState(() {
      _quantity--;
      _qtyController.text = _quantity.toString();
    });
  }
  // ---------------- calculations ----------------

  double get totalQty => cartItems.fold(0, (sum, e) => sum + e.qty);

  double get totalPrice => cartItems.fold(0, (sum, e) => sum + e.buyPrice);

  double get subTotal => cartItems.fold(0, (sum, e) => sum + e.amount);

  double get gst => _selectedOption == 'Digital Wallet' ? 0 : subTotal * 0.18;

  double get courierCharges => _selectedOption == 'Physical Delivery' ? 250 : 0;

  double get finalTotal => subTotal + gst + courierCharges;

  IconData _getDeliveryIcon(String option) {
    switch (option) {
      case 'Physical Delivery':
        return Icons.local_shipping;
      case 'Digital Wallet':
        return Icons.account_balance_wallet;
      case 'Self Pickup':
        return Icons.storefront;
      default:
        return Icons.local_shipping;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text(
          'Check Out',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SummaryRowCard(
                label: 'Slab',
                // value: cartItems.map((e) => e.slab).join(', '),
                value: 'CART ITEMS',
              ),
              const SizedBox(height: 24),
              SummaryRowCard(label: 'Order Type', value: 'SELL'),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Price',
                value: totalPrice.toStringAsFixed(2),
              ),
              const SizedBox(height: 24),
              // const Text(
              //   "Quantity (KG)",
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              // ),
              // const SizedBox(height: 8),
              // Container(
              //   width: double.infinity,
              //   padding: const EdgeInsets.all(14),
              //   decoration: BoxDecoration(
              //     color: const Color(0xfff8f9fa),
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: Colors.grey, width: 1),
              //   ),
              //   child: Text(
              //     totalQty.toStringAsFixed(2),
              //     style: const TextStyle(fontSize: 16),
              //   ),
              // ),
              Row(
                children: [
                  /// Lot dropdown (UI only)
                  Expanded(
                    flex: 2,
                    child: CustomDropdown(
                      label: 'Select Lot',
                      value: selectedLot,
                      items: const [
                        'Lot 1 - 60 KG',
                        'Lot 2 - 70 KG',
                        'Lot 3 - 100 KG',
                      ],
                      onChanged: (value) {
                        setState(() => selectedLot = value);
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      cursorColor: AppColors.black,
                      textInputAction: TextInputAction.done,
                      decoration: AppDecorations.textField(
                        label: '',
                        suffixIcon: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: _incrementQty,
                              child: const Icon(
                                Icons.keyboard_arrow_up,
                                size: 22,
                              ),
                            ),
                            InkWell(
                              onTap: _decrementQty,
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          setState(() => _quantity = parsed);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CustomDropdown(
                label: 'Delivery Option',
                value: _selectedOption,
                items: _options,
                iconBuilder: _getDeliveryIcon,
                onChanged: (value) {
                  setState(() => _selectedOption = value);
                },
              ),
              const SizedBox(height: 24),
              SummaryRowCard(label: 'GST (18%)', value: gst.toStringAsFixed(2)),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Courier Charges',
                value: courierCharges.toStringAsFixed(2),
              ),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Sub Total',
                value: subTotal.toStringAsFixed(2),
              ),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Final Total ₹',
                value: finalTotal.toStringAsFixed(2),
              ),
              const SizedBox(height: 30),
              CustomButton(
                width: double.infinity,
                text: 'Confirm Checkout',
                onPressed: () {
                  //  paymentService.openCheckout(500);
                  // Navigator.pushNamed(context, AppRoutes.orderSuccess);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
