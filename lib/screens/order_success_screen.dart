import 'package:copper_hub/utils/rate_app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/widgets/custom_button.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  String type = "BUY";
  double? qty;
  double? price;
  // String? orderId;

  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadArguments();
    _showRateDialogOnce();
  }

  void _loadArguments() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) return;

    type = args['type']?.toString() ?? "BUY";
    qty = (args['qty'] as num?)?.toDouble() ?? 0;
    price = (args['price'] as num?)?.toDouble() ?? 0;
    // orderId = args['orderId'] as String?;
  }

  void _showRateDialogOnce() {
    if (_dialogShown) return;

    _dialogShown = true;

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        RateAppDialog.show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSell = type == "SELL";

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// SUCCESS ICON
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 60,
                ),
              ),

              const SizedBox(height: 24),

              /// TITLE
              Text(
                isSell
                    ? "Sell Order Placed Successfully"
                    : "Buy Order Placed Successfully",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              /// ORDER ID
              // if (orderId != null)
              //   Column(
              //     children: [
              //       Text(
              //         "Order ID: $orderId",
              //         style: const TextStyle(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //       const SizedBox(height: 8),
              //     ],
              //   ),

              /// DETAILS
              if (qty != null && price != null)
                Column(
                  children: [
                    Text(
                      "Quantity: ${qty!.toStringAsFixed(2)} KG",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total Amount: ₹${price!.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),

              /// MESSAGE
              Text(
                isSell
                    ? "Your sell order is successful. Amount will be credited to your account shortly."
                    : "Your buy order is successful. You can track delivery in Order History.",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              /// ORDER HISTORY BUTTON
              CustomButton(
                width: double.infinity,
                text: "View Order History",
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.orderHistory,
                  );
                },
              ),

              const SizedBox(height: 12),

              /// HOME BUTTON
              CustomButton(
                width: double.infinity,
                text: "Back to Home",
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.liveRates,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
