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

  /// FLATTENED LIST (IMPORTANT)
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
      final List data = result['data'];

      List<Map<String, dynamic>> flattened = [];

      for (var order in data) {
        final items = order["Items"] ?? [];

        for (var item in items) {
          flattened.add({
            ...item,
            "OrderId": order["OrderId"],
            "OrderDateTime": order["OrderDateTime"],
            "PaymentStatus": order["PaymentStatus"],
          });
        }
      }

      setState(() {
        orders = flattened;
        isLoading = false;
      });
    } else {
      setState(() {
        orders = [];
        isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Failed')));
    }
  }

  List<Map<String, dynamic>> get filteredOrders {
    return orders.where((order) {
      final type = (order["Type"] ?? "").toString().toUpperCase();
      return selectedTab == 0 ? type == "BUY" : type == "SELL";
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order History")),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  buildTabs(),
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
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 0),
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
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 1),
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

  Widget buildOrderList() {
    if (filteredOrders.isEmpty) {
      return const Center(child: Text("No Data"));
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
              arguments: {
                'orderId': order["OrderId"],
                'itemId': order["ItemId"],
              },
            );
          },
          child: OrderCard(
            date: order["OrderDateTime"] ?? "",
            slab: order["Slab"] ?? "",
            type: order["Type"] ?? "",
            quantity: order["Qty"].toString(),
            total: "₹${order["Total"]}",
            status: order["PaymentStatus"] ?? "",
          ),
        );
      },
    );
  }
}
