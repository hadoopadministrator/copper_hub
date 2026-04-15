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
          title: const Text("Enjoying Copper Hub?"),
          content: const Text(
            "Please take a moment to rate our app. Your feedback helps us improve.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Later"),
            ),
            CustomButton(
              text: "Rate Now",
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
