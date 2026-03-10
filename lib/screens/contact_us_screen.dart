import 'package:copper_hub/utils/app_colors.dart';
import 'package:copper_hub/utils/input_decoration.dart';
import 'package:copper_hub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _isSending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
    });

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String subject = _subjectController.text.trim();
    final String message = _messageController.text.trim();

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@company.com',
      queryParameters: {
        'subject': subject,
        'body': 'Name: $name\nEmail: $email\n\nMessage:\n$message',
      },
    );

    try {
      final bool canLaunch = await canLaunchUrl(emailUri);

      if (!mounted) return;

      if (canLaunch) {
        await launchUrl(emailUri);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email app opened. Please press send to deliver your message.',
            ),
          ),
        );

        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email app found on this device')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to open email app')));
    }

    if (!mounted) return;

    setState(() {
      _isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Contact Us")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Get in Touch",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "If you have any questions, feedback or need support, feel free to contact us."
                  "Our team will get back to you as soon as possible.",
                  // textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Send us a message",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  cursorColor: AppColors.black,
                  autofillHints: const [AutofillHints.name],
                  decoration: AppDecorations.textField(label: 'Your Name'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectController,
                  textInputAction: TextInputAction.next,
                  cursorColor: AppColors.black,
                  decoration: AppDecorations.textField(label: "Subject"),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Subject is required'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  cursorColor: AppColors.black,
                  maxLines: 4,
                  decoration: AppDecorations.textField(label: "Your Message"),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Message is required'
                      : null,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: _isSending ? 'Opening Mail...' : 'Send Message',
                  backgroundColor: AppColors.orangeDark,
                  foregroundColor: AppColors.white,
                  width: double.infinity,
                  onPressed: _isSending ? null : _sendEmail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
