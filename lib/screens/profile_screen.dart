import 'package:copper_hub/services/cart_database_service.dart';
import 'package:copper_hub/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/services/api_service.dart';
import 'package:copper_hub/services/auth_storage.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:copper_hub/widgets/info_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  bool isEditing = false;
  bool _isLoading = false;

  int? _userId;

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController =
      TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    pincodeController.dispose();
    gstController.dispose();
    bankNameController.dispose();
    accountHolderController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    ifscController.dispose();

    super.dispose();
  }
  bool _hasAnyBankDetailFilled() {
  return accountHolderController.text.trim().isNotEmpty ||
      accountNumberController.text.trim().isNotEmpty ||
      confirmAccountNumberController.text.trim().isNotEmpty ||
      ifscController.text.trim().isNotEmpty ||
      bankNameController.text.trim().isNotEmpty;
}



  // Load profile from API
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final email = await AuthStorage.getEmail();
      if (email == null) return;

      final result = await _apiService.getUserByEmailOrMobile(
        emailOrMobile: email,
      );

      if (result['success'] == true) {
        final data = result['data'];

        _userId = data['Id'];

        fullNameController.text = data['FullName'] ?? '';
        emailController.text = data['Email'] ?? '';
        mobileController.text = data['Mobile'] ?? '';
        addressController.text = data['Address'] ?? '';
        landmarkController.text = data['Landmark'] ?? '';
        pincodeController.text = data['Pincode'] ?? '';
        gstController.text = data['Gst'] ?? '';
        bankNameController.text = data['BankName'] ?? '';
        accountHolderController.text = data['AccountHolderName'] ?? '';
        accountNumberController.text = data['AccountNumber'] ?? '';
        confirmAccountNumberController.text = data['AccountNumber'] ?? '';
        ifscController.text = data['IfscCode'] ?? '';
      }
    } catch (e) {
      // debugPrint('Profile load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Update profile API
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userId == null) return;

    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final address = addressController.text.trim();
    final pincode = pincodeController.text.trim();
    final gst = gstController.text.trim();
    final landmark = landmarkController.text.trim();
    final bankName = bankNameController.text.trim();
    final accountHolder = accountHolderController.text.trim();
    final accountNumber = accountNumberController.text.trim();
    final ifsc = ifscController.text.trim().toUpperCase();

    setState(() => _isLoading = true);

    try {
      await _apiService.updateUserProfile(
        id: _userId!,
        fullname: fullName,
        email: email,
        mobile: mobile,
        address: address,
        landmark: landmark,
        pincode: pincode,
        gst: gst,
        bankName: bankName,
        accountHolder: accountHolder,
        accountNumber: accountNumber,
        ifscCode: ifsc,
      );

      await AuthStorage.saveLoginData(
        userId: _userId!,
        name: fullName,
        email: email,
        mobile: mobile,
      );

      if (!mounted) return;

      setState(() => isEditing = false);
      _showMessage('Profile updated successfully');

      await _loadProfile();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Update failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildField({
    required IconData icon,
    required String label,
    required String value,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    if (isEditing && enabled) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: TextInputAction.next,
          decoration: AppDecorations.textField(label: label),
          validator: validator,
        ),
      );
    }

    return Column(
      children: [
        InfoRow(icon: icon, label: label, value: value),
        const Divider(height: 24),
      ],
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () async {
              // if (isEditing) {
              //   await _loadProfile();
              // }
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.amber.shade100,
                        child: Text(
                          fullNameController.text.isNotEmpty
                              ? fullNameController.text.trim()[0].toUpperCase()
                              : '',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffF9B236),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullNameController.text,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildField(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: fullNameController.text,
                        controller: fullNameController,
                        validator: Validators.fullName,
                      ),
                      _buildField(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: emailController.text,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      _buildField(
                        icon: Icons.phone_outlined,
                        label: 'Mobile',
                        value: mobileController.text,
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        validator: Validators.mobile,
                      ),
                      _buildField(
                        icon: Icons.location_on_outlined,
                        label: 'Address',
                        value: addressController.text,
                        controller: addressController,
                        validator: Validators.address,
                      ),
                      _buildField(
                        icon: Icons.pin_drop_outlined,
                        label: 'Pincode',
                        value: pincodeController.text,
                        controller: pincodeController,
                        keyboardType: TextInputType.number,
                        validator: Validators.pincode,
                      ),
                      _buildField(
                        icon: Icons.place_outlined,
                        label: 'Landmark',
                        value: landmarkController.text,
                        controller: landmarkController,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return null;
                          return Validators.landmark(text);
                        },
                      ),
                      _buildField(
                        icon: Icons.receipt_long_outlined,
                        label: 'GST Number',
                        value: gstController.text,
                        controller: gstController,
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return null;
                          return Validators.gst(text);
                        },
                      ),
                      const SizedBox(height: 16),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Bank Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildField(
                        icon: Icons.account_circle,
                        label: 'Account Holder Name',
                        value: accountHolderController.text,
                        controller: accountHolderController,
                         validator: (value) {
                          if (!_hasAnyBankDetailFilled()) return null;
                          return Validators.accountHolder(value?.trim() ?? '');
                        },
                      ),

                      _buildField(
                        icon: Icons.credit_card,
                        label: 'Account Number',
                        value: accountNumberController.text,
                        controller: accountNumberController,
                        keyboardType: TextInputType.number,
                         validator: (value) {
                          if (!_hasAnyBankDetailFilled()) return null;
                          return Validators.accountNumber(value?.trim() ?? '');
                        },
                      ),

                      _buildField(
                        icon: Icons.credit_card,
                        label: 'Confirm Account Number',
                        value: confirmAccountNumberController.text,
                        controller: confirmAccountNumberController,
                        keyboardType: TextInputType.number,
                         validator: (value) {
                          if (!_hasAnyBankDetailFilled()) return null;
                          return Validators.confirmAccountNumber(
                            value?.trim() ?? '',
                            accountNumberController.text.trim(),
                          );
                        },
                      ),

                      _buildField(
                        icon: Icons.account_balance,
                        label: 'IFSC Code',
                        value: ifscController.text,
                        controller: ifscController,
                         validator: (value) {
                          if (!_hasAnyBankDetailFilled()) return null;
                          return Validators.ifsc(value?.trim() ?? '');
                        },
                      ),

                      _buildField(
                        icon: Icons.account_balance_wallet,
                        label: 'Bank Name',
                        value: bankNameController.text,
                        controller: bankNameController,
                         validator: (value) {
                          if (!_hasAnyBankDetailFilled()) return null;
                          return Validators.bankName(value?.trim() ?? '');
                        },
                      ),

                      // _buildField(
                      //   icon: Icons.qr_code,
                      //   label: 'UPI ID',
                      //   value: upiController.text,
                      //   controller: upiController,
                      // ),
                      if (isEditing) ...[
                        const SizedBox(height: 8),
                        // AppColors.greenDark,
                        CustomButton(
                          text: 'Save Changes',
                          backgroundColor: AppColors.orangeDark,
                          foregroundColor: AppColors.white,
                          width: double.infinity,
                          onPressed: _updateProfile,
                        ),
                        const SizedBox(height: 16),

                        // DELETE ACCOUNT BUTTON
                        CustomButton(
                          text: 'Delete Account',
                          backgroundColor: Colors.red,
                          foregroundColor: AppColors.white,
                          width: double.infinity,
                          onPressed: _showDeleteDialog,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text("Delete Account"),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAccount();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    if (_userId == null) {
      _showMessage("User not found");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.deleteUserAccount(userId: _userId!);

      if (result['success'] == true) {
        // clear login storage
        await AuthStorage.logout();
        await CartDatabaseService.instance.clearCart();

        if (!mounted) return;
        _showMessage(result['message'] ?? "Account deleted successfully");
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      } else {
        _showMessage(result['message'] ?? "Failed to delete account");
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage("Failed to delete account");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
