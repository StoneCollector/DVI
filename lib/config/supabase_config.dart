import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and initialization
class SupabaseConfig {
  // ignore: unused_field
  static SupabaseClient? _client;
  static bool _initialized = false;

  /// Initialize Supabase with credentials from .env file
  /// This should be called once in main() before runApp()
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('Supabase already initialized');
      return;
    }

    try {
      // Load environment variables
      await dotenv.load(fileName: '.env');

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      // If credentials are missing or empty, log warning but allow app to continue
      if (supabaseUrl == null || supabaseAnonKey == null) {
        debugPrint(
          '⚠️  Supabase credentials not found in .env file. '
          'Some features may not work. Please ensure SUPABASE_URL and SUPABASE_ANON_KEY are set.',
        );
        _initialized = true; // Mark as initialized to allow UI to render
        return;
      }

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        debugPrint(
          '⚠️  Supabase credentials are empty in .env file. '
          'Some features may not work. Please set SUPABASE_URL and SUPABASE_ANON_KEY.',
        );
        _initialized = true; // Mark as initialized to allow UI to render
        return;
      }

      if (supabaseUrl.contains('your_supabase') ||
          supabaseAnonKey.contains('your_supabase')) {
        debugPrint(
          '⚠️  Placeholder Supabase credentials detected. '
          'Please replace them with your actual project credentials from https://app.supabase.com',
        );
        _initialized = true; // Mark as initialized to allow UI to render
        return;
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce, // More secure auth flow
          autoRefreshToken: true, // Automatically refresh tokens
        ),
      );

      _initialized = true;
      debugPrint('✅ Supabase initialized successfully');
    } catch (e) {
      debugPrint('❌ Supabase initialization error: $e');
      // Mark as initialized anyway to allow app to continue
      _initialized = true;
    }
  }

  /// Get the Supabase client instance
  /// Throws if Supabase hasn't been initialized
  static SupabaseClient get client {
    if (!_initialized) {
      throw Exception(
        'Supabase not initialized. Call SupabaseConfig.initialize() first.',
      );
    }
    return Supabase.instance.client;
  }

  /// Check if Supabase is initialized
  static bool get isInitialized => _initialized;

  /// Get current auth state
  static User? get currentUser {
    try {
      if (!_initialized) {
        return null;
      }
      return Supabase.instance.client.auth.currentUser;
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Check if user is authenticated
  static bool get isAuthenticated {
    try {
      return currentUser != null;
    } catch (e) {
      debugPrint('Error checking authentication: $e');
      return false;
    }
  }
}
