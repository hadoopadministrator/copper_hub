import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;

  Function(String paymentId)? onPaymentSuccessCallback;
  Function(String message)? onPaymentErrorCallback;

  // ================= INIT =================
  void initPayment({
    required Function(String paymentId) onSuccess,
    required Function(String message) onError,
  }) {
    _razorpay = Razorpay();
    onPaymentSuccessCallback = onSuccess;
    onPaymentErrorCallback = onError;

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // ================= OPEN CHECKOUT =================
  void openCheckout({
    required double amount,
    required String email,
    required String contact,
  }) {
    var options = {
      'key': 'rzp_live_S4YU2wG1qoN7Cl',
      'amount': (amount * 100).toInt(),
      'name': 'Copper Hub',
      'description': 'Copper Order Payment',
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      onPaymentErrorCallback?.call("Payment initialization failed");
    }
  }

  // ================= PAYMENT SUCCESS =================
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final paymentId = response.paymentId ?? '';

    if (paymentId.isEmpty) {
      onPaymentErrorCallback?.call("Invalid payment response");
      return;
    }
    // ---------------- CHANGE ----------------
    // Call success callback
    onPaymentSuccessCallback?.call(paymentId);
    // ---------------- END CHANGE ----------------
  }

  // ================= PAYMENT ERROR =================
  void _handlePaymentError(PaymentFailureResponse response) {
    // ---------------- CHANGE ----------------
    // Call error callback (navigation handled in ByCheckoutScreen)
    onPaymentErrorCallback?.call(response.message ?? "Payment failed");
    // ---------------- END CHANGE ----------------
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Optional external wallet handling
  }

  void dispose() {
    try {
      _razorpay.clear();
    } catch (_) {}
  }
}
