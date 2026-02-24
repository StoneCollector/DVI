import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/navigation/main_navigation.dart';
import 'screens/welcome/welcome_page.dart';
import 'screens/home/home_page.dart';
import 'screens/bookings/bookings_screen.dart';
import 'screens/history/history_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/booking/book_package_screen.dart';
import 'screens/booking/book_service_screen.dart';
import 'screens/packages/filter_package_list_screen.dart';
import 'screens/packages/customize_package_page.dart';
import 'screens/services/coordination_service_page.dart';
import 'screens/vendors/vendor_categories_page.dart';
import 'utils/constants.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase from .env file
  await SupabaseConfig.initialize();

  runApp(const DreamVentzApp());
}

class DreamVentzApp extends StatelessWidget {
  const DreamVentzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DreamVentz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'sans-serif',
      ),
      // Check auth state and navigate accordingly
      home: const AuthWrapper(),
      routes: {
        AppConstants.loginRoute: (context) => const LoginScreen(),
        AppConstants.signupRoute: (context) => const SignUpScreen(),
        AppConstants.forgotPasswordRoute: (context) =>
            const ForgotPasswordScreen(),
        AppConstants.homeRoute: (context) => const MainNavigation(),
        '/homepage': (context) => const HomePage(),
        '/bookingspage': (context) => const BookingsScreen(),
        '/historypage': (context) => const HistoryPage(),
        '/profilepage': (context) => const ProfilePage(),
        '/bookpackage': (context) => const BookPackageScreen(),
        '/bookservice': (context) => const BookServiceScreen(),
        '/vendorcategories': (context) => const VendorCategoriesPage(),
        '/packages': (context) => const FilterPackageListScreen(),
        '/customize_package_page': (context) => const CustomizePackagePage(),
        '/coordination_service_page': (context) =>
            const CoordinationServicePage(),
      },
    );
  }
}

/// Wrapper to check authentication state on app start
/// Directs to login if not authenticated, home if authenticated
/// Shows splash screen while checking
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Wait a moment for any existing session to be restored
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Show splash screen while checking auth
      return const SplashScreen();
    }

    // Navigate based on auth state
    // If user is authenticated, go to home, otherwise login
    // Use try-catch to handle potential Supabase initialization failures
    try {
      if (SupabaseConfig.isAuthenticated) {
        return const MainNavigation();
      }
    } catch (e) {
      debugPrint('Error checking auth state: $e');
    }

    return const WelcomePage();
  }
}

/// Splash screen shown while app initializes
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF121212), Colors.black],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset('assets/icons/DV.png', width: 150),
              const SizedBox(height: 40),
              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[400]!),
              ),
              const SizedBox(height: 24),
              // App name
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Dream",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: "Ventz",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.amber[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
