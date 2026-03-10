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
                foregroundColor: AppColors.orangeLight,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Later", style: TextStyle(fontSize: 18)),
            ),
            CustomButton(
              text: "Rate Now",
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
