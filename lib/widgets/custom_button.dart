import 'package:copper_hub/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final Color foregroundColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.padding,
    this.backgroundColor = AppColors.orangeDark,
    this.foregroundColor = AppColors.black,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: isDisabled ? Colors.grey : backgroundColor,
          foregroundColor: foregroundColor,
        ),
        onPressed: isDisabled ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDisabled
                      ? AppColors.black.withValues(alpha: 0.38)
                      : foregroundColor,
                ),
              )
            : Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
