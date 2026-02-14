import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/utils/app_colors.dart';
import 'package:wealth_bridge_impex/widgets/order_card.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  int selectedTab = 0; // 0 = Buy, 1 = Sell

  /// STATIC DATA (replace later with API)
  final List<Map<String, String>> orders = [
    {
      "date": "21/01/26",
      "slab": "0.50 kg",
      "type": "Buy",
      "quantity": "3",
      "total": "₹16,680",
      "status": "Paid",
    },
    {
      "date": "22/01/26",
      "slab": "0.50 kg",
      "type": "Sell",
      "quantity": "2",
      "total": "₹27,900",
      "status": "Completed",
    },
    {
      "date": "24/01/26",
      "slab": "1 kg",
      "type": "Buy",
      "quantity": "5",
      "total": "₹27,800",
      "status": "Paid",
    },
  ];

  /// FILTERED LIST
  List<Map<String, String>> get filteredOrders {
    return orders.where((order) {
      if (selectedTab == 0) {
        return order["type"] == "Buy";
      } else {
        return order["type"] == "Sell";
      }
    }).toList();
  }

  /// MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text(
          "Order History",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// BUY / SELL SWITCH
            buildTabs(),

            /// LIST
            Expanded(child: buildOrderList()),
          ],
        ),

        // ListView.builder(
        //   padding: const EdgeInsets.all(16),
        //   itemCount: orders.length,
        //   itemBuilder: (context,s index) {
        //     final order = orders[index];
        //     return OrderCard(
        //       date: order["date"]!,
        //       slab: order["slab"]!,
        //       type: order["type"]!,
        //       quantity: order["quantity"]!,
        //       total: order["total"]!,
        //       status: order["status"]!,
        //     );
        //   },
        // ),
      ),
    );
  }

  Widget buildTabs() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          /// BUY TAB
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == 0
                      ? AppColors.orangeDark
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "BUY",
                    style: TextStyle(
                      color: selectedTab == 0 ? AppColors.white : AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// SELL TAB
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == 1
                      ? AppColors.greenDark
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "SELL",
                    style: TextStyle(
                      color: selectedTab == 1 ? AppColors.white : AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// EMPTY STATE
  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            selectedTab == 0 ? "No Copper Bought Yet" : "No Copper Sold Yet",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// ORDER LIST
  Widget buildOrderList() {
    if (filteredOrders.isEmpty) {
      return buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];

        return OrderCard(
          date: order["date"]!,
          slab: order["slab"]!,
          type: order["type"]!,
          quantity: order["quantity"]!,
          total: order["total"]!,
          status: order["status"]!,
        );
      },
    );
  }
}
