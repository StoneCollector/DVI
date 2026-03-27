import os

# 1. Update login_screen.dart
f_path = 'lib/screens/auth/login_screen.dart'
with open(f_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
content = content.replace(
    "import '../../utils/validators.dart';",
    "import '../../utils/validators.dart';\nimport '../../components/oauth_button.dart';"
)

# Add logic methods
logic_methods = """  Future<void> _handleGoogleSignIn() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() => _isLoading = true);
      await _authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("Google Sign-In failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleFacebookSignIn() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() => _isLoading = true);
      await _authService.signInWithFacebook();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text("Facebook Sign-In failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle login button press"""

content = content.replace("  /// Handle login button press", logic_methods)

# Add UI
ui_injection = """                            // OAuth Buttons
                            OAuthButton(
                              provider: 'google',
                              isLoading: _isLoading,
                              onPressed: _handleGoogleSignIn,
                            ),
                            const SizedBox(height: 12),
                            OAuthButton(
                              provider: 'facebook',
                              isLoading: _isLoading,
                              onPressed: _handleFacebookSignIn,
                            ),
                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.grey[700])),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.grey[700])),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Email Field"""

content = content.replace("                            // Email Field", ui_injection)

with open(f_path, 'w', encoding='utf-8', newline='') as f:
    f.write(content)

# 2. Update signup_screen.dart
f_path2 = 'lib/screens/auth/signup_screen.dart'
with open(f_path2, 'r', encoding='utf-8') as f:
    content2 = f.read()

# Add import
content2 = content2.replace(
    "import '../../utils/validators.dart';",
    "import '../../utils/validators.dart';\nimport '../../components/oauth_button.dart';"
)

# Add logic methods
logic_methods2 = """  Future<void> _handleGoogleSignIn() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() => _isLoading = true);
      await AuthService().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleFacebookSignIn() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      setState(() => _isLoading = true);
      await AuthService().signInWithFacebook();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Facebook Sign-In failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handle signup button press"""

content2 = content2.replace("  /// Handle signup button press", logic_methods2)

# Add UI
ui_injection2 = """                            const SizedBox(height: 24),

                            // ── OR Divider ────────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: Colors.grey[700]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: Colors.grey[700]),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ── OAuth Buttons ──────────────────────────────
                            OAuthButton(
                              provider: 'google',
                              isLoading: _isLoading,
                              onPressed: _handleGoogleSignIn,
                            ),
                            const SizedBox(height: 12),
                            OAuthButton(
                              provider: 'facebook',
                              isLoading: _isLoading,
                              onPressed: _handleFacebookSignIn,
                            ),

                            const SizedBox(height: 32),

                            // Login Prompt"""

content2 = content2.replace("                            const SizedBox(height: 32),\n\n                            // Login Prompt", ui_injection2)

with open(f_path2, 'w', encoding='utf-8', newline='') as f:
    f.write(content2)

print('Successfully patched UI pieces')
