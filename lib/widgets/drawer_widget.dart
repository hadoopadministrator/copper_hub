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
      backgroundColor: AppColors.background,
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
          ListTile(
            leading: const Icon(
              Icons.show_chart_rounded,
              color: AppColors.orangeDark,
            ),
            title: const Text('Live Prices', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.liveRates,
                (route) => false,
              );
            },
          ),

          /// MY HOLDINGS (NEW)
          ListTile(
            leading: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.greenDark,
            ),
            title: const Text('My Holdings', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppRoutes.myHoldings,
              );
            },
          ),

          /// ORDER HISTORY
          ListTile(
            leading: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.black,
            ),
            title: const Text('Order History', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.orderHistory);
            },
          ),

          /// PROFILE
          ListTile(
            leading: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.black,
            ),
            title: const Text('Profile', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),

          const Divider(),

          /// VISIT WEBSITE
          ListTile(
            leading: const Icon(Icons.language_rounded, color: AppColors.black),
            title: const Text('Visit Website', style: TextStyle(fontSize: 18)),
            onTap: () => _openUrl(
              context,
              "https://wealthbridgeimpex.com/",
              "Could not open website",
            ),
          ),

          /// CONTACT US
          ListTile(
            leading: const Icon(
              Icons.support_agent_rounded,
              color: AppColors.black,
            ),
            title: const Text('Contact Us', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.contactUs);
            },
          ),

          /// ABOUT US
          ListTile(
            leading: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.black,
            ),
            title: const Text('About Us', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.aboutUs);
            },
          ),

          /// PRIVACY POLICY
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.black,
            ),
            title: const Text('Privacy Policy', style: TextStyle(fontSize: 18)),
            onTap: () => _openUrl(
              context,
              "https://wealthbridgeimpex.com/privacy_policy.html",
              "Could not open privacy policy",
            ),
          ),

          const Divider(),

          /// SHARE APP
          ListTile(
            leading: const Icon(Icons.share_outlined, color: AppColors.black),
            title: const Text('Share App', style: TextStyle(fontSize: 18)),
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
          ListTile(
            leading: const Icon(
              Icons.star_border_rounded,
              color: AppColors.black,
            ),
            title: const Text('Rate App', style: TextStyle(fontSize: 18)),
            onTap: () => _openUrl(
              context,
              "https://play.google.com/store/apps/details?id=com.infisoft.copperhub",
              "Could not open Play Store",
            ),
          ),

          const Divider(),

          /// LOGOUT
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
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
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthStorage.logout();

    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }
}
