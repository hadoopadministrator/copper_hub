import 'package:flutter/material.dart';
import 'package:copper_hub/utils/app_colors.dart';

class OrderCard extends StatelessWidget {
  final String date;
  final String slab;
  final String type;
  final String quantity;
  final String total;
  final String status;

  const OrderCard({
    super.key,
    required this.date,
    required this.slab,
    required this.type,
    required this.quantity,
    required this.total,
    required this.status,
  });

  bool get isBuy => type.toLowerCase() == "buy";
  bool get isPaid => status.toLowerCase() == "paid";

  @override
  Widget build(BuildContext context) {
    final Color primaryColor =
        isBuy ? AppColors.orangeDark : AppColors.greenDark;

    final Color lightColor =
        isBuy ? AppColors.orangeLight : AppColors.greenLight;

    final IconData typeIcon =
        isBuy ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightColor.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(typeIcon, color: primaryColor, size: 20),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBuy ? "Copper Bought" : "Copper Sold",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? AppColors.greenLight.withValues(alpha: 0.25)
                        : AppColors.orangeLight.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isPaid
                          ? AppColors.greenDark
                          : AppColors.orangeDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BuildItem(title: "Slab", value: slab),
                BuildItem(title: "Qty", value: quantity),
                BuildItem(title: "Total", value: total, isAmount: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BuildItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isAmount;

  const BuildItem({
    super.key,
    required this.title,
    required this.value,
    this.isAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isAmount ? 16 : 15,
            fontWeight: FontWeight.w700,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }
}
