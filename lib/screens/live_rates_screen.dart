import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wealth_bridge_impex/routes/app_routes.dart';
import 'package:wealth_bridge_impex/services/api_service.dart';
import 'package:wealth_bridge_impex/services/auth_storage.dart';
import 'package:wealth_bridge_impex/services/cart_database_service.dart';
import 'package:wealth_bridge_impex/models/cart_item_model.dart';
import 'package:wealth_bridge_impex/utils/app_colors.dart';
import 'package:wealth_bridge_impex/utils/input_decoration.dart';
import 'package:wealth_bridge_impex/widgets/custom_button.dart';
import 'package:wealth_bridge_impex/widgets/drawer_widget.dart';

class LiveRatesScreen extends StatefulWidget {
  const LiveRatesScreen({super.key});

  @override
  State<LiveRatesScreen> createState() => _LiveRatesScreenState();
}

class _LiveRatesScreenState extends State<LiveRatesScreen> {
  final Map<int, TextEditingController> _qtyControllers = {};
  final Map<int, int> _quantities = {};

  Map<String, dynamic>? _copperRate;
  bool _isLoading = true;

  final ApiService apiService = ApiService();
  Timer? _fetchTimer;
  // DateTime? _lastUpdated;

  // ---------------- API ----------------

  Future<void> _fetchLiveRates({bool showLoader = false}) async {
    debugPrint("LiveRates API called at: ${DateTime.now().toString()}");
    if (showLoader && mounted) {
      setState(() => _isLoading = true);
    }

    final result = await apiService.getLiveCopperRate();

    if (result['success'] == true) {
      setState(() {
        _copperRate = result['data'];
        _isLoading = false;
        // _lastUpdated = DateTime.now();
      });
    } else {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to load rates')),
      );
    }
  }

  void _startAutoFetch() {
    _fetchTimer?.cancel();
    _fetchTimer = Timer.periodic(const Duration(seconds: 300), (_) {
      debugPrint("Timer triggered at: ${DateTime.now()}");
      _fetchLiveRates();
    });
  }

  // ---------------- Quantity helpers ----------------

  ({int min, int? max}) getQtyLimitsFromSlab(String slabName) {
    final clean = slabName.replaceAll('KG', '').trim();

    // Fractional slabs 0.25 KG + or 0.5 KG + → min 1, max unlimited
    if (clean.startsWith('0.25') || clean.startsWith('0.5')) {
      return (min: 1, max: null);
    }

    // Range slabs, e.g., 1 - 15 KG
    if (clean.contains('-')) {
      final parts = clean.split('-');
      return (min: int.parse(parts[0].trim()), max: int.parse(parts[1].trim()));
    }
    // + slabs, e.g., 100 KG +
    if (clean.contains('+')) {
      return (min: int.parse(clean.replaceAll('+', '').trim()), max: null);
    }

    return (min: 1, max: null);
  }

  void incrementQty(int index, int? maxQty) {
    final current = _quantities[index] ?? 0;
    if (maxQty != null && current >= maxQty) return;

    final updated = current + 1;
    setState(() {
      _quantities[index] = updated;
      _qtyControllers[index]!.text = updated.toString();
    });
  }

  void decrementQty(int index, int minQty) {
    final current = _quantities[index] ?? 0;
    if (current <= minQty) return;

    final updated = current - 1;
    setState(() {
      _quantities[index] = updated;
      _qtyControllers[index]!.text = updated.toString();
    });
  }

  // ---------------- Lifecycle ----------------

  @override
  void initState() {
    super.initState();
    _fetchLiveRates(showLoader: true);
    _startAutoFetch();
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

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
          'Live Prices',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
            icon: const Icon(Icons.shopping_cart_checkout_sharp),
          ),
        ],
      ),
      drawer: DrawerWidget(),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _copperRate == null
            ? const Center(child: Text('No data available'))
            : SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _copperRate!['Slabs'].length,
                  itemBuilder: (context, index) {
                    final slab = _copperRate!['Slabs'][index];
                    final slabName = slab['SlabName'];
                    // Get min/max using helper
                    final limits = getQtyLimitsFromSlab(slabName);
                    final minQty = limits.min;
                    final maxQty = limits.max;
                    _qtyControllers.putIfAbsent(index, () {
                      _quantities[index] ??= minQty;
                      return TextEditingController(
                        text: _quantities[index].toString(),
                      );
                    });
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'COPPER PRICE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                          // Text(
                          //   "Last Updated: ${_lastUpdated != null ? DateFormat('HH:mm:ss').format(_lastUpdated!) : '--'}",
                          //   style: TextStyle(color: AppColors.white),
                          // ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Buy: ₹ ${slab['BuyPrice']}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Sell: ₹ ${slab['SellPrice']}',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Qty: $slabName',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'BUY',
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  onPressed: () async {
                                    final navigator = Navigator.of(context);
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    bool added = await _addToCart(
                                      index: index,
                                      slab: slab,
                                      slabName: slabName,
                                    );
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          added
                                              ? 'Added to cart'
                                              : 'Please select quantity',
                                        ),
                                      ),
                                    );
                                    if (added) {
                                      navigator.pushNamed(AppRoutes.cart);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomButton(
                                  text: 'SELL',
                                  backgroundColor: AppColors.greenDark,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 14,
                                  ),
                                  onPressed: () {
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'This Feature is Coming Soon...',
                                        ),
                                      ),
                                    );
                                    // final navigator = Navigator.of(context);
                                    // await _addToCart(
                                    //   index: index,
                                    //   slab: slab,
                                    //   slabName: slabName,
                                    // );
                                    // navigator.pushNamed(AppRoutes.cart);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _qtyControllers[index],
                                  readOnly: true,
                                  keyboardType: TextInputType.none,
                                  decoration: AppDecorations.textField(
                                    label: '',
                                    suffixIcon: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () =>
                                              incrementQty(index, maxQty),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 6,
                                              horizontal: 8,
                                            ),
                                            child: Icon(
                                              Icons.keyboard_arrow_up,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () =>
                                              decrementQty(index, minQty),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 6,
                                              horizontal: 8,
                                            ),
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Future<bool> _addToCart({
    required int index,
    required Map slab,
    required String slabName,
  }) async {
    final int unitQty = _quantities[index] ?? 0;

    if (unitQty <= 0) {
      return false;
    }

    try {
      final limits = getQtyLimitsFromSlab(slabName);
      final minQty = limits.min;
      final maxQty = limits.max;

      final double totalKg = unitQty.toDouble();
      final double buyPrice = double.parse(slab['BuyPrice'].toString());
      final double sellPrice = double.parse(slab['SellPrice'].toString());

      final int slabId = slab['Id'];
      final userId = await AuthStorage.getUserId();
      if (userId == null) {
        return false;
      }

      /// ADD TO CART API
      final apiResult = await apiService.addToCart(
        userId: userId,
        slabName: slabName,
        pricePerKg: buyPrice,
        qty: unitQty,
        minWeight: minQty,
        maxWeight: maxQty ?? unitQty,
      );
      debugPrint("ADD TO CART API RESULT: $apiResult");
      if (apiResult['success'] != true) {
        return false;
      }

      final cartItem = CartItemModel(
        slabId: slabId,
        slab: slabName,
        buyPrice: buyPrice,
        sellPrice: sellPrice,
        qty: totalKg,
        amount: buyPrice * totalKg,
        createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      );
      // DEBUG PRINT START
      // debugPrint('------------ ADD TO CART DEBUG ------------');
      // debugPrint('Slab ID: $slabId');
      // debugPrint('Slab Name: $slabName');
      // debugPrint('Unit Qty: $unitQty');
      // debugPrint('Total KG: $totalKg');
      // debugPrint('Buy Price: $buyPrice');
      // debugPrint('Final Amount: ${buyPrice * totalKg}');
      // debugPrint('Cart Map: ${cartItem.toMap()}');
      // debugPrint('-------------------------------------------');
      // DEBUG PRINT END
      await CartDatabaseService.instance.insertOrUpdate(cartItem);
      // final items = await CartDatabaseService.instance.getCartItems();
      // debugPrint('---- FULL CART AFTER INSERT ----');
      // for (var item in items) {
      //   debugPrint(item.toMap().toString());
      // }
      // debugPrint('--------------------------------');
      return true;
    } catch (e) {
      // debugPrint('Add to cart error: $e');
      return false;
    }
  }
}
