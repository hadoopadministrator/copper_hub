import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/services/auth_storage.dart';
// import 'package:wealth_bridge_impex/routes/app_routes.dart';
import 'package:wealth_bridge_impex/services/cart_database_service.dart';
import 'package:wealth_bridge_impex/services/payment_service.dart';
import 'package:wealth_bridge_impex/widgets/custom_button.dart';
import 'package:wealth_bridge_impex/models/cart_item_model.dart';

class ByCheckoutScreen extends StatefulWidget {
  const ByCheckoutScreen({super.key});

  @override
  State<ByCheckoutScreen> createState() => _ByCheckoutScreenState();
}

class _ByCheckoutScreenState extends State<ByCheckoutScreen> {
  // late TextEditingController _qtyController;
  // late int _quantity;
  final PaymentService paymentService = PaymentService();

  List<CartItemModel> cartItems = [];
  bool _loading = true;
  String? userEmail;
  String? userMobile;

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

    setState(() {
      userEmail = email;
      userMobile = mobile;
    });
  }

  Future<void> _loadCart() async {
    final items = await CartDatabaseService.instance.getCartItems();
    setState(() {
      cartItems = items;
      _loading = false;
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();

  //   if (!_initialized) {
  //     final args = ModalRoute.of(context)?.settings.arguments;
  //     if (args is CartItemModel) {
  //       cartItem = args;
  //       _quantity = cartItem.qty.toInt();
  //     } else {
  //       // fallback if argument missing
  //       cartItem = CartItemModel(
  //         slab: 'Unknown',
  //         price: 0,
  //         qty: 1,
  //         amount: 0,
  //         createdAt: DateTime.now().toString(),
  //       );
  //       _quantity = 1;
  //     }
  //     _qtyController = TextEditingController(text: _quantity.toString());
  //     _initialized = true;
  //   }
  // }

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

  // void _incrementQty() {
  //   setState(() {
  //     _quantity++;
  //     _qtyController.text = _quantity.toString();
  //   });
  // }

  // void _decrementQty() {
  //   if (_quantity <= 1) return;
  //   setState(() {
  //     _quantity--;
  //     _qtyController.text = _quantity.toString();
  //   });
  // }

  @override
  void dispose() {
    paymentService.dispose();
    super.dispose();
  }

  // double get subTotal => cartItem.price * _quantity;
  // double get gst => subTotal * 0.18; // 18% GST
  // double get courierCharges => 250; // fixed for now
  // double get finalTotal => subTotal + gst + courierCharges;

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

              // TextField(
              //   controller: _qtyController,
              //   keyboardType: TextInputType.number,
              //   cursorColor: Colors.black,
              //   textInputAction: TextInputAction.done,
              //   decoration: AppDecorations.textField(
              //     label: '',
              //     suffixIcon: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         InkWell(
              //           onTap: _incrementQty,
              //           child: const Icon(Icons.keyboard_arrow_up, size: 22),
              //         ),
              //         InkWell(
              //           onTap: _decrementQty,
              //           child: const Icon(Icons.keyboard_arrow_down, size: 22),
              //         ),
              //       ],
              //     ),
              //   ),
              //   onChanged: (value) {
              //     final parsed = int.tryParse(value);
              //     if (parsed != null && parsed > 0) {
              //       setState(() => _quantity = parsed);
              //     }
              //   },
              // ),
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

class SummaryRowCard extends StatelessWidget {
  final String label;
  final String value;
  const SummaryRowCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xfff8f9fa),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
