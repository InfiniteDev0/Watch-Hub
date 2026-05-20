// Form validation helpers
/// Form validation utilities
class Validators {
  Validators._();

  // ==================== EMAIL VALIDATION ====================
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email';
    }

    return null; // Valid
  }

  // ==================== PASSWORD VALIDATION ====================
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null; // Valid
  }

  // ==================== CONFIRM PASSWORD VALIDATION ====================
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null; // Valid
  }

  // ==================== OTP VALIDATION ====================
  static String? validateOTP(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter OTP';
    }

    if (value.trim().length != 5) {
      return 'OTP must be 5 digits';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'OTP must contain only numbers';
    }

    return null; // Valid
  }

  // ==================== REQUIRED FIELD VALIDATION ====================
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}
