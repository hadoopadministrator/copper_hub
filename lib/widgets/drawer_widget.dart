import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wealth_bridge_impex/routes/app_routes.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xffF5F6FA),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          /// HEADER
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.white),
            child: Image.asset('assets/logo/logo.jpeg', fit: BoxFit.fill),
          ),

          /// LIVE PRICES (HOME)
          /// Always go back to first/root screen
          ListTile(
            leading: const Icon(Icons.home, color: Colors.black),
            title: const Text('Live Prices', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),

          /// PROFILE
          /// Normal push, back press should return to previous screen
          ListTile(
            leading: const Icon(Icons.person, color: Colors.black),
            title: const Text('Profile', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),

          /// ORDER HISTORY
          /// Drawer se hamesha simple push
          /// Never clear stack here
          ListTile(
            leading: const Icon(Icons.history, color: Colors.black),
            title: const Text('Order History', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context); // close drawer
              Navigator.pushNamed(context, AppRoutes.orderHistory);
            },
          ),

          /// VISIT WEBSITE
          ListTile(
            leading: const Icon(Icons.web, color: Colors.black),
            title: const Text(
              'Visit our Website',
              style: TextStyle(fontSize: 18),
            ),
            onTap: () {
              Navigator.pop(context);
              // open website using url_launcher
            },
          ),

          /// CONTACT US
          ListTile(
            leading: const Icon(Icons.contact_mail, color: Colors.black),
            title: const Text('Contact Us', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.contactUs);
            },
          ),

          /// About US
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.black),
            title: const Text('About Us', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.aboutUs);
            },
          ),

          /// SHARE APP
          ListTile(
            leading: const Icon(Icons.share, color: Colors.black),
            title: const Text('Share this App', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              // share app link
            },
          ),

          /// RATE APP
          ListTile(
            leading: const Icon(Icons.star, color: Colors.black),
            title: const Text('Rate this App', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.pop(context);
              // open play store
            },
          ),

          /// LOGOUT
          /// Clear full stack and go to Login
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black),
            title: const Text('Logout', style: TextStyle(fontSize: 18)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
