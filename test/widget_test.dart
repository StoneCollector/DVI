// Widget tests for DreamVentz
// Testing utility functions and validators without requiring full app initialization

import 'package:flutter_test/flutter_test.dart';
import 'package:dreamventz/utils/validators.dart';

void main() {
  group('Email Validation Tests', () {
    test('Valid email addresses pass validation', () {
      expect(Validators.validateEmail('test@example.com'), null);
      expect(Validators.validateEmail('user.name@domain.com'), null);
      expect(Validators.validateEmail('user+tag@example.co.uk'), null);
    });

    test('Empty email shows error', () {
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail(null), 'Email is required');
    });

    test('Invalid email format shows error', () {
      expect(
        Validators.validateEmail('invalid-email'),
        'Please enter a valid email address',
      );
      expect(
        Validators.validateEmail('missing@domain'),
        'Please enter a valid email address',
      );
      expect(
        Validators.validateEmail('@example.com'),
        'Please enter a valid email address',
      );
    });
  });

  group('Password Validation Tests', () {
    test('Valid passwords pass validation', () {
      expect(Validators.validatePassword('Password123'), null);
      expect(Validators.validatePassword('MyP@ssw0rd'), null);
      expect(Validators.validatePassword('SecurePass1'), null);
    });

    test('Empty password shows error', () {
      expect(Validators.validatePassword(''), 'Password is required');
      expect(Validators.validatePassword(null), 'Password is required');
    });

    test('Short password shows error', () {
      expect(
        Validators.validatePassword('Pass1'),
        'Password must be at least 8 characters',
      );
    });

    test('Password without uppercase shows error', () {
      expect(Validators.validatePassword('password123'), contains('uppercase'));
    });

    test('Password without lowercase shows error', () {
      expect(Validators.validatePassword('PASSWORD123'), contains('lowercase'));
    });

    test('Password without number shows error', () {
      expect(Validators.validatePassword('PasswordOnly'), contains('number'));
    });
  });

  group('Name Validation Tests', () {
    test('Valid names pass validation', () {
      expect(Validators.validateName('John Doe'), null);
      expect(Validators.validateName('Jane Smith'), null);
    });

    test('Empty name shows error', () {
      expect(Validators.validateName(''), 'Name is required');
      expect(Validators.validateName(null), 'Name is required');
    });
  });

  group('Phone Validation Tests', () {
    test('Valid phone numbers pass validation', () {
      expect(Validators.validatePhone('+1234567890'), null);
      expect(Validators.validatePhone('1234567890'), null);
      expect(Validators.validatePhone('+91 9876543210'), null);
    });

    test('Empty phone is allowed (optional field)', () {
      expect(Validators.validatePhone(''), null);
      expect(Validators.validatePhone(null), null);
    });

    test('Invalid phone format shows error', () {
      expect(
        Validators.validatePhone('123'), // Too short
        'Please enter a valid phone number',
      );
      expect(
        Validators.validatePhone('abc123'),
        'Please enter a valid phone number',
      );
    });
  });

  group('Confirm Password Validation Tests', () {
    test('Matching passwords pass validation', () {
      expect(
        Validators.validateConfirmPassword('Password123', 'Password123'),
        null,
      );
    });

    test('Empty confirm password shows error', () {
      expect(
        Validators.validateConfirmPassword('', 'Password123'),
        'Please confirm your password',
      );
      expect(
        Validators.validateConfirmPassword(null, 'Password123'),
        'Please confirm your password',
      );
    });

    test('Mismatched passwords show error', () {
      expect(
        Validators.validateConfirmPassword('Password123', 'DifferentPass'),
        'Passwords do not match',
      );
    });
  });
}
