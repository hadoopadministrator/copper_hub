import 'dart:async';
import 'package:flutter/material.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:copper_hub/widgets/drawer_widget.dart';
import 'package:intl/intl.dart';

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
  DateTime? _lastUpdated;

  // ---------------- API ----------------

  Future<void> _fetchLiveRates({bool showLoader = false}) async {
    if (showLoader && mounted) {
      setState(() => _isLoading = true);
    }

    final result = await apiService.getLiveCopperRate();

    if (result['success'] == true) {
      setState(() {
        _copperRate = result['data'];
        _isLoading = false;
        _lastUpdated = DateTime.now();
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
    _fetchTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _fetchLiveRates();
    });
  }

  // ================= NEW HELPER =================
  double getUnitWeight(String slabName) {
    final clean = slabName.toUpperCase();

    if (clean.startsWith('0.25')) return 0.25;
    if (clean.startsWith('0.5')) return 0.5;

    return 1.0; // 1KG slabs
  }

  // ---------------- Quantity helpers ----------------

  ({int min, int? max}) getQtyLimitsFromSlab(String slabName) {
    final clean = slabName.toUpperCase().replaceAll('KG', '').trim();

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
      appBar: AppBar(
        title: const Text('Live Prices'),
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
                          /// HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'COPPER PRICE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                "Last Updated: ${_lastUpdated != null ? DateFormat('HH:mm:a').format(_lastUpdated!) : '--'}",
                                style: TextStyle(
                                  color: AppColors.white.withValues(alpha: 0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          /// PRICE ROW
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Buy",
                                      style: TextStyle(
                                        color: AppColors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹ ${slab['BuyPrice']}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Sell",
                                      style: TextStyle(
                                        color: AppColors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹ ${slab['SellPrice']}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Qty",
                                      style: TextStyle(
                                        color: AppColors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$slabName',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Expanded(
                              //   child: Text(
                              //     'Qty: $slabName',
                              //     style: TextStyle(
                              //       fontSize: 13,
                              //       color: AppColors.white,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          /// ACTION ROW
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
                                    final result = await _addToCart(
                                      index: index,
                                      slab: slab,
                                      slabName: slabName,
                                    );
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(result['message']),
                                      ),
                                    );
                                    if (result['success'] == true) {
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
                                  onPressed: () async {
                                    final navigator = Navigator.of(context);
                                    final messenger = ScaffoldMessenger.of(
                                      context,
                                    );

                                    final slabId = slab['Id'];
                                    final userId =
                                        await AuthStorage.getUserId();

                                    if (userId == null || slabId == null) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text("Please login first"),
                                        ),
                                      );
                                      return;
                                    }

                                    final result = await apiService.canUserSell(
                                      userId: userId,
                                      slabId: slabId,
                                    );

                                    if (!mounted) return;

                                    if (result['success'] == true) {
                                      final remainingQty =
                                          (result['remainingQty'] ?? 0);
                                      if (remainingQty <= 0) {
                                        messenger.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "You don't have any quantity to sell in this slab",
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      navigator.pushNamed(
                                        AppRoutes.sellCheckOut,
                                        arguments: {
                                          'userId': userId,
                                          'slabId': slabId,
                                        },
                                      );
                                    } else {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(result['message']),
                                        ),
                                      );
                                    }
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

  Future<Map<String, dynamic>> _addToCart({
    required int index,
    required Map slab,
    required String slabName,
  }) async {
    final int unitQty = _quantities[index] ?? 0;

    if (unitQty <= 0) {
      return {'success': false, 'message': 'Please select quantity'};
    }

    try {
      // ================= API DATA (DIRECT) =================
      final double minWeight = double.parse(slab['MinWeight'].toString());

      final double maxWeight = double.parse(slab['MaxWeight'].toString());

      final double buyPrice = double.parse(slab['BuyPrice'].toString());

      final int slabId = slab['Id'];

      final userId = await AuthStorage.getUserId();
      if (userId == null) {
        return {'success': false, 'message': 'User not logged in'};
      }

      /// ADD TO CART API
      final apiResult = await apiService.addToCart(
        userId: userId,
        slabId: slabId,
        slabName: slabName,
        pricePerKg: buyPrice,
        qty: unitQty.toDouble(),
        minWeight: minWeight,
        maxWeight: maxWeight,
      );

      if (apiResult['success'] != true) {
        return {'success': false, 'message': 'Something went wrong'};
      }

      return {
        'success': true,
        'message': apiResult['message'] ?? 'Added to cart',
      };
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }
}
