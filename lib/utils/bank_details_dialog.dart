import 'package:copper_hub/routes/app_routes.dart';
import 'package:copper_hub/utils/app_colors.dart';
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
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
     title: Text(
        accountNumberController.text.isEmpty
            ? "Add Bank Details"
            : "Update Bank Details",
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
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Account Number"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: confirmAccountNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Confirm Account Number",
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Confirm account number required";
                  }

                  if (v != accountNumberController.text) {
                    return "Account numbers do not match";
                  }

                  return null;
                },
              ),

              TextFormField(
                controller: ifscController,
                decoration: const InputDecoration(labelText: "IFSC Code"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: bankNameController,
                decoration: const InputDecoration(labelText: "Bank Name"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
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
          text: loading ? '' : "Save",
          onPressed: loading ? null : save,
        ),
      ],
    );
  }
}
