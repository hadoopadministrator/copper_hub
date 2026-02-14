import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/services/api_service.dart';
import 'package:wealth_bridge_impex/services/auth_storage.dart';
import 'package:wealth_bridge_impex/utils/app_colors.dart';
import 'package:wealth_bridge_impex/utils/input_decoration.dart';
import 'package:wealth_bridge_impex/widgets/custom_button.dart';
import 'package:wealth_bridge_impex/widgets/info_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

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
    super.dispose();
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
      }
    } catch (e) {
      debugPrint('Profile load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Update profile API
  Future<void> _updateProfile() async {
    if (_userId == null) return;
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();
    final address = addressController.text.trim();
    final pincode = pincodeController.text.trim();
    final gst = gstController.text.trim();
    final landmark = landmarkController.text.trim();

    // ---- validations (NO API CALL if any fails) ----
    if (fullName.isEmpty) {
      _showMessage('Full name is required');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Email is required');
      return;
    }

    if (mobile.isEmpty || mobile.length != 10) {
      _showMessage('Enter valid 10 digit mobile number');
      return;
    }

    if (address.isEmpty) {
      _showMessage('Address is required');
      return;
    }

    if (pincode.isEmpty || pincode.length != 6) {
      _showMessage('Enter valid pincode');
      return;
    }

    if (gst.isEmpty) {
      _showMessage('GST number is required');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.updateUserProfile(
        id: _userId!,
        fullname: fullName,
        email: email,
        mobile: mobile,
        address: address,
        landmark: landmark, // can be empty
        pincode: pincode,
        gst: gst,
      );

      // UPDATE LOCAL STORAGE HERE
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
  }) {
    if (isEditing && enabled) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: AppDecorations.textField(label: label),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
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
                    ),
                    _buildField(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: emailController.text,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildField(
                      icon: Icons.phone_outlined,
                      label: 'Mobile',
                      value: mobileController.text,
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildField(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: addressController.text,
                      controller: addressController,
                    ),
                    _buildField(
                      icon: Icons.place_outlined,
                      label: 'Landmark',
                      value: landmarkController.text,
                      controller: landmarkController,
                    ),
                    _buildField(
                      icon: Icons.pin_drop_outlined,
                      label: 'Pincode',
                      value: pincodeController.text,
                      controller: pincodeController,
                      keyboardType: TextInputType.number,
                    ),
                    _buildField(
                      icon: Icons.receipt_long_outlined,
                      label: 'GST Number',
                      value: gstController.text,
                      controller: gstController,
                    ),
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
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
