import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:copper_hub/widgets/custom_button.dart';

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
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _confirmAccountNumberController =
      TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();

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
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _ifscController.dispose();
    _bankNameController.dispose();
    _upiController.dispose();

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Center(
            child: Card(
              color: AppColors.white,
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Form(
                key: _formKey, // Attach Form key
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
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
                        cursorColor: AppColors.black,
                        decoration: AppDecorations.textField(
                          label: 'Full Name',
                        ),
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
                        cursorColor: AppColors.black,
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
                        cursorColor: AppColors.black,
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
                        cursorColor: AppColors.black,
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
                        cursorColor: AppColors.black,
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
                        validator: (value) {
                          if (value != null && value.trim().length > 100) {
                            return 'Landmark too long';
                          }
                          return null;
                        },
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
                        textCapitalization: TextCapitalization.characters,
                        decoration: AppDecorations.textField(
                          label: 'GST Number (optional)',
                        ),
                        validator: (value) {
                          final gst = value?.trim().toUpperCase();

                          if (gst == null || gst.isEmpty) return null;

                          final gstRegex = RegExp(
                            r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
                          );

                          if (!gstRegex.hasMatch(gst)) {
                            return 'Enter valid GST number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      const Text(
                        "Bank Details (Optional)",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _accountHolderController,
                        decoration: AppDecorations.textField(
                          label: 'Account Holder Name (optional)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final name = value.trim();
                          if (name.length < 3) {
                            return "Minimum 3 characters required";
                          }
                          final nameRegex = RegExp(r'^[a-zA-Z ]+$');
                          if (!nameRegex.hasMatch(name)) {
                            return "Only letters allowed";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        decoration: AppDecorations.textField(
                          label: 'Account Number (optional)',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (!RegExp(r'^[0-9]{8,18}$').hasMatch(value)) {
                            return "Enter valid account number";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _confirmAccountNumberController,
                        keyboardType: TextInputType.number,
                        decoration: AppDecorations.textField(
                          label: 'Confirm Account Number',
                        ),
                        validator: (value) {
                          if (_accountNumberController.text.isEmpty &&
                              (value == null || value.isEmpty)) {
                            return null;
                          }
                          if (value != _accountNumberController.text) {
                            return "Account numbers do not match";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _ifscController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: AppDecorations.textField(
                          label: 'IFSC Code (optional)',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          if (!RegExp(
                            r'^[A-Z]{4}0[A-Z0-9]{6}$',
                          ).hasMatch(value)) {
                            return "Enter valid IFSC code";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _bankNameController,
                        decoration: AppDecorations.textField(
                          label: 'Bank Name (optional)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final bank = value.trim();
                          if (bank.length < 3) {
                            return "Minimum 3 characters required";
                          }
                          final bankRegex = RegExp(r'^[a-zA-Z ]+$');
                          if (!bankRegex.hasMatch(bank)) {
                            return "Enter valid bank name";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _upiController,
                        decoration: AppDecorations.textField(
                          label: 'UPI ID (optional)',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }
                          final upi = value.trim();
                          final upiRegex = RegExp(
                            r'^[a-zA-Z0-9.\-_]{2,}@[a-zA-Z]{2,}$',
                          );
                          if (!upiRegex.hasMatch(upi)) {
                            return "Enter valid UPI ID";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: 'Register',
                        onPressed: _isFormValid ? _onRegisterPressed : null,
                        isLoading: _isLoading,
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
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
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
        // accountHolderName: _accountHolderController.text.trim(),
        // accountNumber: _accountNumberController.text.trim(),
        // ifscCode: _ifscController.text.trim(),
        // bankName: _bankNameController.text.trim(),
        // upiId: _upiController.text.trim(),
      );

      if (!mounted) return;

      // debugPrint('Response---- $response');

      final bool isSuccess = response['success'] == true;
      final String message =
          response['message']?.toString() ??
          (isSuccess ? 'Registration successful' : 'Registration failed');

      _showMessage(message);

      if (isSuccess) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
