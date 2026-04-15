import 'package:copper_hub/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch phone dialer');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch email app');
    }
  }

  Future<void> _launchMap(String address) async {
    final Uri uri = Uri.parse(
      "https://www.google.com/maps?q=${Uri.encodeComponent(address)}",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not open map');
    }
  }

  @override
  Widget build(BuildContext context) {
    const address = "856 Cordia Extension Apt. 356, Lake, United State";
    const email = "info.colorlib@gmail.com";
    const phone = "1234567890";
    return Scaffold(
      appBar: AppBar(title: const Text("About Us")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric( vertical: 30),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.location_on,
                    label: "Our Address",
                    value: address,
                    onTap: () => _launchMap(address),
                  ),
                  const SizedBox(height: 20),
                  InfoRow(
                    icon: Icons.email,
                    label: "Email Address",
                    value: email,
                    onTap: () => _launchEmail(email),
                  ),
                  const SizedBox(height: 20),
                  InfoRow(
                    icon: Icons.phone,
                    label: "Phone",
                    value: phone,
                    onTap: () => _launchPhone(phone),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppColors.orangeDark.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.orangeDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: textTheme.bodySmall),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
