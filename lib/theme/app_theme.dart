import 'package:copper_hub/utils/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.orangeDark,
      primary: AppColors.orangeDark,
      secondary: AppColors.orangeLight,
      error: AppColors.red,
    ),

    primaryColor: AppColors.orangeDark,
    scaffoldBackgroundColor: AppColors.background,

    // ================= ICON =================
    iconTheme: const IconThemeData(color: AppColors.textPrimary),

    // ================= APPBAR =================
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),

    // ================= DrAWER =================
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.background),

    // ================= LIST =================
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textPrimary,
      textColor: AppColors.textPrimary,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    ),

    // ================= PROGRESS =================
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.orangeDark,
      circularTrackColor: AppColors.border,
    ),

    // ================= DIVIDER =================
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),

    // ================= SNACKBAR =================
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.black,
      contentTextStyle: TextStyle(color: AppColors.white, fontSize: 14),
      behavior: SnackBarBehavior.floating,
    ),

    // ================= BUTTON =================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orangeDark,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.disabled,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // ================= INPUT =================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      // Label styles
      labelStyle: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
      floatingLabelStyle: const TextStyle(
        fontSize: 18,
        color: AppColors.textPrimary,
      ),

      // Default border
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      // Enabled border
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      // Focused border
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.orangeDark, width: 1.5),
      ),

      // Error border
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),

      // Focused error border
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    ),

    // ================= TEXT SELECTION =================
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.orangeDark,
      selectionColor: AppColors.orangeLight,
      selectionHandleColor: AppColors.orangeDark,
    ),

    // ================= TEXT =================
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),

      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),

      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
    ),

    // ================= CHECKBOX =================
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.orangeDark;
        }
        return AppColors.white;
      }),
      checkColor: WidgetStateProperty.all(AppColors.white),
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // ================= DIALOG =================
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // ================= TEXT BUTTON =================
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.orangeLight,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // ================= CARD =================
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
