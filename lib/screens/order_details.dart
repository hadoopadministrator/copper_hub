import 'package:flutter/material.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/utils/app_colors.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool isLoading = true;
  bool shipmentLoading = true;

  Map<String, dynamic>? order;
  Map<String, dynamic>? item;

  List<Map<String, dynamic>> shipments = [];

  String? error;
  int? orderId;
  int? itemId;

  bool _isInitialized = false;

  final ApiService _apiService = ApiService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    _isInitialized = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    orderId = args?['orderId'];
    itemId = args?['itemId'];

    if (orderId != null) {
      fetchOrderDetails();
      fetchShipments();
    }
  }

  Future<void> fetchOrderDetails() async {
    try {
      final result = await _apiService.getOrderById(orderId: orderId!);

      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'];
        final items = List<Map<String, dynamic>>.from(data["Items"] ?? []);

        ///
        final selectedItem = items.firstWhere(
          (i) => i["ItemId"] == itemId,
          orElse: () => items.isNotEmpty ? items[0] : {},
        );

        setState(() {
          order = data;
          item = selectedItem;
          isLoading = false;
        });
      } else {
        setState(() {
          error = result['message'] ?? 'Failed to fetch order details';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Something went wrong';
        isLoading = false;
      });
    }
  }

  Future<void> fetchShipments() async {
    try {
      final userId = await AuthStorage.getUserId();

      if (userId == null || orderId == null) {
        setState(() {
          shipmentLoading = false;
        });
        return;
      }

      final result = await _apiService.getShipments(userId: userId);

      if (!mounted) return;

      if (result['success'] == true) {
        final allShipments = List<Map<String, dynamic>>.from(
          result['data'] ?? [],
        );

        final filteredShipments = allShipments.where((shipment) {
          return shipment['order_id'] == orderId;
        }).toList();

        setState(() {
          shipments = filteredShipments;
          shipmentLoading = false;
        });
      } else {
        setState(() {
          shipmentLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        shipmentLoading = false;
      });
    }
  }

  Widget sectionCard({required String title, required List<Widget> children}) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget buildRow(
    String label,
    String value, {
    Color? valueColor,
    bool isMultiline = false,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: valueColor != null
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color getShipmentStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "DELIVERED":
        return AppColors.greenDark;
      case "SHIPPED":
      case "IN_TRANSIT":
        return AppColors.orangeDark;
      case "AWB_CREATED":
        return AppColors.orangeLight;
      case "AWB_FAILED":
        return AppColors.red;
      default:
        return AppColors.orangeLight;
    }
  }

  Widget buildShipmentSection() {
    if (shipmentLoading) {
      return sectionCard(
        title: "Shipment Details",
        children: const [
          SizedBox(height: 20),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (shipments.isEmpty) {
      return sectionCard(
        title: "Shipment Details",
        children: const [Text("No shipment information available")],
      );
    }

    return sectionCard(
      title: "Shipment Details",
      children: shipments.map((shipment) {
        final status = shipment["status"] ?? "";
        return Column(
          children: [
            buildRow("Part No", shipment["part_no"].toString()),
            buildRow("Weight", "${shipment["weight"]} KG"),
            buildRow(
              "Status",
              status,
              valueColor: getShipmentStatusColor(status),
            ),
            buildRow("Courier", shipment["courier_name"] ?? "-"),
            buildRow("AWB", shipment["awb"] ?? "-"),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
                child: Text(
                  error!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.red),
                ),
              )
            : ListView(
               padding: const EdgeInsets.all(16),
                children: [
                  /// ORDER INFO (USING ITEM)
                  sectionCard(
                    title: "Order Info",
                    children: [
                      buildRow("Slab", item?["Slab"] ?? ""),
                      buildRow("Type", item?["Type"] ?? ""),
                      buildRow("Quantity", item?["Qty"]?.toString() ?? ""),
                      buildRow(
                        "Price per KG",
                        "₹${item?["PricePerKg"]?.toString() ?? "0"}",
                      ),
                      buildRow(
                        "Total",
                        "₹${item?["Total"]?.toString() ?? "0"}",
                        valueColor: AppColors.orangeDark,
                      ),

                      if (item?["Type"] == "SELL")
                        buildRow(
                          "Remaining Qty",
                          item?["RemainingQty"]?.toString() ?? "",
                        ),
                    ],
                  ),

                  /// PAYMENT INFO (ORDER LEVEL)
                  sectionCard(
                    title: "Payment Info",
                    children: [
                      buildRow("GST", "₹${item?["Gst"]?.toString() ?? "0"}"),
                      buildRow(
                        "Courier",
                        "₹${item?["Courier"]?.toString() ?? "0"}",
                      ),
                      buildRow(
                        "Payment Status",
                        order?["PaymentStatus"] ?? "",
                        valueColor: order?["PaymentStatus"] == "Paid"
                            ? AppColors.greenDark
                            : AppColors.red,
                      ),
                      buildRow(
                        "Razorpay ID",
                        order?["RazorpayPaymentId"] ?? "",
                        isMultiline: true,
                      ),
                    ],
                  ),

                  /// DELIVERY INFO
                  sectionCard(
                    title: "Delivery Info",
                    children: [
                      buildRow(
                        "Delivery Option",
                        order?["DeliveryOption"] ?? "",
                      ),
                      buildRow(
                        "Address",
                        order?["Address"] ?? "",
                        isMultiline: true,
                      ),
                      buildRow("Order Date", order?["OrderDateTime"] ?? ""),
                    ],
                  ),

                  /// SHIPMENT SAME
                  buildShipmentSection(),
                ],
              ),
      ),
    );
  }
}
