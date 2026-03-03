import 'package:flutter/material.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/utils/app_colors.dart';

class HoldingsScreen extends StatefulWidget {
  const HoldingsScreen({super.key});

  @override
  State<HoldingsScreen> createState() => _HoldingsScreenState();
}

class _HoldingsScreenState extends State<HoldingsScreen> {
  bool isLoading = true;

  double totalBought = 0;
  double totalSold = 0;
  double remainingQty = 60;
  double avgBuyPrice = 720;
  double currentRate = 750;
  double currentValue = 0;

  @override
  void initState() {
    super.initState();
    fetchHoldings();
  }

  Future<void> fetchHoldings() async {
    final userId = await AuthStorage.getUserId();

    if (userId == null) return;

    // final result = await ApiService().getUserHoldings(userId: userId);

    if (!mounted) return;

    // if (result["success"] == true) {
    //   final data = result["data"];

    //   setState(() {
    //     totalBought = (data["totalBought"] ?? 0).toDouble();
    //     totalSold = (data["totalSold"] ?? 0).toDouble();
    //     remainingQty = (data["remainingQty"] ?? 0).toDouble();
    //     avgBuyPrice = (data["avgBuyPrice"] ?? 0).toDouble();
    //     currentRate = (data["currentRate"] ?? 0).toDouble();
    //     currentValue = (data["currentValue"] ?? 0).toDouble();
    //     isLoading = false;
    //   });
    // } else {
    //   setState(() => isLoading = false);
    // }
  }

  double get profitLoss => (currentRate - avgBuyPrice) * remainingQty;
  bool get isProfit => profitLoss >= 0;

  Widget buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
         /// REMAINING
          const Text(
            "Remaining Copper",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 4),

          Text(
            "$remainingQty KG",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          buildRow(
            "Average Buy Price",
            "₹${avgBuyPrice.toStringAsFixed(2)} / KG",
            AppColors.black,
          ),

          const SizedBox(height: 12),

          buildRow(
            "Current Price",
            "₹${currentRate.toStringAsFixed(2)} / KG",
            AppColors.black,
          ),

          const Divider(height: 30),

          buildRow(
            "Current Value",
            "₹${currentValue.toStringAsFixed(2)}",
            AppColors.greenDark,
            isBold: true,
          ),

          const SizedBox(height: 12),

          buildProfitLossRow(),
        ],
      ),
    );
  }
   Widget buildProfitLossRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        const Text(
          "Unrealized P/L",
          style: TextStyle(fontSize: 16),
        ),

        Row(
          children: [
            Icon(
              isProfit
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: isProfit ? AppColors.greenLight : Colors.red,
              size: 18,
            ),

            const SizedBox(width: 4),

            Text(
              "${isProfit ? "+" : "-"}₹${profitLoss.abs().toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isProfit ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildRow(
    String title,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),

        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "My Holdings",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),

      body:
          // isLoading
          //     ? const Center(child: CircularProgressIndicator())
          //     : remainingQty <= 0
          //     ? buildEmpty()
          //     :
          Padding(padding: const EdgeInsets.all(16), child: buildSummaryCard()),
    );
  }
}
