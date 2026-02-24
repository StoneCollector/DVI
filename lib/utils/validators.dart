import '../utils/constants.dart';

/// Form validation utilities
class Validators {
  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!AppConstants.emailPattern.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.passwordMinLength) {
      return 'Password must be at least ${AppConstants.passwordMinLength} characters';
    }

    // Check password strength
    bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = value.contains(RegExp(r'[a-z]'));
    bool hasDigit = value.contains(RegExp(r'[0-9]'));
    // ignore: unused_local_variable
    bool hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUppercase || !hasLowercase || !hasDigit) {
      return 'Password must contain uppercase, lowercase, and numbers';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate full name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < AppConstants.nameMinLength) {
      return 'Name must be at least ${AppConstants.nameMinLength} characters';
    }

    if (!AppConstants.namePattern.hasMatch(value)) {
      return 'Please enter a valid name';
    }

    return null;
  }

  /// Validate phone number (optional field)
  static String? validatePhone(String? value) {
    // Phone is optional, so allow empty
    if (value == null || value.isEmpty) {
      return null;
    }

    // Remove spaces, dashes, and any non-digit characters except +
    String cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Remove + prefix if present
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    
    // Remove country code if present (assuming it starts with country code like +91, +1 etc)
    // Extract only digits
    String digitsOnly = cleaned.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }

    return null;
  }

  /// Generic required field validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Get password strength (0-4)
  /// 0 = Very Weak, 1 = Weak, 2 = Fair, 3 = Good, 4 = Strong
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Character variety checks
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    // Cap at 4
    return strength > 4 ? 4 : strength;
  }

  /// Get password strength description
  static String getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return '';
    }
  }
}
