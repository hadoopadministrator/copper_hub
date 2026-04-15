import 'package:copper_hub/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:copper_hub/widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
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

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  bool _hasAnyBankDetailFilled() {
    return _accountHolderController.text.trim().isNotEmpty ||
        _accountNumberController.text.trim().isNotEmpty ||
        _ifscController.text.trim().isNotEmpty ||
        _bankNameController.text.trim().isNotEmpty;
  }

  bool get _isFormValid {
    final isBasicValid =
        Validators.fullName(_fullNameController.text.trim()) == null &&
        Validators.email(_emailController.text.trim()) == null &&
        Validators.mobile(_mobileController.text.trim()) == null &&
        Validators.password(_passwordController.text.trim()) == null &&
        Validators.address(_addressController.text.trim()) == null &&
        Validators.pincode(_pincodeController.text.trim()) == null;

    final landmark = _landmarkController.text.trim();
    final gst = _gstController.text.trim();
    final isOptionalValid =
        (landmark.isEmpty || Validators.landmark(landmark) == null) &&
        (gst.isEmpty || Validators.gst(gst) == null);
    final hasBank = _hasAnyBankDetailFilled();
    final isBankValid =
        !hasBank ||
        (Validators.accountHolder(_accountHolderController.text.trim()) ==
                null &&
            Validators.accountNumber(_accountNumberController.text.trim()) ==
                null &&
            Validators.confirmAccountNumber(
                  _confirmAccountNumberController.text.trim(),
                  _accountNumberController.text.trim(),
                ) ==
                null &&
            Validators.ifsc(_ifscController.text.trim()) == null &&
            Validators.bankName(_bankNameController.text.trim()) == null);
    return isBasicValid && isOptionalValid && isBankValid;
  }

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_updateForm);
    _emailController.addListener(_updateForm);
    _mobileController.addListener(_updateForm);
    _passwordController.addListener(_updateForm);
    _addressController.addListener(_updateForm);
    _pincodeController.addListener(_updateForm);
    _landmarkController.addListener(_updateForm);
    _gstController.addListener(_updateForm);
    _accountHolderController.addListener(_updateForm);
    _accountNumberController.addListener(_updateForm);
    _confirmAccountNumberController.addListener(_updateForm);
    _ifscController.addListener(_updateForm);
    _bankNameController.addListener(_updateForm);
  }

  void _updateForm() {
    setState(() {});
  }

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
    // _upiController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Card(
            child: Form(
              key: _formKey, // Attach Form key
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Create Account',
                        style: textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _fullNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      decoration: AppDecorations.textField(label: 'Full Name'),
                      validator: Validators.fullName,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: AppDecorations.textField(
                        label: 'Email Address',
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
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
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      maxLines: 3,
                      decoration: AppDecorations.textField(label: 'Address'),
                      validator: Validators.address,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _pincodeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: AppDecorations.textField(
                        label: 'Pincode',
                        counterText: '',
                      ),
                      validator: Validators.pincode,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _landmarkController,
                      textInputAction: TextInputAction.next,
                      decoration: AppDecorations.textField(
                        label: 'Landmark (optional)',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return null;
                        return Validators.landmark(text);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _gstController,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9]'),
                        ),
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: AppDecorations.textField(
                        label: 'GST Number (optional)',
                      ),
                      onChanged: (value) {
                        final upper = value.toUpperCase();
                        if (value != upper) {
                          _gstController.value = _gstController.value.copyWith(
                            text: upper,
                            selection: TextSelection.collapsed(
                              offset: upper.length,
                            ),
                          );
                        }
                      },
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return null;
                        return Validators.gst(text);
                      },
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Bank Details (Optional)",
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountHolderController,
                      textInputAction: TextInputAction.next,
                      decoration: AppDecorations.textField(
                        label: 'Account Holder Name (optional)',
                      ),
                      validator: (value) {
                        if (!_hasAnyBankDetailFilled()) return null;
                        return Validators.accountHolder(value?.trim() ?? '');
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: AppDecorations.textField(
                        label: 'Account Number (optional)',
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (!_hasAnyBankDetailFilled()) return null;
                        return Validators.accountNumber(value?.trim() ?? '');
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmAccountNumberController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: AppDecorations.textField(
                        label: 'Confirm Account Number (optional)',
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (!_hasAnyBankDetailFilled()) return null;
                        return Validators.confirmAccountNumber(
                          value?.trim() ?? '',
                          _accountNumberController.text.trim(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ifscController,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9]'),
                        ),
                        LengthLimitingTextInputFormatter(11),
                      ],
                      decoration: AppDecorations.textField(
                        label: 'IFSC Code (optional)',
                      ),
                      onChanged: (value) {
                        final upper = value.toUpperCase();
                        if (value != upper) {
                          _ifscController.value = _ifscController.value
                              .copyWith(
                                text: upper,
                                selection: TextSelection.collapsed(
                                  offset: upper.length,
                                ),
                              );
                        }
                      },
                      validator: (value) {
                        if (!_hasAnyBankDetailFilled()) return null;
                        return Validators.ifsc(value?.trim() ?? '');
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _bankNameController,
                      textInputAction: TextInputAction.done,
                      decoration: AppDecorations.textField(
                        label: 'Bank Name (optional)',
                      ),
                      validator: (value) {
                        if (!_hasAnyBankDetailFilled()) return null;
                        return Validators.bankName(value?.trim() ?? '');
                      },
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      width: double.infinity,
                      text: 'Register',
                      onPressed: _isFormValid ? _onRegisterPressed : null,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?'),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Login'),
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
        bankName: _bankNameController.text.trim(),
        accountHolderName: _accountHolderController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        ifscCode: _ifscController.text.trim(),
      );

      if (!mounted) return;

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
