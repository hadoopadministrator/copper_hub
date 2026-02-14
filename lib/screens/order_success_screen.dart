import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/routes/app_routes.dart';
import 'package:wealth_bridge_impex/utils/app_colors.dart';
import 'package:wealth_bridge_impex/widgets/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                child: const Icon(Icons.check, color: AppColors.white, size: 60),
              ),

              const SizedBox(height: 24),

              /// TITLE
              const Text(
                "Order Placed Successfully",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              /// MESSAGE
              const Text(
                "Your copper order has been placed successfully.\nYou can track it from Order History.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              /// ACTION BUTTONS
              CustomButton(
                width: double.infinity,
                text: "View Order History",
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.orderHistory,
                    (route) => route.settings.name == AppRoutes.liveRates,
                  );
                },
              ),
              
              const SizedBox(height: 12),

              CustomButton(
                width: double.infinity,
                text: "Back to Home",
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
