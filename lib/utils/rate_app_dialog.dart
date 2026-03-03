import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RateAppDialog {
  static const String _playStoreUrl =
      "https://play.google.com/store/apps/details?id=com.infisoft.copperhub";

  static Future<void> show(BuildContext context) async {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Enjoying Copper Hub?"),
          content: const Text(
            "Please take a moment to rate our app. Your feedback helps us improve.",
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.orangeDark,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Later"),
            ),
            CustomButton(
              width: double.infinity,
              text: "Rate Now",
              onPressed: () async {
                Navigator.pop(dialogContext);
                final Uri url = Uri.parse(_playStoreUrl);
                try {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                } catch (_) {}
              },
            ),
          ],
        );
      },
    );
  }
}
