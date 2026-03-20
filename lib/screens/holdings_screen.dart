import 'package:copper_hub/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:intl/intl.dart';

class HoldingsScreen extends StatefulWidget {
  const HoldingsScreen({super.key});

  @override
  State<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> holdings = [];
  final apiService = ApiService();
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    fetchHoldings();
  }

  Future<void> fetchHoldings() async {
    final userId = await AuthStorage.getUserId();

    if (userId == null) return;

    final result = await apiService.getUserHoldings(userId: userId);

    if (!mounted) return;

    if (result["success"] == true) {
      final data = List<Map<String, dynamic>>.from(result["data"] ?? []);
      setState(() {
        holdings = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

 Widget buildHoldingCard(Map<String, dynamic> holding) {
  final remainingQty = (holding['RemainingQty'] as num?)?.toDouble() ?? 0;
  final avgBuyPrice = (holding['BuyPricePerKg'] as num?)?.toDouble() ?? 0;
  final currentRate = (holding['CurrentRate'] as num?)?.toDouble() ?? 0;
  final currentValue = (holding['CurrentValue'] as num?)?.toDouble() ?? 0;
  final investedAmount = (holding['InvestedAmount'] as num?)?.toDouble() ?? 0;

  final profitLoss = (holding['ProfitLoss'] as num?)?.toDouble() ??
      (currentRate - avgBuyPrice) * remainingQty;

  final profit = profitLoss >= 0;

  return Container(
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          holding['SlabName'] ?? 'N/A',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        buildRow("Bought Quantity", "${holding['BoughtQty'] ?? 0} KG"),
        buildRow("Sold Quantity", "${holding['SoldQty'] ?? 0} KG"),
        buildRow("Remaining Quantity", "$remainingQty KG"),

        buildRow(
          "Average Buy Price",
          "${currencyFormat.format(avgBuyPrice)} / KG",
        ),
        buildRow(
          "Current Price",
          "${currencyFormat.format(currentRate)} / KG",
        ),

        buildRow("Invested Amount", currencyFormat.format(investedAmount)),
        buildRow("Current Value", currencyFormat.format(currentValue)),

        const Divider(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Unrealized P/L", style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Icon(
                  profit
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: profit ? AppColors.greenLight : Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "${profit ? "+" : "-"}${currencyFormat.format(profitLoss.abs())}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: profit ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}


  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget buildEmpty() {
    return const Center(
      child: Text("No holdings yet", style: TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Holdings")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : holdings.isEmpty
          ? buildEmpty()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: holdings.length,
                itemBuilder: (context, index) =>
                    buildHoldingCard(holdings[index]),
              ),
            ),
    );
  }
}
