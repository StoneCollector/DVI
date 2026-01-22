/// Application-wide constants
class AppConstants {
  // Route names
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String homeRoute = '/home';

  // Error messages
  static const String networkError =
      'Network error. Please check your internet connection.';
  static const String unknownError =
      'An unexpected error occurred. Please try again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String emailAlreadyExists =
      'An account with this email already exists.';
  static const String weakPassword =
      'Password is too weak. Please use a stronger password.';
  static const String emailNotVerified =
      'Please verify your email before logging in.';
  static const String sessionExpired =
      'Your session has expired. Please login again.';

  // Success messages
  static const String signupSuccess =
      'Account created successfully! Please check your email for verification.';
  static const String loginSuccess = 'Welcome back!';
  static const String passwordResetEmailSent =
      'Password reset link has been sent to your email.';
  static const String passwordResetSuccess = 'Password reset successfully!';
  static const String logoutSuccess = 'Logged out successfully.';

  // Validation rules
  static const int passwordMinLength = 8;
  static const int nameMinLength = 2;
  static const int phoneMinLength = 10;

  // Regex patterns
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phonePattern = RegExp(
    r'^\+?[1-9]\d{1,14}$', // International phone format
  );
  static final RegExp namePattern = RegExp(
    r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$",
  );

  // Storage keys
  static const String rememberMeKey = 'remember_me';
  static const String savedEmailKey = 'saved_email';
  static const String userCacheKey = 'user_cache';
}
