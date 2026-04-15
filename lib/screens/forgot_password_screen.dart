import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:flutter/services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mobileController = TextEditingController();
  final apiService = ApiService();
  bool _isLoading = false;
  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    final result = await apiService.forgotPassword(
      mobileNo: _mobileController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "OTP sent successfully to ${result['mobile'] ?? _mobileController.text}",
          ),
        ),
      );

      Navigator.pushNamed(
        context,
        AppRoutes.verifyOTP,
        arguments: {
          "mobile": result['mobile'] ?? _mobileController.text.trim(),
          "otp": result['otp'],
        },
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          // dismiss keyboard on outside tap
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: Card(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Forgot Password?',
                          style: textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Enter your registered mobile number to receive OTP',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: AppDecorations.textField(
                          label: 'Mobile Number',
                          counterText: '',
                        ),
                        validator: Validators.mobile,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        width: double.infinity,
                        text: "Send OTP",
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _sendOtp,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Remember your password?'),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
