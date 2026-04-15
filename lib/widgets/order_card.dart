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
    final textTheme = Theme.of(context).textTheme;
    final Color primaryColor =
        isBuy ? AppColors.orangeDark : AppColors.greenDark;

    final Color lightColor =
        isBuy ? AppColors.orangeLight : AppColors.greenLight;

    final IconData typeIcon =
        isBuy ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightColor.withValues(alpha: 0.2),
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
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? AppColors.greenLight.withValues(alpha: 0.2)
                        : AppColors.orangeLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isPaid
                          ? AppColors.greenDark
                          : AppColors.orangeDark,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

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
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
