import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Load remembered email if user checked "Remember Me" previously
  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;
    final savedEmail = prefs.getString(AppConstants.savedEmailKey) ?? '';

    if (rememberMe && savedEmail.isNotEmpty) {
      setState(() {
        _rememberMe = true;
        _emailController.text = savedEmail;
      });
    }
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Save email if remember me is checked
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.rememberMeKey, _rememberMe);
      if (_rememberMe) {
        await prefs.setString(
          AppConstants.savedEmailKey,
          _emailController.text.trim(),
        );
      } else {
        await prefs.remove(AppConstants.savedEmailKey);
      }

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppConstants.loginSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Navigate to home
        Navigator.pushReplacementNamed(context, AppConstants.homeRoute);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10),
          child: Image.asset('assets/icons/DV.png'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A0A), Color(0xFF121212), Colors.black],
          ),
        ),
        child: Stack(
          children: [
            // Background Elements
            Positioned(
              top: -size.height * 0.15,
              left: -size.width * 0.2,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -size.height * 0.1,
              right: -size.width * 0.1,
              child: Container(
                width: size.width * 0.6,
                height: size.width * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 40,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 30,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome Back",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Colors.amber[400],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Dream",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: "Ventz",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.amber[400],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Sign in to access your event dashboard",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Form Section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Email Field
                            _buildTextField(
                              label: "Email Address",
                              hint: "you@example.com",
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              validator: Validators.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 12),

                            // Password Field
                            _buildPasswordField(),

                            const SizedBox(height: 12),

                            // Remember Me & Forgot Password
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _rememberMe = !_rememberMe;
                                        });
                                      },
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: Colors.amber.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          color: _rememberMe
                                              ? Colors.amber
                                              : Colors.transparent,
                                        ),
                                        child: _rememberMe
                                            ? const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Colors.black,
                                              )
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Remember me",
                                      style: TextStyle(color: Colors.grey[400]),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppConstants.forgotPasswordRoute,
                                  ),
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: Colors.amber[400],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  disabledBackgroundColor: Colors.amber
                                      .withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.black,
                                              ),
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Sign In",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.black,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Sign Up Prompt
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "New to DreamVentz?",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppConstants.signupRoute,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.3),
                                  ),
                                  color: Colors.amber.withValues(alpha: 0.05),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Create Account",
                                      style: TextStyle(
                                        color: Colors.amber[400],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.amber[400],
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Footer Note
                      Center(
                        child: Text(
                          "By continuing, you agree to our Terms & Privacy Policy",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[300],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              prefixIcon: Icon(
                prefixIcon,
                color: Colors.amber.withValues(alpha: 0.7),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: TextStyle(
            color: Colors.grey[300],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: TextFormField(
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
            obscureText: !_isPasswordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.lock_outline,
                color: Colors.amber.withValues(alpha: 0.7),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[500],
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
