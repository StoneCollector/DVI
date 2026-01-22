import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

/// Authentication service for user authentication operations
/// Handles login, signup, password reset, and session management
class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Sign up a new user
  /// Password is automatically hashed by Supabase (bcrypt) - never transmitted in plain text
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password, // Supabase automatically hashes this with bcrypt
        data: {'full_name': fullName, 'phone': phone},
      );

      if (response.user != null) {
        debugPrint('✅ User signed up: ${response.user!.id}');

        // Create user profile in profiles table
        // The trigger will handle this automatically, but we'll do it explicitly for control
        await _createUserProfile(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          phone: phone,
        );
      }

      return response;
    } on AuthException catch (e) {
      debugPrint('❌ Signup error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected signup error: $e');
      throw AppConstants.unknownError;
    }
  }

  /// Sign in an existing user
  /// Password is hashed before comparison - secure authentication
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password, // Supabase compares with hashed password
      );

      if (response.user != null) {
        debugPrint('✅ User signed in: ${response.user!.id}');

        // Cache user data for offline access
        await _cacheUserData(response.user!.id);
      }

      return response;
    } on AuthException catch (e) {
      debugPrint('❌ Login error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected login error: $e');
      throw AppConstants.unknownError;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();

      // Clear cached user data but keep other cached data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userCacheKey);

      debugPrint('✅ User signed out');
    } catch (e) {
      debugPrint('❌ Signout error: $e');
      throw AppConstants.unknownError;
    }
  }

  /// Send OTP to email for password reset
  /// Uses Supabase's email OTP for in-app verification
  Future<void> sendOtpForPasswordReset(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null, // We don't need redirect for in-app flow
      );

      debugPrint('✅ OTP sent to email: $email');
    } on AuthException catch (e) {
      debugPrint('❌ OTP send error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected OTP send error: $e');
      throw AppConstants.unknownError;
    }
  }

  /// Verify OTP and reset password
  /// This verifies the OTP code and updates the password in one flow
  Future<void> verifyOtpAndResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      // First verify the OTP
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.email,
      );

      if (response.user == null) {
        throw 'OTP verification failed';
      }

      debugPrint('✅ OTP verified successfully');

      // Now update the password
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));

      debugPrint('✅ Password reset successfully');

      // Sign out after password reset for security
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      debugPrint('❌ OTP verification/password reset error: ${e.message}');
      if (e.message.contains('Invalid') || e.message.contains('expired')) {
        throw 'Invalid or expired OTP code. Please try again.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      if (e is String) {
        throw e;
      }
      throw AppConstants.unknownError;
    }
  }

  /// Update user password
  /// Used after password reset verification
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));

      debugPrint('✅ Password updated successfully');
    } on AuthException catch (e) {
      debugPrint('❌ Password update error: ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Unexpected password update error: $e');
      throw AppConstants.unknownError;
    }
  }

  /// Get current authenticated user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _supabase.auth.currentUser != null;
  }

  /// Get current session
  Session? getCurrentSession() {
    return _supabase.auth.currentSession;
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  /// Create user profile in profiles table
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phone,
  }) async {
    try {
      await _supabase.from('profiles').insert({
        'id': userId,
        'full_name': fullName,
        'phone': phone,
        'role': 'user', // Default role
      });

      debugPrint('✅ User profile created');
    } catch (e) {
      debugPrint('⚠️ Profile creation error (may already exist): $e');
      // Don't throw - profile might be created by trigger
    }
  }

  /// Cache user data for offline access
  Future<void> _cacheUserData(String userId) async {
    try {
      // Fetch user profile
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Cache to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userCacheKey, jsonEncode(response));

      debugPrint('✅ User data cached for offline access');
    } catch (e) {
      debugPrint('⚠️ Failed to cache user data: $e');
      // Don't throw - caching is optional
    }
  }

  /// Get cached user data (for offline mode)
  Future<UserModel?> getCachedUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(AppConstants.userCacheKey);

      if (cachedData != null) {
        final json = jsonDecode(cachedData) as Map<String, dynamic>;
        return UserModel.fromJson(json);
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load cached user data: $e');
    }
    return null;
  }

  /// Handle authentication exceptions and convert to user-friendly messages
  String _handleAuthException(AuthException e) {
    switch (e.statusCode) {
      case '400':
        if (e.message.contains('Invalid login credentials')) {
          return AppConstants.invalidCredentials;
        }
        if (e.message.contains('User already registered')) {
          return AppConstants.emailAlreadyExists;
        }
        return e.message;
      case '422':
        return AppConstants.weakPassword;
      case '500':
        return AppConstants.unknownError;
      default:
        return e.message;
    }
  }
}
