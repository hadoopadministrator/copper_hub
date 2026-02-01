import 'package:flutter/material.dart';

class AppDecorations {
  static InputDecoration textField({
    required String label,
    String? counterText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      counterText: counterText,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(fontSize: 16, color: Colors.grey[600]),
      floatingLabelStyle: const TextStyle(color: Colors.black, fontSize: 18),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}
