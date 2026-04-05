import 'dart:async';

import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/utils/bank_details_dialog.dart';
import 'package:flutter/material.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:copper_hub/widgets/custom_dropdown.dart';
import 'package:copper_hub/widgets/summary_row_card.dart';
import 'package:flutter/services.dart';

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
  bool _placingOrder = false;

  int _quantity = 1;

  String slabName = '';
  double pricePerKg = 0;
  int remainingQty = 0;

  String _selectedOption = '';
  List<String> _options = [];
  String _apiDeliveryOption = '';

  int? userId;
  int? slabId;

  Timer? _priceTimer;
  Timer? _qtyDebounce;

  double pickupCharge = 0;

  Map<String, dynamic>? _bankDetails;

  /// ---------------- GET ROUTE ARGUMENTS ----------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_argsLoaded) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

      userId = args['userId'];
      slabId = args['slabId'];

      _loadInitialData();

      _argsLoaded = true;
    }
  }

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: '1');
  }

  // ---------------- INITIAL LOAD ----------------
  Future<void> _loadInitialData() async {
    await _checkBankDetails();
    await _loadSellDetails();
  }

  // ---------------- BANK CHECK ----------------
  bool isBankIncomplete(Map<String, dynamic>? data) {
    if (data == null) return true;

    return (data['accountHolder']?.toString().trim().isEmpty ?? true) ||
        (data['accountNumber']?.toString().trim().isEmpty ?? true) ||
        (data['ifscCode']?.toString().trim().isEmpty ?? true) ||
        (data['bankName']?.toString().trim().isEmpty ?? true);
  }

  Future<void> _checkBankDetails() async {
    if (userId == null) return;

    final result = await apiService.getBankDetails(userId: userId!);

    if (!mounted) return;

    if (result['success'] == true) {
      _bankDetails = result['data'];
    }

    if (result['success'] != true || isBankIncomplete(_bankDetails)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showBankDialog();
      });
    }
  }

  void showBankDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: BankDetailsDialog(
          userId: userId!,
          bankData: _bankDetails,
          onSaved: () async {
            await _checkBankDetails();
          },
        ),
      ),
    );
  }

  // ---------------- LOAD API ----------------
  Future<void> _loadSellDetails() async {
    final result = await apiService.getSellDetails(
      userId: userId!,
      slabId: slabId!,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      slabName = result['slabName'] ?? '';
      pricePerKg = (result['pricePerKg'] ?? 0).toDouble();
      remainingQty = result['remainingQty'] ?? 0;
      _apiDeliveryOption = result['deliveryOption'] ?? '';

      _setupDeliveryOptions();

      if (_selectedOption == 'Doorstep Pickup') {
        await _getPickupCharge();
      }
      _startPriceTimer();

      setState(() => _loading = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Something went wrong',
          ),
        ),
      );
    }
  }

  void _startPriceTimer() {
    _priceTimer?.cancel();

    _priceTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _refreshPrice(),
    );
  }

  /// ---------------- LIVE PRICE REFRESH ----------------
  Future<void> _refreshPrice() async {
    if (_placingOrder || userId == null || slabId == null) return;

    final result = await apiService.getSellDetails(
      userId: userId!,
      slabId: slabId!,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final latestPrice = (result['pricePerKg'] ?? 0).toDouble();

      if ((latestPrice - pricePerKg).abs() >= 0.01) {
        setState(() => pricePerKg = latestPrice);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                "Market price updated to ₹${latestPrice.toStringAsFixed(2)}",
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
      _options = ['Wallet Credit'];
      _selectedOption = 'Wallet Credit';
    } else if (option == 'physical' || option == 'physical delivery') {
      _options = ['Doorstep Pickup', 'Self Drop'];
      _selectedOption = 'Doorstep Pickup';
    } else if (option == 'pickup' || option == 'self pickup') {
      _options = ['Self Drop', 'Doorstep Pickup'];
      _selectedOption = 'Self Drop';
    } else {
      _options = ['Self Drop'];
      _selectedOption = 'Self Drop';
    }
  }

  // ---------------- QUANTITY ----------------
  void _incrementQty() {
    if (_quantity >= remainingQty) return;
    _updateQty(_quantity + 1);
  }

  void _decrementQty() {
    if (_quantity <= 1) return;
    _updateQty(_quantity - 1);
  }

  void _updateQty(int qty) {
    setState(() {
      _quantity = qty;
      _qtyController.text = qty.toString();
    });

    _debouncePickupCharge();
  }

  /// debounce for qty change
  void _debouncePickupCharge() {
    _qtyDebounce?.cancel();

    _qtyDebounce = Timer(const Duration(milliseconds: 500), () {
      if (_selectedOption == 'Doorstep Pickup') {
        _getPickupCharge();
      }
    });
  }

  // ---------------- WEIGHT HELPER ----------------
  double getUnitWeightFromSlab(String slabName) {
    final clean = slabName.toUpperCase().replaceAll('KG', '').trim();

    if (clean.startsWith('0.25')) return 0.25;
    if (clean.startsWith('0.5')) return 0.5;

    return 1;
  }

  // ---------------- CALCULATIONS ----------------
  double get totalWeight {
    final unitWeight = getUnitWeightFromSlab(slabName);
    return _quantity * unitWeight;
  }

  double get subTotal => pricePerKg * _quantity;

  double get courier => _selectedOption == 'Doorstep Pickup' ? pickupCharge : 0;
  double get finalTotal => subTotal + courier;

  // ---------------- DELIVERY ICON ----------------

  IconData _getDeliveryIcon(String option) {
    switch (option) {
      case 'Doorstep Pickup':
        return Icons.local_shipping;

      case 'Wallet Credit':
        return Icons.account_balance_wallet;

      case 'Self Drop':
        return Icons.store;

      default:
        return Icons.local_shipping;
    }
  }

  // ---------------- CHECKOUT ----------------

  Future<void> _confirmCheckout() async {
    if (_placingOrder) return;

    if (_quantity < 1 || _quantity > remainingQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can sell between 1 and $remainingQty KG only'),
        ),
      );
      return;
    }

    setState(() => _placingOrder = true);

    if (!mounted) return;
    // ---------------- Ensure latest pickup charge ----------------
    _qtyDebounce?.cancel();
    if (_selectedOption == 'Doorstep Pickup') {
      await _getPickupCharge();
    }
    // ---------------- Verify latest price ----------------
    final latest = await apiService.getSellDetails(
      userId: userId!,
      slabId: slabId!,
    );

    if (!mounted) return;

    if (latest['success'] != true) {
      setState(() => _placingOrder = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            latest['message']?.toString() ?? 'Unable to verify price',
          ),
        ),
      );
      return;
    }

    final latestPrice = (latest['pricePerKg'] ?? 0).toDouble();

    if (latestPrice != pricePerKg) {
      setState(() {
        pricePerKg = latestPrice;
        _placingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Price updated to ₹${latestPrice.toStringAsFixed(2)}. Please confirm again.",
          ),
        ),
      );

      return;
    }

    // ---------------- PLACE SELL ORDER ----------------
    final result = await apiService.placeSellOrder(
      userId: userId!,
      slabId: slabId!,
      qty: _quantity,
      deliveryOption: _selectedOption,
    );

    setState(() => _placingOrder = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Sell order placed'),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.orderSuccess,
        arguments: {
          "type": "SELL",
          "qty": result['data']['Qty'],
          "price": result['data']['Total'],
          "orderId": result['data']['OrderId'],
          "paymentStatus": result['data']['PaymentStatus'],
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Something went wrong',
          ),
        ),
      );
    }
  }

  Future<void> _getPickupCharge() async {
    if (userId == null || slabId == null) return;

    final result = await apiService.getDeliveryCharges(
      userId: userId!,
      weight: totalWeight,
      deliveryOption: _selectedOption,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        pickupCharge = (result['deliveryCharge'] ?? 0).toDouble();
      });
    } else {
      setState(() {
        pickupCharge = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Unable to fetch courier')),
      );
    }
  }

  // ---------------- DISPOSE ----------------

  @override
  void dispose() {
    _priceTimer?.cancel();
    _qtyDebounce?.cancel();
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
      appBar: AppBar(title: const Text('Sell Checkout')),
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  final parsed = int.tryParse(value) ?? 1;

                  int safeQty = parsed.clamp(1, remainingQty);

                  if (safeQty.toString() != value) {
                    _qtyController.text = safeQty.toString();
                    _qtyController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _qtyController.text.length),
                    );
                  }

                  setState(() {
                    _quantity = safeQty;
                  });
                  _debouncePickupCharge();
                },
              ),
              const SizedBox(height: 24),
              CustomDropdown(
                label: 'Delivery Option',
                value: _selectedOption,
                items: _options,
                iconBuilder: _getDeliveryIcon,
                onChanged: (value) async {
                  setState(() => _selectedOption = value);
                  if (value == 'Doorstep Pickup') {
                    await _getPickupCharge();
                  } else {
                    setState(() => pickupCharge = 0);
                  }
                },
              ),
              // if (_selectedOption == 'Physical Delivery')
              if (_selectedOption == 'Doorstep Pickup')
                const SizedBox(height: 24),
              // if (_selectedOption == 'Physical Delivery')
              if (_selectedOption == 'Doorstep Pickup')
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
                text: 'Confirm Checkout',
                isLoading: _placingOrder,
                onPressed: _placingOrder ? null : _confirmCheckout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
