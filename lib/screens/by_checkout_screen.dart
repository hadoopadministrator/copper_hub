import 'dart:async';

import 'package:copper_hub/models/cart_item_model.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/services/cart_database_service.dart';
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

  Timer? _priceTimer;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    _initCheckout();

    /// LIVE AUTO PRICE REFRESH EVERY 15 SEC
    _priceTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _syncCartWithLiveRates(silent: true),
    );

    paymentService.initPayment(
      onSuccess: (paymentId) {
        _placeOrder(paymentId);
      },
      onError: (message) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(" payment not made $message")));
      },
    );
  }

  Future<void> _initCheckout() async {
    await _loadUser();
    await _syncCartWithLiveRates();
  }

  Future<void> _loadUser() async {
    userEmail = await AuthStorage.getEmail();
    userMobile = await AuthStorage.getMobile();
    userId = await AuthStorage.getUserId();
  }

  // ================= SYNC CART WITH LIVE RATES =================

  Future<void> _syncCartWithLiveRates({bool silent = false}) async {
    if (!mounted) return;

    if (!silent) {
      setState(() => _loading = true);
    }

    final result = await apiService.getLiveCopperRate();

    if (!mounted) return;

    if (result['success'] == true) {
      final slabs = result['data']['Slabs'] as List;

      final db = CartDatabaseService.instance;
      final items = await db.getCartItems();

      bool priceChanged = false;

      for (final item in items) {
        final liveSlab = slabs.cast<Map<String, dynamic>?>().firstWhere(
          (s) => s?['Id'] == item.slabId,
          orElse: () => null,
        );

        if (liveSlab != null) {
          final newBuyPrice =
              double.tryParse(liveSlab['BuyPrice'].toString()) ?? item.buyPrice;

          if ((newBuyPrice - item.buyPrice).abs() >= 0.01) {
            await db.updatePrice(item.id!, newBuyPrice);
            priceChanged = true;
          }
        }
      }

      final updatedItems = await db.getCartItems();

      if (!mounted) return;

      setState(() {
        cartItems = updatedItems;
        _loading = false;
      });

      /// show only when price changed and silent sync
      if (silent && priceChanged) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text("Price updated based on live market"),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } else {
      if (!silent && mounted) {
        setState(() => _loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Failed to sync prices")),
        );
      }
    }
  }

  // ---------------- calculations ----------------

  double get totalQty => cartItems.fold(0, (sum, e) => sum + e.qty);

  /// combined price of all slabs
  // double get totalPrice => cartItems.fold(0, (sum, e) => sum + e.buyPrice);

  double get subTotal => cartItems.fold(0, (sum, e) => sum + e.amount);

  double get effectivePricePerKg => totalQty == 0 ? 0 : subTotal / totalQty;

  // bool get isSingleItem => cartItems.length == 1;

  // String get pricePerKgLabel =>
  //     isSingleItem ? 'Price per (KG)' : 'Effective Price per KG';

  // double get pricePerKgValue =>
  //     isSingleItem ? cartItems.first.buyPrice : effectivePricePerKg;

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
  //  Widget buildSlabPrices() {
  //   return Column(
  //     children: cartItems.map((item) {
  //       return Padding(
  //         padding:
  //             const EdgeInsets.only(bottom: 16),
  //         child: SummaryRowCard(
  //           label:
  //               "Slab ${item.slab} /Quantity (${item.qty.toStringAsFixed(2)} KG)",
  //           value:
  //               "Price per (KG): ₹${item.buyPrice.toStringAsFixed(2)} / KG",
  //         ),
  //       );
  //     }).toList(),
  //   );
  // }

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Buy Checkout',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // buildSlabPrices(),
              SummaryRowCard(
                label: 'Slab',
                value: cartItems.map((e) => e.slab).join(', '),
                // value: 'CART ITEMS',
              ),
              const SizedBox(height: 24),
              SummaryRowCard(label: 'Order Type', value: 'BUY'),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Price per (KG)',
                value: cartItems
                    .map((e) => "₹${e.buyPrice.toStringAsFixed(2)}")
                    .join(', '),
              ),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Quantity (KG)',
                value: totalQty.toStringAsFixed(2),
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

      // clear cart
      await CartDatabaseService.instance.clearCart();

      // navigate success
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.orderSuccess,
        (route) => false,
        arguments: {
          "type": "BUY",
          "qty": totalQty,
          "price": finalTotal,
          "orderId": "ORD123456",
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Order failed")),
      );
    }
  }
}
