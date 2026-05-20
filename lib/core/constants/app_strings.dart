// All text strings for the app
/// All text strings used in the app
/// Centralized for easy localization later
class AppStrings {
  AppStrings._();

  // ==================== ONBOARDING ====================
  static const String appName = 'Watch Hub';
  static const String onboardingSubtitle =
      'Log in or sign up to your WH account to access our watches';
  static const String loginButton = 'Log in';
  static const String signupButton = 'Sign up';

  // ==================== LOGIN ====================
  static const String loginTitle = 'Log in to your WH account';
  static const String loginSubtitle =
      'Enter your email and password to log in.';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String forgotPassword = 'Forgot password';

  // ==================== SIGNUP ====================
  static const String signupTitle = 'Create your WH account';
  static const String signupSubtitle =
      'Enter your email and password to register.';
  static const String confirmPasswordLabel = 'Confirm Password';

  // ==================== OTP ====================
  static const String otpTitle = 'We have sent an OTP to you';
  static const String otpSubtitle =
      'check your registered email for the otp message';
  static const String resendCode = 'Resend code';
  static const String continueButton = 'Continue';

  // ==================== RESET PASSWORD ====================
  static const String resetPasswordTitle = 'Reset your WH password';
  static const String resetPasswordSubtitle =
      'Enter your new password and confirm';
  static const String newPasswordLabel = 'New Password';
  static const String resetPasswordButton = 'Reset password';
  static const String goBackToLogin = 'Go back to login page';

  // ==================== VALIDATION MESSAGES ====================
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String otpRequired = 'Please enter OTP';
  static const String otpInvalid = 'OTP must be 5 digits';

  // ==================== DEMO CREDENTIALS ====================
  static const String demoEmail = 'demo@watchhub.com';
  static const String demoPassword = 'Demo@123';
}
