import 'package:flutter/material.dart';
import 'package:copper_hub/services/payment_service.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:copper_hub/widgets/custom_dropdown.dart';
import 'package:copper_hub/widgets/summary_row_card.dart';

class SellCheckoutScreen extends StatefulWidget {
  const SellCheckoutScreen({super.key});

  @override
  State<SellCheckoutScreen> createState() => _SellCheckoutScreenState();
}

class _SellCheckoutScreenState extends State<SellCheckoutScreen> {
  final PaymentService paymentService = PaymentService();

  late TextEditingController _qtyController;

  int _quantity = 1;

  late String _selectedOption;
  final List<String> _options = [
    'Physical Delivery',
    'Digital Wallet',
    'Self Pickup',
  ];

  @override
  void initState() {
    super.initState();

    _selectedOption = _options.first;

    _qtyController = TextEditingController(text: _quantity.toString());
  }

  // ---------------- Quantity Controls ----------------

  void _incrementQty() {
    if (_quantity >= 1) return;

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
  // ---------------- Delivery Icon ----------------

  IconData _getDeliveryIcon(String option) {
    switch (option) {
      case 'Physical Delivery':
        return Icons.local_shipping;

      case 'Digital Wallet':
        return Icons.account_balance_wallet;

      case 'Self Pickup':
        return Icons.store;

      default:
        return Icons.local_shipping;
    }
  }

  void _confirmCheckout() async {
    if (_quantity > 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('You can sell maximum ${50} KG')));

      return;
    }

    /// Razorpay open here
  }

  @override
  void dispose() {
    _qtyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (_loading) {
    //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
    // }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text(
          'Sell Checkout',
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
              SummaryRowCard(label: 'Price per (KG)', value: '2323'),
              const SizedBox(height: 24),
              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                cursorColor: AppColors.black,
                textInputAction: TextInputAction.done,
                decoration: AppDecorations.textField(
                  label: 'Quantity',
                  suffixIcon: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: _incrementQty,
                        child: const Icon(Icons.keyboard_arrow_up, size: 22),
                      ),
                      InkWell(
                        onTap: _decrementQty,
                        child: const Icon(Icons.keyboard_arrow_down, size: 22),
                      ),
                    ],
                  ),
                ),
                onChanged: (value) {
                  final parsed = int.tryParse(value);

                  if (parsed == null) return;

                  if (parsed <= 0) return;

                  if (parsed > 50) {
                    _qtyController.text = '50';

                    _quantity = 50;

                    return;
                  }

                  setState(() {
                    _quantity = parsed;
                  });
                },
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
              SummaryRowCard(label: 'GST (18%)', value: '250'),
              const SizedBox(height: 24),
              SummaryRowCard(label: 'Courier Charges', value: '400'),
              const SizedBox(height: 24),
              SummaryRowCard(label: 'Sub Total', value: '232300'),
              const SizedBox(height: 24),
              SummaryRowCard(label: 'Final Total ₹', value: '2323567'),
              const SizedBox(height: 30),
              CustomButton(
                width: double.infinity,
                text: 'Confirm Checkout',
                onPressed: _confirmCheckout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
