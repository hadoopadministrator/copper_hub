import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/screens/about_us_screen.dart';
import 'package:wealth_bridge_impex/screens/check_out_screen.dart';
import 'package:wealth_bridge_impex/screens/contact_us_screen.dart';
import 'package:wealth_bridge_impex/screens/forgot_password_screen.dart';
import 'package:wealth_bridge_impex/screens/live_rates_screen.dart';
import 'package:wealth_bridge_impex/screens/login_screen.dart';
import 'package:wealth_bridge_impex/screens/order_history.dart';
import 'package:wealth_bridge_impex/screens/order_success_screen.dart';
import 'package:wealth_bridge_impex/screens/payment_screen.dart';
import 'package:wealth_bridge_impex/screens/profile_screen.dart';
import 'package:wealth_bridge_impex/screens/register_screen.dart';
import 'package:wealth_bridge_impex/screens/splash_screen.dart';

class AppRoutes {
  AppRoutes._(); // prevents instantiation

  // Route names
  static const String splash = '/';
  static const String liveRates = '/liveRates';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgot = '/forgot';
  static const String contactUs = '/contactUs';
  static const String aboutUs = '/aboutUs';
  static const String orderHistory = '/orderHistory';
  static const String checkOut = '/checkOut';
  static const String payment = '/payment';
  static const String orderSuccess = '/orderSuccess';
  static const String profile = '/profile';
  // Route map
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    liveRates: (context) => const LiveRatesScreen(),
    login: (context) => const LoginScreen(),
    forgot: (context) => const ForgotPasswordScreen(),
    register: (context) => const RegisterScreen(),
    contactUs: (context) => const ContactUsScreen(),
    aboutUs: (context) => const AboutUsScreen(),
    orderHistory: (context) => const OrderHistory(),
    checkOut: (context) => const CheckOutScreen(),
    payment: (context) => const PaymentScreen(),
    orderSuccess: (context) => const OrderSuccessScreen(),
    profile: (context) => const ProfileScreen(),
  };
}