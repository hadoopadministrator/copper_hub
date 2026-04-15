import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/utils/app_colors.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          /// HEADER
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.white),
            child: Center(
              child: Image.asset('assets/logo/logo.png', height: 80),
            ),
          ),

          /// HOME / LIVE PRICES
          _tile(
            context,
            icon: Icons.show_chart_rounded,
            title: 'Live Prices',
            color: AppColors.orangeDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.liveRates,
                (route) => false,
              );
            },
          ),

          /// MY HOLDINGS
          _tile(
            context,
            icon: Icons.account_balance_wallet_rounded,
            title: 'My Holdings',
            color: AppColors.greenDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.myHoldings);
            },
          ),

          /// ORDER HISTORY
          _tile(
            context,
            icon: Icons.receipt_long_rounded,
            title: 'Order History',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.orderHistory);
            },
          ),

          /// PROFILE
          _tile(
            context,
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
          const Divider(),

          /// VISIT WEBSITE
          _tile(
            context,
            icon: Icons.language_rounded,
            title: 'Visit Website',
            onTap: () => _openUrl(
              context,
              "https://wealthbridgeimpex.com/",
              "Could not open website",
            ),
          ),

          /// CONTACT US
          _tile(
            context,
            icon: Icons.support_agent_rounded,
            title: 'Contact Us',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.contactUs);
            },
          ),

          /// ABOUT US
          _tile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'About Us',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.aboutUs);
            },
          ),

          /// PRIVACY POLICY
          _tile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _openUrl(
              context,
              "https://wealthbridgeimpex.com/privacy_policy.html",
              "Could not open privacy policy",
            ),
          ),

          const Divider(),

          /// SHARE APP
          _tile(
            context,
            icon: Icons.share_outlined,
            title: 'Share App',
            onTap: () async {
              Navigator.pop(context);

              const url =
                  "https://play.google.com/store/apps/details?id=com.infisoft.copperhub";

              await SharePlus.instance.share(
                ShareParams(
                  text: "Download Copper Hub App:\n$url",
                  subject: "Copper Hub App",
                ),
              );
            },
          ),

          /// RATE APP
          _tile(
            context,
            icon: Icons.star_border_rounded,
            title: 'Rate App',
            onTap: () => _openUrl(
              context,
              "https://play.google.com/store/apps/details?id=com.infisoft.copperhub",
              "Could not open Play Store",
            ),
          ),

          const Divider(),

          /// LOGOUT
          _tile(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            color: AppColors.red,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  /// Reusable Tile
  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: onTap,
    );
  }

  /// URL OPENER
  static Future<void> _openUrl(
    BuildContext context,
    String link,
    String error,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);

    final Uri url = Uri.parse(link);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  /// LOGOUT
  static Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    final confirm = await showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthStorage.logout();

    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }
}
