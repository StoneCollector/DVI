import 'package:flutter/material.dart';

/// OAuth provider button widget with consistent styling
class OAuthButton extends StatelessWidget {
  final String provider; // 'google' or 'facebook'
  final VoidCallback onPressed;
  final bool isLoading;

  const OAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getProviderConfig();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.grey[700]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0x0DFFFFFF), // Subtle white tint
        ),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Image.asset(
                config['icon']!,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to colored icon if asset not found
                  return Icon(
                    Icons.account_circle,
                    color: config['color'] as Color,
                    size: 24,
                  );
                },
              ),
        label: Text(
          config['label']!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getProviderConfig() {
    switch (provider.toLowerCase()) {
      case 'google':
        return {
          'label': 'Continue with Google',
          'icon': 'assets/google_logo.png', // You'll need to add this asset
          'color': Colors.red,
        };
      case 'facebook':
        return {
          'label': 'Continue with Facebook',
          'icon': 'assets/facebook_logo.png', // You'll need to add this asset
          'color': const Color(0xFF1877F2),
        };
      default:
        return {'label': 'Continue', 'icon': '', 'color': Colors.grey};
    }
  }
}
