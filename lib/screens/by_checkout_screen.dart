import 'dart:async';

import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/services/payment_service.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:copper_hub/widgets/custom_dropdown.dart';
import 'package:copper_hub/widgets/summary_row_card.dart';
import 'package:flutter/material.dart';

class ByCheckoutScreen extends StatefulWidget {
  const ByCheckoutScreen({super.key});

  @override
  State<ByCheckoutScreen> createState() => _ByCheckoutScreenState();
}

class _ByCheckoutScreenState extends State<ByCheckoutScreen> {
  final PaymentService paymentService = PaymentService();
  final ApiService apiService = ApiService();

  List<dynamic> cartItems = [];
  bool _loading = true;

  String? userEmail;
  String? userMobile;
  int? userId;
  double pickupCharge = 0;

  String _selectedOption = 'Digital Wallet';

  final List<String> _options = [
    'Physical Delivery',
    'Digital Wallet',
    'Self Pickup',
  ];

  Timer? _priceTimer;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    _initCheckout();

    paymentService.initPayment(
      onSuccess: (paymentId) {
        _placeOrder(paymentId); // success calls placeOrder
      },
      onError: (message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Payment Failed")));
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.liveRates,
          (route) => false,
        );
      },
    );
  }

  // ================= INIT =================
  Future<void> _initCheckout() async {
    await _loadUser();
    await _fetchCart();
  }

  Future<void> _loadUser() async {
    userEmail = await AuthStorage.getEmail();
    userMobile = await AuthStorage.getMobile();
    userId = await AuthStorage.getUserId();
  }

  // ================= GET CART =================
  Future<void> _fetchCart() async {
    if (userId == null) return;

    setState(() => _loading = true);

    final result = await apiService.getCart(userId: userId!);

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        cartItems = result['data'];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Cart load failed")),
      );
    }
  }

  // ================= DELIVERY CHARGES =================
  Future<void> _getPickupCharge() async {
    if (userId == null || cartItems.isEmpty) return;

    final result = await apiService.getDeliveryCharges(
      userId: userId!,
      weight: totalWeight,
      deliveryOption: _selectedOption,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() => pickupCharge = result['deliveryCharge']?.toDouble() ?? 0);
    } else {
      setState(() => pickupCharge = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Unable to fetch courier')),
      );
    }
  }

  // ================= UNIT WEIGHT =================
  double getUnitWeightFromSlab(String slabName) {
    final clean = slabName.toUpperCase().replaceAll('KG', '').trim();

    if (clean.startsWith('0.25')) return 0.25;
    if (clean.startsWith('0.5')) return 0.5;

    return 1;
  }

  // ================= CALCULATIONS =================
  double get totalWeight {
    double weight = 0;

    for (final item in cartItems) {
      final slabName = item['SlabName'] ?? '';
      final qty = (item['Quantity'] ?? 0).toDouble();

      final unit = getUnitWeightFromSlab(slabName);

      weight += unit * qty;
    }

    return weight;
  }

  double get subTotal =>
      cartItems.fold(0, (sum, e) => sum + (e['TotalAmount'] ?? 0));

  double get gst => _selectedOption == 'Digital Wallet' ? 0 : subTotal * 0.18;

  double get courierCharges =>
      _selectedOption == 'Physical Delivery' ? pickupCharge : 0;

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
    _priceTimer?.cancel();
    paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Checkout')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // buildSlabPrices(),
              SummaryRowCard(
                label: 'Slab',
                value: cartItems.map((e) => e['SlabName']).join(', '),
              ),
              const SizedBox(height: 24),
              SummaryRowCard(label: 'Order Type', value: 'BUY'),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Price per (KG)',
                value: cartItems
                    .map(
                      (e) =>
                          "₹${(e['PricePerKg'] ?? 0).toDouble().toStringAsFixed(2)}",
                    )
                    .join(', '),
              ),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Quantity (KG)',
                value: totalWeight.toStringAsFixed(2),
              ),
              const SizedBox(height: 24),

              CustomDropdown(
                label: 'Delivery Option',
                value: _selectedOption,
                items: _options,
                iconBuilder: _getDeliveryIcon,
                onChanged: (value) async {
                  setState(() => _selectedOption = value);
                  if (value == 'Physical Delivery') {
                    await _getPickupCharge();
                  } else {
                    setState(() => pickupCharge = 0);
                  }
                },
              ),

              const SizedBox(height: 24),
              if (_selectedOption == 'Physical Delivery' ||
                  _selectedOption == 'Self Pickup')
                SummaryRowCard(
                  label: 'GST (18%)',
                  value: "₹${gst.toStringAsFixed(2)}",
                ),
              const SizedBox(height: 24),
              if (_selectedOption == 'Physical Delivery')
                SummaryRowCard(
                  label: 'Courier Charges',
                  value: "₹${courierCharges.toStringAsFixed(2)}",
                  // totalWeight.toStringAsFixed(2),
                ),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Sub Total',
                value: "₹${subTotal.toStringAsFixed(2)}",
              ),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Final Total ₹',
                value: "₹${finalTotal.toStringAsFixed(2)}",
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- PLACE ORDER API ----------------

  Future<void> _placeOrder(String razorpayPaymentId) async {
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User ID not found")));
      return;
    }

    final result = await apiService.placeOrderFromCart(
      userId: userId!,
      razorpayPaymentId: razorpayPaymentId,
      deliveryOption: _selectedOption,
      gst: gst.toStringAsFixed(2),
      courier: courierCharges.toStringAsFixed(2),
    );

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Order placed successfully"),
        ),
      );

      // navigate success
      if (!mounted) return;
      final data = result['data']['Data'];

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.orderSuccess,
        (route) => route.settings.name == AppRoutes.liveRates,
        arguments: {
          "type": "BUY",
          "qty": data['TotalQty'],
          "price": data['FinalTotal'],
          "orderId": data['OrderId'],
          "paymentStatus": data['PaymentStatus'],
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Order failed")),
      );
    }
  }
}
