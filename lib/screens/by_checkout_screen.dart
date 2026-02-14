import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/services/auth_storage.dart';
import 'package:wealth_bridge_impex/services/cart_database_service.dart';
import 'package:wealth_bridge_impex/services/payment_service.dart';
import 'package:wealth_bridge_impex/widgets/custom_button.dart';
import 'package:wealth_bridge_impex/models/cart_item_model.dart';
import 'package:wealth_bridge_impex/widgets/summary_row_card.dart';

class ByCheckoutScreen extends StatefulWidget {
  const ByCheckoutScreen({super.key});

  @override
  State<ByCheckoutScreen> createState() => _ByCheckoutScreenState();
}

class _ByCheckoutScreenState extends State<ByCheckoutScreen> {
  
  final PaymentService paymentService = PaymentService();

  List<CartItemModel> cartItems = [];
  bool _loading = true;

  String? userEmail;
  String? userMobile;
  int? userId;

  String _selectedOption = 'Physical Delivery';

  final List<String> _options = [
    'Physical Delivery',
    'Digital Wallet',
    'Self Pickup',
  ];
  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCart();
    paymentService.initPayment();
  }

  Future<void> _loadUser() async {
    final email = await AuthStorage.getEmail();
    final mobile = await AuthStorage.getMobile();
    final id = await AuthStorage.getUserId();

    setState(() {
      userEmail = email;
      userMobile = mobile;
      userId = id;
    });
  }

  Future<void> _loadCart() async {
    final items = await CartDatabaseService.instance.getCartItems();
    setState(() {
      cartItems = items;
      _loading = false;
    });
  }

  // ---------------- calculations ----------------

  double get totalQty => cartItems.fold(0, (sum, e) => sum + e.qty);

  /// combined price of all slabs
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
    paymentService.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
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
              SummaryRowCard(label: 'Order Type', value: 'BUY'),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Price',
                value: totalPrice.toStringAsFixed(2),
              ),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Quantity (KG)',
                value: totalQty.toStringAsFixed(2),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delivery Option',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.white,
                    ),
                    child: DropdownButton<String>(
                      value: _selectedOption,
                      underline: const SizedBox(),
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                      items: _options.map((option) {
                        return DropdownMenuItem(
                          value: option,
                          child: Row(
                            children: [
                              Icon(
                                _getDeliveryIcon(option),
                                size: 18,
                                color: const Color(0xffF9B236),
                              ),
                              const SizedBox(width: 8),
                              Text(option),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedOption = value);
                      },
                    ),
                  ),
                ],
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
                  if (userEmail == null || userMobile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("User details not loaded")),
                    );
                    return;
                  }
                  paymentService.openCheckout(
                    amount: finalTotal,
                    email: userEmail!,
                    contact: userMobile!,
                  );
                  // debugPrint("RazorPayEnd----------");
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

