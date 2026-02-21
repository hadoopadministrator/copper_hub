import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/utils/app_colors.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
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
            child: Image.asset('assets/logo/logo.png', fit: BoxFit.contain),
          ),

          /// LIVE PRICES (HOME)
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.black),
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

          /// PROFILE
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.black),
            title: const Text('Profile', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),

          /// ORDER HISTORY
          ListTile(
            leading: const Icon(Icons.history, color: AppColors.black),
            title: const Text('Order History', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.pushNamed(context, AppRoutes.orderHistory);
            },
          ),
          const Divider(),

          /// VISIT WEBSITE
          ListTile(
            leading: const Icon(Icons.web, color: AppColors.black),
            title: const Text(
              'Visit our Website',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);

              final Uri url = Uri.parse('https://wealthbridgeimpex.com/');

              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Could not launch website')),
                );
              }
            },
          ),

          /// CONTACT US
          ListTile(
            leading: const Icon(Icons.contact_support, color: AppColors.black),
            title: const Text('Contact Us', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.contactUs);
            },
          ),

          /// About US
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.black),
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
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              final Uri url = Uri.parse(
                'https://wealthbridgeimpex.com/privacy_policy.html',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Could not open privacy policy'),
                  ),
                );
              }
            },
          ),
          const Divider(),

          /// SHARE APP
          ListTile(
            leading: const Icon(Icons.share, color: AppColors.black),
            title: const Text('Share this App', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coming Soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),

          /// RATE APP
          ListTile(
            leading: const Icon(Icons.star, color: AppColors.black),
            title: const Text('Rate this App', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coming Soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(),

          /// LOGOUT
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.black),
            title: const Text('Logout', style: TextStyle(fontSize: 18)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  /// LOGOUT WITH CONFIRMATION
  Future<void> _logout() async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await AuthStorage.clear();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

}
