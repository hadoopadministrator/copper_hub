import 'package:copper_hub/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:copper_hub/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailOrMobileController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool remember = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final isRemember = await AuthStorage.isRememberMe();

    if (!isRemember) return;

    final user = await AuthStorage.getRememberUser();
    final password = await AuthStorage.getRememberPassword();

    setState(() {
      remember = true;
      _emailOrMobileController.text = user ?? '';
      _passwordController.text = password ?? '';
    });
  }

  bool get _isFormValid {
    return Validators.emailOrMobile(_emailOrMobileController.text.trim()) ==
            null &&
        _passwordController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _emailOrMobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Card(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey, // Attach Form key
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text('Login', style: textTheme.titleLarge)),
                    const SizedBox(height: 20),
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
                      //validator: Validators.emailOrMobile,
                      decoration: AppDecorations.textField(
                        label: 'Email / Mobile',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => setState(() {}),
                      /*validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },*/
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
                          onChanged: (value) {
                            setState(() => remember = value ?? false);
                          },
                        ),
                        Text('Remember me'),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.forgotPassword,
                            );
                          },
                          child: Text('Forgot password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      width: double.infinity,
                      text: 'Login',
                      onPressed: _isFormValid ? _onLoginPressed : null,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: const Text('Register'),
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

        await AuthStorage.saveRememberMe(
          remember: remember,
          emailOrMobile: _emailOrMobileController.text.trim(),
          password: _passwordController.text.trim(),
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
