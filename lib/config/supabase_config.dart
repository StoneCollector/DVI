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

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception(
          'Supabase credentials not found in .env file. '
          'Please ensure SUPABASE_URL and SUPABASE_ANON_KEY are set.',
        );
      }

      if (supabaseUrl.contains('your_supabase') ||
          supabaseAnonKey.contains('your_supabase')) {
        throw Exception(
          'Please replace the placeholder Supabase credentials in .env file '
          'with your actual project credentials from https://app.supabase.com',
        );
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
      debugPrint('❌ Supabase initialization failed: $e');
      rethrow;
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
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
