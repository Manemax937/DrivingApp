import 'package:driveapp/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators Tests', () {
    group('validatePhone', () {
      test('should return null for valid phone number', () {
        // Arrange
        const validPhone = '9876543210';

        // Act
        final result = Validators.validatePhone(validPhone);

        // Assert
        expect(result, isNull);
      });

      test('should return error for phone starting with invalid digit', () {
        // Arrange
        const invalidPhone = '5876543210';

        // Act
        final result = Validators.validatePhone(invalidPhone);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('valid'));
      });

      test('should return error for phone with less than 10 digits', () {
        // Arrange
        const invalidPhone = '987654321';

        // Act
        final result = Validators.validatePhone(invalidPhone);

        // Assert
        expect(result, isNotNull);
      });

      test('should return error for empty phone', () {
        // Arrange
        const emptyPhone = '';

        // Act
        final result = Validators.validatePhone(emptyPhone);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('should return error for null phone', () {
        // Act
        final result = Validators.validatePhone(null);

        // Assert
        expect(result, isNotNull);
      });
    });

    group('validateEmail', () {
      test('should return null for valid email', () {
        // Arrange
        const validEmail = 'test@example.com';

        // Act
        final result = Validators.validateEmail(validEmail);

        // Assert
        expect(result, isNull);
      });

      test('should return null for empty email (optional)', () {
        // Arrange
        const emptyEmail = '';

        // Act
        final result = Validators.validateEmail(emptyEmail);

        // Assert
        expect(result, isNull);
      });

      test('should return error for invalid email format', () {
        // Arrange
        const invalidEmail = 'invalid-email';

        // Act
        final result = Validators.validateEmail(invalidEmail);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('valid'));
      });
    });

    group('validatePassword', () {
      test('should return null for valid strong password', () {
        // Arrange
        const validPassword = 'Test@1234';

        // Act
        final result = Validators.validatePassword(validPassword);

        // Assert
        expect(result, isNull);
      });

      test('should return error for password without uppercase', () {
        // Arrange
        const weakPassword = 'test@1234';

        // Act
        final result = Validators.validatePassword(weakPassword);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('uppercase'));
      });

      test('should return error for password without lowercase', () {
        // Arrange
        const weakPassword = 'TEST@1234';

        // Act
        final result = Validators.validatePassword(weakPassword);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('lowercase'));
      });

      test('should return error for password without number', () {
        // Arrange
        const weakPassword = 'Test@abcd';

        // Act
        final result = Validators.validatePassword(weakPassword);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('number'));
      });

      test('should return error for password without special character', () {
        // Arrange
        const weakPassword = 'Test1234';

        // Act
        final result = Validators.validatePassword(weakPassword);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('special'));
      });

      test('should return error for short password', () {
        // Arrange
        const shortPassword = 'Ts@1';

        // Act
        final result = Validators.validatePassword(shortPassword);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('8 characters'));
      });
    });

    group('validatePincode', () {
      test('should return null for valid 6-digit pincode', () {
        // Arrange
        const validPincode = '560001';

        // Act
        final result = Validators.validatePincode(validPincode);

        // Assert
        expect(result, isNull);
      });

      test('should return error for pincode with less than 6 digits', () {
        // Arrange
        const invalidPincode = '56001';

        // Act
        final result = Validators.validatePincode(invalidPincode);

        // Assert
        expect(result, isNotNull);
      });

      test('should return error for pincode with letters', () {
        // Arrange
        const invalidPincode = '56000A';

        // Act
        final result = Validators.validatePincode(invalidPincode);

        // Assert
        expect(result, isNotNull);
      });
    });

    group('validateAmount', () {
      test('should return null for valid amount', () {
        // Arrange
        const validAmount = '1500';

        // Act
        final result = Validators.validateAmount(validAmount);

        // Assert
        expect(result, isNull);
      });

      test('should return error for zero amount', () {
        // Arrange
        const zeroAmount = '0';

        // Act
        final result = Validators.validateAmount(zeroAmount);

        // Assert
        expect(result, isNotNull);
      });

      test('should return error for negative amount', () {
        // Arrange
        const negativeAmount = '-100';

        // Act
        final result = Validators.validateAmount(negativeAmount);

        // Assert
        expect(result, isNotNull);
      });
    });
  });
}
