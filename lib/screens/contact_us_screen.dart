import 'package:flutter/material.dart';
import 'package:wealth_bridge_impex/utils/app_colors.dart';
import 'package:wealth_bridge_impex/utils/input_decoration.dart';
import 'package:wealth_bridge_impex/widgets/custom_button.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Contact Us"),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                Text(
                  "Get in Touch",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  "If you have any questions, feedback or need support, feel free to contact us. "
                  "Our team will get back to you as soon as possible.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  "Send us a message",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  cursorColor: AppColors.black,
                  autofillHints: const [AutofillHints.name],
                  decoration: AppDecorations.textField(label: 'Your Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  cursorColor: AppColors.black,
                  autofillHints: const [AutofillHints.email],
                  decoration: AppDecorations.textField(label: "Your Email"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _subjectController,
                  textInputAction: TextInputAction.next,
                  cursorColor: AppColors.black,
                  decoration: AppDecorations.textField(label: "Subject"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Subject is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _messageController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  cursorColor: AppColors.black,
                  maxLines: 4,
                  decoration: AppDecorations.textField(label: "Your Message"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Message is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Send Message',
                  backgroundColor: AppColors.orangeDark,
                  foregroundColor: AppColors.white,
                  width: double.infinity,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // final name = _nameController.text.trim();
                      // final email = _emailController.text.trim();
                      // final subject = _subjectController.text.trim();
                      // final message = _messageController.text.trim();
                    }
                  },
                ),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: const Color(0xffF9B236),
                //       foregroundColor: Colors.black,
                //       padding: const EdgeInsets.symmetric(vertical: 16.0),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8.0),
                //       ),
                //     ),
                //     onPressed: () {
                //       if (_formKey.currentState!.validate()) {
                //         // final name = _nameController.text.trim();
                //         // final email = _emailController.text.trim();
                //         // final subject = _subjectController.text.trim();
                //         // final message = _messageController.text.trim();
                //       }
                //     },
                //     child: const Text("Send Message"),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
