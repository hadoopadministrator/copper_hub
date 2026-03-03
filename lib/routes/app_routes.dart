import 'package:copper_hub/screens/about_us_screen.dart';
import 'package:copper_hub/screens/by_checkout_screen.dart';
import 'package:copper_hub/screens/contact_us_screen.dart';
import 'package:copper_hub/screens/forgot_password_screen.dart';
import 'package:copper_hub/screens/holdings_screen.dart';
import 'package:copper_hub/screens/live_rates_screen.dart';
import 'package:copper_hub/screens/login_screen.dart';
import 'package:copper_hub/screens/my_cart_screen.dart';
import 'package:copper_hub/screens/order_details.dart';
import 'package:copper_hub/screens/order_history.dart';
import 'package:copper_hub/screens/order_success_screen.dart';
import 'package:copper_hub/screens/profile_screen.dart';
import 'package:copper_hub/screens/register_screen.dart';
import 'package:copper_hub/screens/reset_password_screen.dart';
import 'package:copper_hub/screens/sell_checkout_screen.dart';
import 'package:copper_hub/screens/splash_screen.dart';
import 'package:copper_hub/screens/verify_otp_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._(); // prevents instantiation

  // Route names
  static const String splash = '/';
  static const String liveRates = '/liveRates';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgotPassword';
  static const String contactUs = '/contactUs';
  static const String aboutUs = '/aboutUs';
  static const String orderHistory = '/orderHistory';
  static const String orderDetails = '/orderDetails';
  static const String byCheckOut = '/byCheckOut';
  static const String sellCheckOut = '/sellCheckOut';
  static const String orderSuccess = '/orderSuccess';
  static const String profile = '/profile';
  static const String cart = '/cart';
  static const String verifyOTP = '/verifyOTP';
  static const String resetPassword = '/resetPassword';
  static const String myHoldings = '/myHoldings';


  // Route map
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    liveRates: (context) => const LiveRatesScreen(),
    login: (context) => const LoginScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    register: (context) => const RegisterScreen(),
    contactUs: (context) => const ContactUsScreen(),
    aboutUs: (context) => const AboutUsScreen(),
    orderHistory: (context) => const OrderHistory(),
    orderDetails: (context) => const OrderDetails(),
    byCheckOut: (context) => const ByCheckoutScreen(),
    sellCheckOut: (context) => const SellCheckoutScreen(),
    orderSuccess: (context) => const OrderSuccessScreen(),
    profile: (context) => const ProfileScreen(),
    cart: (context) => const MyCartScreen(),
    verifyOTP: (context) => const VerifyOtpScreen(),
    resetPassword: (context) => const ResetPasswordScreen(),
    myHoldings: (context) => const HoldingsScreen(),
  };
}
