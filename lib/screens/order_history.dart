import 'package:flutter/material.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/widgets/order_card.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  int selectedTab = 0;
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final userId = await AuthStorage.getUserId();
    if (userId == null) return;

    final result = await ApiService().getOrdersByUser(userId: userId);
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        // Convert dynamic list to Map<String, dynamic>
        orders = (result['data'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        orders = [];
        isLoading = false;
      });
      // Optionally show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to fetch orders')),
      );
    }
  }

  /// FILTERED LIST
  List<Map<String, dynamic>> get filteredOrders {
    return orders.where((order) {
      final type = (order["Type"] ?? "").toString().trim().toUpperCase();
      return selectedTab == 0 ? type == "BUY" : type == "SELL";
    }).toList();
  }

  /// MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order History")),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  /// BUY / SELL SWITCH
                  buildTabs(),

                  /// LIST
                  Expanded(child: buildOrderList()),
                ],
              ),
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
                      color: selectedTab == 0
                          ? AppColors.white
                          : AppColors.black,
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
                      color: selectedTab == 1
                          ? AppColors.white
                          : AppColors.black,
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

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.orderDetails,
              arguments: {'orderId': order["Id"]},
            );
          },
          child: OrderCard(
            date: order["OrderDateTime"] ?? "",
            slab: order["Slab"] ?? "",
            type: order["Type"] ?? "",
            quantity: order["Qty"]?.toString() ?? "",
            total: "₹${(order["Total"] as num?)?.toDouble().toStringAsFixed(2) ?? "0.00"}",
            status: order["PaymentStatus"] ?? "",
          ),
        );
      },
    );
  }
}
