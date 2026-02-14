import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;
  // Function()? onPaymentSuccessCallback;
  // Function(String message)? onPaymentErrorCallback;
  void initPayment(
    //   {
    //   required Function() onSuccess,
    //   required Function(String message) onError,
    // }
  ) {
    _razorpay = Razorpay();
    // onPaymentSuccessCallback = onSuccess;
    // onPaymentErrorCallback = onError;
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required double amount,
    required String email,
    required String contact,
    // required String orderId,
  }) {
    var options = {
      'key': 'rzp_live_S4YU2wG1qoN7Cl', // rzp_test_xxxxxxxxx
      'amount': (amount * 100).toInt(),
      'name': 'Wealth Bridge Impex', // SattvikPlate
      'description': 'Copper Order Payment',
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      // onPaymentErrorCallback?.call("Payment initialization failed");
      // print("Error--------------------: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // print("SUCCESS----------: ${response.paymentId}");
    // Send all values to backend for verification
    // verifyPaymentFromServer(
    //   paymentId: response.paymentId,
    //   orderId: response.orderId,
    //   signature: response.signature,
    // );
    verifyPaymentFromServer(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // onPaymentErrorCallback?.call(
    //     response.message ?? "Payment failed");
    // print("ERROR: ${response.code} - ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    //    print("External Wallet Selected: ${response.walletName}");
  }

  void dispose() {
    _razorpay.clear();
  }

  void verifyPaymentFromServer(
  //   {
  //   String? paymentId,
  //   String? orderId,
  //   String? signature,
  // }
    String? paymentId) {
    //   if (paymentId == null || orderId == null || signature == null) {
    //   onPaymentErrorCallback?.call("Invalid payment response");
    //   return;
    // }
    // TODO: Call your backend API
    // Send paymentId, orderId, signature
    // Backend must verify using Razorpay secret

    // onPaymentSuccessCallback?.call();
  }
}
