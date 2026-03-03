import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:copper_hub/services/api_service.dart';

class BankDetailsDialog extends StatefulWidget {
  final int userId;
  final VoidCallback onSaved;

  const BankDetailsDialog({
    super.key,
    required this.userId,
    required this.onSaved,
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
  final upiController = TextEditingController();

  final api = ApiService();

  bool loading = false;

  Future<void> save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    // final result = await api.saveBankDetails(
    //   userId: widget.userId,
    //   accountHolderName: accountHolderController.text.trim(),
    //   accountNumber: accountNumberController.text.trim(),
    //   ifscCode: ifscController.text.trim(),
    //   bankName: bankNameController.text.trim(),
    //   upiId: upiController.text.trim(),
    // );

    setState(() => loading = false);

    // if (result['success']) {
    //   Navigator.pop(context);
    //   widget.onSaved();

    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Bank details saved successfully")),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Bank Details"),
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

              TextFormField(
                controller: upiController,
                decoration: const InputDecoration(
                  labelText: "UPI ID (optional)",
                ),
              ),
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
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.orangeDark,
          ),
          onPressed: () {},
          child: const Text("Required"),
        ),
        CustomButton(
          width: double.infinity,
          text: loading ? '' : "Save",
          onPressed: loading ? null : save,
        ),
        ElevatedButton(
          onPressed: loading ? null : save,
          child: loading
              ? const CircularProgressIndicator()
              : const Text("Save"),
        ),
      ],
    );
  }
}
