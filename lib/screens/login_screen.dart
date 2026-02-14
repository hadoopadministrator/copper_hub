import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_bridge_impex/routes/app_routes.dart';
import 'package:wealth_bridge_impex/services/api_service.dart';
import 'package:wealth_bridge_impex/services/auth_storage.dart';
import 'package:wealth_bridge_impex/utils/app_colors.dart';
import 'package:wealth_bridge_impex/utils/input_decoration.dart';
import 'package:wealth_bridge_impex/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _emailOrMobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool remember = false;
  bool _isValidEmail(String value) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
  }

  // bool _isValidMobile(String value) {
  //   return RegExp(r'^[0-9]{10}$').hasMatch(value);
  // }

  // Computed property for enabling/disabling button
  bool get _isFormValid {
    final input = _emailOrMobileController.text.trim();
    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(input);

    if (isNumeric) {
      return input.length == 10 && _passwordController.text.trim().length >= 4;
    } else {
      return _isValidEmail(input) &&
          _passwordController.text.trim().length >= 4;
    }
  }

  @override
  void dispose() {
    _emailOrMobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Card(
            margin: const EdgeInsets.only(left: 16.0, right: 16.0),
            color: AppColors.white,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Attach Form key
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _emailOrMobileController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.username,
                        AutofillHints.email,
                      ],
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9a-zA-Z@._-]'),
                        ),
                        LengthLimitingTextInputFormatter(50),
                      ],
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        final input = value?.trim() ?? '';

                        if (input.isEmpty) {
                          return 'Email or mobile is required';
                        }

                        final isNumeric = RegExp(r'^[0-9]+$').hasMatch(input);

                        // UPDATED: numeric input = mobile
                        if (isNumeric) {
                          if (input.length != 10) {
                            return 'Mobile number must be 10 digits';
                          }
                        }
                        // else treat as email
                        else if (!_isValidEmail(input)) {
                          return 'Enter valid email address';
                        }

                        return null;
                      },
                      cursorColor: AppColors.black,
                      decoration: AppDecorations.textField(
                        label: 'Email / Mobile',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().length < 4) {
                          return 'Password must be at least 4 characters';
                        }
                        return null;
                      },
                      cursorColor: AppColors.black,
                      decoration: AppDecorations.textField(
                        label: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: remember,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            setState(() => remember = value ?? false);
                          },
                        ),
                        Text(
                          'Remember me',
                          style: TextStyle(color: AppColors.black),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.forgot);
                          },
                          child: Text(
                            'Forgot passsword?',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Login',
                      onPressed: _isFormValid ? _onLoginPressed : null,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(color: Colors.blue),
                          ),
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
    );
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.loginUser(
        emailOrMobile: _emailOrMobileController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final bool isSuccess = response['success'] == true;
      final String message = response['message'] ?? 'Login failed';

      if (isSuccess) {
        final data = response['data'];
        await AuthStorage.saveLoginData(
          userId: data['Id'],
          name: data['FullName'],
          email: data['Email'],
          mobile: data['Mobile'],
        );

        _showMessage(message);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.liveRates);
      } else {
        _showMessage(message);
      }
    } catch (e) {
      _showMessage('Something went wrong. Please try again');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
