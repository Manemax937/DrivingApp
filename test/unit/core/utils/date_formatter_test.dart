import 'package:driveapp/core/utils/date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFormatter Tests', () {
    test('formatDate should format date correctly', () {
      // Arrange
      final date = DateTime(2025, 12, 8);

      // Act
      final result = DateFormatter.formatDate(date);

      // Assert
      expect(result, '08 Dec 2025');
    });

    test('formatDateForApi should format date for API', () {
      // Arrange
      final date = DateTime(2025, 12, 8);

      // Act
      final result = DateFormatter.formatDateForApi(date);

      // Assert
      expect(result, '2025-12-08');
    });

    test('formatTime should format time correctly', () {
      // Arrange
      final dateTime = DateTime(2025, 12, 8, 14, 30);

      // Act
      final result = DateFormatter.formatTime(dateTime);

      // Assert
      expect(result, '14:30');
    });

    test('isToday should return true for today\'s date', () {
      // Arrange
      final today = DateTime.now();

      // Act
      final result = DateFormatter.isToday(today);

      // Assert
      expect(result, isTrue);
    });

    test('isToday should return false for yesterday\'s date', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      // Act
      final result = DateFormatter.isToday(yesterday);

      // Assert
      expect(result, isFalse);
    });

    test('daysBetween should calculate days correctly', () {
      // Arrange
      final start = DateTime(2025, 12, 1);
      final end = DateTime(2025, 12, 8);

      // Act
      final result = DateFormatter.daysBetween(start, end);

      // Assert
      expect(result, 7);
    });

    test('getRelativeTime should return "Just now" for recent time', () {
      // Arrange
      final recentTime = DateTime.now().subtract(const Duration(seconds: 30));

      // Act
      final result = DateFormatter.getRelativeTime(recentTime);

      // Assert
      expect(result, 'Just now');
    });

    test('getRelativeTime should return minutes ago', () {
      // Arrange
      final minutesAgo = DateTime.now().subtract(const Duration(minutes: 5));

      // Act
      final result = DateFormatter.getRelativeTime(minutesAgo);

      // Assert
      expect(result, '5 minutes ago');
    });

    test('parseDate should parse valid date string', () {
      // Arrange
      const dateString = '2025-12-08';

      // Act
      final result = DateFormatter.parseDate(dateString);

      // Assert
      expect(result, isNotNull);
      expect(result!.year, 2025);
      expect(result.month, 12);
      expect(result.day, 8);
    });

    test('parseDate should return null for invalid date string', () {
      // Arrange
      const invalidDateString = 'invalid-date';

      // Act
      final result = DateFormatter.parseDate(invalidDateString);

      // Assert
      expect(result, isNull);
    });
  });
}
