class Validators {

  static String? fullName(String? value) {
    final input = value?.trim() ?? '';

    if (input.length < 2) {
      return 'Enter a valid name';
    }

    if (!RegExp(r'^[a-zA-Z ]{2,50}$').hasMatch(input)) {
      return 'Name can contain only letters and spaces';
    }

    return null;
  }

  static String? email(String? value) {
    final input = value?.trim() ?? '';

    if (input.isEmpty) {
      return 'Email is required';
    }

    final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$');

    if (!regex.hasMatch(input)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? mobile(String? value) {
    final input = value?.trim() ?? '';

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(input)) {
      return 'Enter valid mobile number';
    }

    return null;
  }

  static String? otp(String? value) {
    final input = value?.trim() ?? '';

    if (!RegExp(r'^[0-9]{6}$').hasMatch(input)) {
      return 'Please enter valid 6 digit OTP';
    }

    return null;
  }

  static String? password(String? value) {
    final input = value ?? '';

    if (input.length < 8) {
      return 'Password must be at least 8 characters';
    }

    final regex =
        RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');

    if (!regex.hasMatch(input)) {
      return 'Must include uppercase, lowercase, number & special character';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value != password) {
      return "Passwords do not match";
    }

    return null;
  }

  static String? address(String? value) {
    final input = value?.trim() ?? '';

    if (input.length < 5) {
      return 'Enter a valid address';
    }

    if (!RegExp(r'^[a-zA-Z0-9\s,.-]{5,200}$').hasMatch(input)) {
      return 'Address contains invalid characters';
    }

    return null;
  }

  static String? pincode(String? value) {
    final input = value?.trim() ?? '';

    if (!RegExp(r'^[0-9]{6}$').hasMatch(input)) {
      return 'Pincode must be 6 digits';
    }

    return null;
  }

  static String? landmark(String? value) {
    final input = value?.trim() ?? '';

    if (input.length > 100) {
      return 'Landmark too long';
    }

    return null;
  }

  static String? gst(String? value) {
    final gst = value?.trim().toUpperCase() ?? '';

    if (gst.isEmpty) return null;

    final regex = RegExp(
        r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$');

    if (!regex.hasMatch(gst)) {
      return 'Enter valid GST number';
    }

    return null;
  }

  static String? accountHolder(String? value) {
    final input = value?.trim() ?? '';

    if (input.isEmpty) return null;

    if (!RegExp(r'^[a-zA-Z\s.-]{3,50}$').hasMatch(input)) {
      return 'Enter a valid account holder name';
    }

    return null;
  }

  static String? accountNumber(String? value) {
    final input = value ?? '';

    if (input.isEmpty) return null;

    if (!RegExp(r'^[0-9]{8,18}$').hasMatch(input)) {
      return "Enter valid account number";
    }

    return null;
  }

  static String? confirmAccountNumber(String? value, String accountNumber) {
    if (value != accountNumber) {
      return "Account numbers do not match";
    }

    return null;
  }

  static String? ifsc(String? value) {
    final input = value ?? '';

    if (input.isEmpty) return null;

    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(input)) {
      return "Enter valid IFSC code";
    }

    return null;
  }

  static String? bankName(String? value) {
    final input = value?.trim() ?? '';

    if (input.isEmpty) return null;

    if (!RegExp(r'^[a-zA-Z\s.-]{3,50}$').hasMatch(input)) {
      return 'Enter a valid bank name';
    }

    return null;
  }

  static String? emailOrMobile(String? value) {
    final input = value?.trim() ?? '';

    if (input.isEmpty) {
      return 'Email or mobile is required';
    }

    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(input);

    if (isNumeric) {
      if (input.length != 10) {
        return 'Mobile number must be 10 digits';
      }
    } else {
      final emailRegex =
          RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$');

      if (!emailRegex.hasMatch(input)) {
        return 'Enter valid email address';
      }
    }

    return null;
  }
}