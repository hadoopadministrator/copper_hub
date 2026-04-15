import 'package:flutter/material.dart';

class AppDecorations {
  static InputDecoration textField({
    required String label,
    String? counterText,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      labelText: label,
      counterText: counterText,
      suffixIcon: suffixIcon,
      isDense: true,
      contentPadding: contentPadding,
    );
  }
}
