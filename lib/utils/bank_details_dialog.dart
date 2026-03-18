import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/utils/validators.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:copper_hub/services/api_service.dart';

class BankDetailsDialog extends StatefulWidget {
  final int userId;
  final VoidCallback onSaved;
  final Map<String, dynamic>? bankData;

  const BankDetailsDialog({
    super.key,
    required this.userId,
    required this.onSaved,
    this.bankData,
  });

  @override
  State<BankDetailsDialog> createState() => _BankDetailsDialogState();
}

class _BankDetailsDialogState extends State<BankDetailsDialog> {
  final _formKey = GlobalKey<FormState>();

  final accountHolderController = TextEditingController();
  final accountNumberController = TextEditingController();
  final confirmAccountNumberController = TextEditingController();
  final ifscController = TextEditingController();
  final bankNameController = TextEditingController();
  // final upiController = TextEditingController();

  final api = ApiService();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.bankData;

    if (data != null) {
      accountHolderController.text = data['accountHolder'] ?? '';
      accountNumberController.text = data['accountNumber'] ?? '';
      confirmAccountNumberController.text = data['accountNumber'] ?? '';
      ifscController.text = data['ifscCode'] ?? '';
      bankNameController.text = data['bankName'] ?? '';
    }
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Required";
    }
    return null;
  }

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final result = await api.saveBankDetails(
      userId: widget.userId,
      accountHolderName: accountHolderController.text.trim(),
      accountNumber: accountNumberController.text.trim(),
      ifscCode: ifscController.text.trim(),
      bankName: bankNameController.text.trim(),
    );

    setState(() => loading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context);

      widget.onSaved();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Bank details saved")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'] ?? "Failed")));
    }
  }

  @override
  void dispose() {
    accountHolderController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    ifscController.dispose();
    bankNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      title: Text(
        widget.bankData == null ? "Add Bank Details" : "Update Bank Details",
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: accountHolderController,
                decoration: const InputDecoration(
                  labelText: "Account Holder Name",
                ),
                validator: (value) {
                  return _required(value) ?? Validators.accountHolder(value);
                },
              ),

              TextFormField(
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Account Number"),
                validator: (value) {
                  return _required(value) ?? Validators.accountNumber(value);
                },
              ),

              TextFormField(
                controller: confirmAccountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Confirm Account Number",
                ),
                validator: (value) {
                  final requiredError = _required(value);
                  if (requiredError != null) return requiredError;
                  return Validators.confirmAccountNumber(
                    value?.trim(),
                    accountNumberController.text.trim(),
                  );
                },
              ),

              TextFormField(
                controller: ifscController,
                decoration: const InputDecoration(labelText: "IFSC Code"),
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  final upper = value.toUpperCase();
                  if (value != upper) {
                    ifscController.value = ifscController.value.copyWith(
                      text: upper,
                      selection: TextSelection.collapsed(offset: upper.length),
                    );
                  }
                },
                validator: (value) {
                  return _required(value) ?? Validators.ifsc(value);
                },
              ),

              TextFormField(
                controller: bankNameController,
                decoration: const InputDecoration(labelText: "Bank Name"),
                validator: (value) {
                  return _required(value) ?? Validators.bankName(value);
                },
              ),

              // TextFormField(
              //   controller: upiController,
              //   decoration: const InputDecoration(
              //     labelText: "UPI ID (optional)",
              //   ),
              // ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            foregroundColor: AppColors.orangeLight,
          ),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.liveRates,
              (route) => false,
            );
          },
          child: const Text("Back to Home", style: TextStyle(fontSize: 18)),
        ),
        CustomButton(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          text: "Save",
          isLoading: loading,
          onPressed: loading ? null : save,
        ),
      ],
    );
  }
}
