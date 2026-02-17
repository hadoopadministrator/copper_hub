import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/services/api_service.dart';
import 'package:wealth_bridge_impex/services/auth_storage.dart';
import 'package:wealth_bridge_impex/utils/app_colors.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({super.key});

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool isLoading = true;
  bool shipmentLoading = true;

  Map<String, dynamic>? order;
  List<Map<String, dynamic>> shipments = [];

  String? error;
  int? orderId;

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

    if (orderId != null) {
      fetchOrderDetails();
      fetchShipments();
    }
  }

  Future<void> fetchOrderDetails() async {
    // if (orderId == null) return;
    try {
      final result = await _apiService.getOrderById(orderId: orderId!);
      if (!mounted) return;
      if (result['success'] == true) {
        setState(() {
          order = result['data'];
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

        // FILTER ONLY CURRENT ORDER SHIPMENTS
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
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor ?? AppColors.black,
                fontWeight: valueColor != null ? FontWeight.bold : null,
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
       return Colors.red;
       
      case "PENDING":
      default:
        return AppColors.orangeLight;
    }
  }

  Widget buildShipmentSection() {
    if (shipmentLoading) {
      return sectionCard(
        title: "Shipment Details",
        children: const [Center(child: CircularProgressIndicator())],
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
            const Divider(),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text(
          "Order Details",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
                child: Text(
                  error!,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ListView(
                  children: [
                    // Order Info Section
                    sectionCard(
                      title: "Order Info",
                      children: [
                        buildRow("Slab", order?["Slab"] ?? ""),
                        buildRow("Type", order?["Type"] ?? ""),
                        buildRow("Quantity", order?["Qty"]?.toString() ?? ""),
                        buildRow(
                          "Price per KG",
                          "₹${order?["PricePerKg"]?.toStringAsFixed(2) ?? "0"}",
                        ),
                        buildRow(
                          "Total",
                          "₹${order?["Total"]?.toStringAsFixed(2) ?? "0"}",
                          valueColor: AppColors.orangeDark,
                        ),
                      ],
                    ),

                    // Payment Info Section
                    sectionCard(
                      title: "Payment Info",
                      children: [
                        buildRow(
                          "GST",
                          "₹${order?["Gst"]?.toStringAsFixed(2) ?? "0"}",
                        ),
                        buildRow(
                          "Courier",
                          "₹${order?["Courier"]?.toStringAsFixed(2) ?? "0"}",
                        ),
                        buildRow(
                          "Payment Status",
                          order?["PaymentStatus"] ?? "",
                          valueColor: order?["PaymentStatus"] == "Paid"
                              ? Colors.green
                              : Colors.red,
                        ),
                        buildRow(
                          "Razorpay ID",
                          order?["RazorpayPaymentId"] ?? "",
                          isMultiline: true,
                        ),
                      ],
                    ),

                    // Delivery Info Section
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

                    /// SHIPMENT INFO
                    buildShipmentSection(),
                  ],
                ),
              ),
      ),
    );
  }
}
