import 'dart:async';

import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:flutter/material.dart';
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
  final ApiService apiService = ApiService();

  late TextEditingController _qtyController;

  bool _loading = true;
  bool _argsLoaded = false;

  int _quantity = 1;

  String slabName = '';
  double pricePerKg = 0;
  int remainingQty = 0;

  String _selectedOption = '';
  List<String> _options = [];
  String _apiDeliveryOption = '';

  int? userId;
  int? slabId;

  bool _placingOrder = false;

  Timer? _priceTimer;

  /// ---------------- GET ROUTE ARGUMENTS ----------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_argsLoaded) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      userId = args['userId'];
      slabId = args['slabId'];

      _loadSellDetails();

      _argsLoaded = true;
    }
  }

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '1');
  }

  // ---------------- LOAD API ----------------
  Future<void> _loadSellDetails() async {
    final result = await apiService.getSellDetails(
      userId: userId!,
      slabId: slabId!,
    );

    if (result['success'] == true) {
      slabName = result['slabName'] ?? '';

      pricePerKg = (result['pricePerKg'] ?? 0).toDouble();

      remainingQty = (result['remainingQty'] ?? 0);

      _apiDeliveryOption = result['deliveryOption'] ?? '';

      _setupDeliveryOptions();

      /// Start live refresh timer
      _priceTimer ??= Timer.periodic(
        const Duration(seconds: 15),
        (_) => _refreshPrice(),
      );

      setState(() {
        _loading = false;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  /// ---------------- LIVE PRICE REFRESH ----------------
  Future<void> _refreshPrice() async {
    if (userId == null || slabId == null) return;

    final result = await apiService.getSellDetails(
      userId: userId!,
      slabId: slabId!,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final latestPrice = (result['pricePerKg'] ?? 0).toDouble();

      if ((latestPrice - pricePerKg).abs() >= 0.01) {
        setState(() {
          pricePerKg = latestPrice;
        });

        /// Better UX Snackbar
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                "Live price updated to ₹${latestPrice.toStringAsFixed(2)}",
              ),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  // ---------------- DELIVERY OPTIONS ----------------
  void _setupDeliveryOptions() {
    final option = _apiDeliveryOption.trim().toLowerCase();

    if (option == 'digital' || option == 'digital wallet') {
      _options = ['Digital Wallet'];
      _selectedOption = 'Digital Wallet';
    } else if (option == 'physical' || option == 'physical delivery') {
      _options = ['Physical Delivery', 'Self Pickup'];
      _selectedOption = 'Physical Delivery';
    } else if (option == 'pickup' || option == 'self pickup') {
      _options = ['Self Pickup', 'Physical Delivery'];
      _selectedOption = 'Self Pickup';
    } else {
      _options = ['Self Pickup'];
      _selectedOption = 'Self Pickup';
    }
  }

  // ---------------- QUANTITY ----------------
  void _incrementQty() {
    if (_quantity >= remainingQty) return;

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

  // ---------------- CALCULATIONS ----------------
  double get subTotal => pricePerKg * _quantity;

  // double get gst => _selectedOption == 'Digital Wallet' ? 0 : subTotal * 0.18;

  double get courier => _selectedOption == 'Physical Delivery' ? 250 : 0;

  double get finalTotal => subTotal + courier;

  // ---------------- DELIVERY ICON ----------------

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

  // ---------------- CHECKOUT ----------------

  Future<void> _confirmCheckout() async {
    if (_quantity < 1 || _quantity > remainingQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can sell between 1 and $remainingQty KG only'),
        ),
      );
      return;
    }

    setState(() => _placingOrder = true);

    /// refresh latest price before placing order
    final latest = await apiService.getSellDetails(
      userId: userId!,
      slabId: slabId!,
    );
    if (!mounted) return;
    if (latest['success'] == true) {
      final latestPrice = (latest['pricePerKg'] ?? 0).toDouble();

      /// If price changed, update UI
      if (latestPrice != pricePerKg) {
        setState(() {
          pricePerKg = latestPrice;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Price updated to ₹${latestPrice.toStringAsFixed(2)}. Please confirm again.",
            ),
          ),
        );

        setState(() => _placingOrder = false);

        return;
      }
    }

    /// PLACE SELL ORDER API
    final result = await apiService.placeSellOrder(
      userId: userId!,
      slabId: slabId!,
      qty: _quantity,
    );

    setState(() => _placingOrder = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));

      /// Go to success screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.orderSuccess,
        (route) => false,
        arguments: {
          "type": "SELL",
          "qty": _quantity,
          "price": finalTotal,
          "orderId": "ORD123456",
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  // ---------------- DISPOSE ----------------

  @override
  void dispose() {
    _priceTimer?.cancel();
    _qtyController.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
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
              SummaryRowCard(label: 'Slab', value: slabName),
              const SizedBox(height: 24),
              SummaryRowCard(label: 'Order Type', value: 'SELL'),
              const SizedBox(height: 24),
              SummaryRowCard(
                label: 'Price per (KG)',
                value: "₹${pricePerKg.toStringAsFixed(2)}",
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                cursorColor: AppColors.black,
                textInputAction: TextInputAction.done,
                decoration: AppDecorations.textField(
                  label: 'Quantity (Max $remainingQty)',
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

                  if (parsed < 1) {
                    _qtyController.text = '1';
                    _quantity = 1;
                    return;
                  }

                  if (parsed > remainingQty) {
                    _qtyController.text = remainingQty.toString();
                    _quantity = remainingQty;
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
              // const SizedBox(height: 24),
              // SummaryRowCard(
              //   label: 'GST (18%)',
              //   value: "₹${gst.toStringAsFixed(2)}",
              // ),
              if (_selectedOption == 'Physical Delivery')
                const SizedBox(height: 24),
              if (_selectedOption == 'Physical Delivery')
                SummaryRowCard(
                  label: 'Courier Charges',
                  value: "₹${courier.toStringAsFixed(2)}",
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
                text: _placingOrder ? 'Placing Order...' : 'Confirm Checkout',
                onPressed: _placingOrder ? null : _confirmCheckout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
