import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wealth_bridge_impex/screens/login_screen.dart';
import 'package:wealth_bridge_impex/services/api_service.dart';
import 'package:wealth_bridge_impex/utils/input_decoration.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  // Email validator helper
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Computed property for enabling/disabling button
  bool get _isFormValid {
    return _fullNameController.text.trim().length >= 2 &&
        _isValidEmail(_emailController.text.trim()) &&
        _mobileController.text.trim().length == 10 &&
        _passwordController.text.trim().length >= 4 &&
        _addressController.text.trim().length >= 5 &&
        _pincodeController.text.trim().length == 6;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 24),
          child: Center(
            child: Card(
              color: Colors.white,
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Form(
                key: _formKey, // Attach Form key
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        cursorColor: Colors.black,
                        decoration: AppDecorations.textField(label: 'Full Name'),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().length < 2) {
                            return 'Please enter a valid full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        cursorColor: Colors.black,
                        decoration: AppDecorations.textField(
                          label: 'Email Address',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || !_isValidEmail(value.trim())) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        cursorColor: Colors.black,
                        onChanged: (_) => setState(() {}),
                        decoration: AppDecorations.textField(
                          label: 'Mobile Number',
                          counterText: '',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length != 10) {
                            return 'Mobile number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        cursorColor: Colors.black,
                        onChanged: (_) => setState(() {}),
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
                        validator: (value) {
                          if (value == null || value.trim().length < 4) {
                            return 'Password must be at least 4 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _addressController,
                        textInputAction: TextInputAction.next,
                        maxLines: 3,
                        cursorColor: Colors.black,
                        decoration: AppDecorations.textField(label: 'Address'),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().length < 5) {
                            return 'Please enter a valid address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _landmarkController,
                        textInputAction: TextInputAction.next,
                        decoration: AppDecorations.textField(
                          label: 'Landmark (optional)',
                        ),
                      ),
                      const SizedBox(height: 20),
                                
                      TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        decoration: AppDecorations.textField(
                          label: 'Pincode',
                          counterText: '',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().length != 6) {
                            return 'Pincode must be 6 digits';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _gstController,
                        textInputAction: TextInputAction.done,
                        decoration: AppDecorations.textField(
                          label: 'GST Number (optional)',
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 10) {
                            return 'Invalid GST number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading || !_isFormValid
                            ? null
                            : _onRegisterPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF9B236),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(fontSize: 16, color: Colors.blue),
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
      ),
    );
  }

  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;
    // Safety check, Only proceed if all validators pass

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.registerUser(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        mobile: _mobileController.text.trim(),
        password: _passwordController.text.trim(),
        address: _addressController.text.trim(),
        landmark: _landmarkController.text.trim(),
        pincode: _pincodeController.text.trim(),
        gst: _gstController.text.trim(),
      );
      if (!mounted) return;
      debugPrint('Response---- ${response.toString()}');
      if (response['success'] == true) {
        _showMessage('Registration successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _showMessage(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      // Network error, server error, etc.
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
