import 'dart:async';

import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final apiService = ApiService();
  bool get isOtpComplete => enteredOtp.length == 6;
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String mobileNo = "";
  int? apiOtp;

  int _seconds = 30;
  Timer? _timer;

  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (mobileNo.isEmpty) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        mobileNo = args['mobile'] ?? "";
        apiOtp = args['otp'];
      }

      startTimer();
    }
  }

  void startTimer() {
    _seconds = 30;

    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  String get enteredOtp => _controllers.map((e) => e.text).join();

  Future<void> verifyOtp() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    if (enteredOtp.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter OTP")));
      return;
    }

    if (apiOtp != null && enteredOtp.trim() != apiOtp.toString()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP M")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await apiService.verifyOtp(
        mobileNo: mobileNo,
        otp: enteredOtp,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${result['Message'] ?? "OTP verified"} ")),
      );
      if (result["success"]) {
        Navigator.pushNamed(
          context,
          AppRoutes.resetPassword,
          arguments: {"mobile": mobileNo},
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result["message"])));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> resendOtp() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final result = await apiService.forgotPassword(mobileNo: mobileNo);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    if (result['success']) {
      apiOtp = result['otp'];

      for (var c in _controllers) {
        c.clear();
      }

      _focusNodes[0].requestFocus();

      startTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "OTP sent successfully to ${result['mobile'] ?? mobileNo}",
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  Widget otpBox(int index) {
    return SizedBox(
      width: 45,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        enableSuggestions: false,
        autocorrect: false,
        cursorColor: const Color(0xFF555555),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        decoration: AppDecorations.textField(label: '', counterText: ''),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          }

          if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
          if (index == 5 && value.isNotEmpty && !_isLoading) {
            verifyOtp();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Verify OTP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Enter the OTP sent to $mobileNo',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        6,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: otpBox(index),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      width: double.infinity,
                      text: "Verify OTP",
                      isLoading: _isLoading,
                      onPressed: (isOtpComplete && !_isLoading)
                          ? verifyOtp
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _seconds == 0 && !_isLoading
                        ? TextButton(
                            onPressed: resendOtp,
                            child: const Text(
                              "Resend OTP",
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        : Text(
                            "Resend OTP in $_seconds sec",
                            style: const TextStyle(color: Colors.grey),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
