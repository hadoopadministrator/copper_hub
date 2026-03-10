class Validators {
  static String? fullName(String? value) {
    if (value == null || value.trim().length < 2) return 'Enter a valid name';
    if (!RegExp(r'^[a-zA-Z ]{2,50}$').hasMatch(value.trim())) {
      return 'Name can contain only letters and spaces';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null) return 'Email is required';

    final email = value.trim();

    final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$');

    if (!regex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.trim().length != 10) {
      return 'Mobile number must be 10 digits';
    }
    // optional stronger check (commented if you want later)
    // if (!RegExp(r'^[6-9]\d{9}$').hasMatch(input)) {
    //   return 'Enter valid mobile number';
    // }

    return null;
  }

  static String? otp(String? value) {
    if (value == null || !RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
      return 'Please enter valid 6 digit OTP';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }
  // static String? password(String? value) {
  //   if (value == null || value.length < 8) return 'Password must be at least 8 characters';
  //   final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
  //   if (!regex.hasMatch(value)) {
  //     return 'Must include uppercase, lowercase, number & special character';
  //   }
  //   return null;
  // }

  static String? confirmPassword(String? value, String password) {
    if (password.isEmpty && (value == null || value.isEmpty)) {
      return null;
    }
    if (value != password) {
      return "Passwords do not match";
    }
    return null;
  }

  static String? address(String? value) {
    if (value == null || value.trim().length < 5) {
      return 'Enter a valid address';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s,.-]{5,200}$').hasMatch(value.trim())) {
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
    if (value != null && value.trim().length > 100) {
      return 'Landmark too long';
    }
    return null;
  }

  static String? gst(String? value) {
    final gst = value?.trim().toUpperCase();

    if (gst == null || gst.isEmpty) return null;

    final regex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$');

    if (!regex.hasMatch(gst)) {
      return 'Enter valid GST number';
    }

    return null;
  }

  static String? accountHolder(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[a-zA-Z\s.-]{3,50}$').hasMatch(value.trim())) {
      return 'Enter a valid account holder name';
    }
    return null;
  }

  static String? accountNumber(String? value) {
    if (value == null || value.isEmpty) return null;

    if (!RegExp(r'^[0-9]{8,18}$').hasMatch(value)) {
      return "Enter valid account number";
    }

    return null;
  }

  static String? confirmAccountNumber(String? value, String accountNumber) {
    if (accountNumber.isEmpty && (value == null || value.isEmpty)) {
      return null;
    }

    if (value != accountNumber) {
      return "Account numbers do not match";
    }

    return null;
  }

  static String? ifsc(String? value) {
    if (value == null || value.isEmpty) return null;

    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) {
      return "Enter valid IFSC code";
    }

    return null;
  }

  static String? bankName(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[a-zA-Z\s.-]{3,50}$').hasMatch(value.trim())) {
      return 'Enter a valid bank name';
    }
    return null;
  }

  /// Login screen validator
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
      final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[a-zA-Z]{2,}$');

      if (!emailRegex.hasMatch(input)) {
        return 'Enter valid email address';
      }
    }

    return null;
  }
}
