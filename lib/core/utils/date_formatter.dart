import 'package:intl/intl.dart';

/// Date formatting utilities
class DateFormatter {
  // Date formats
  static const String ddMMMyyyy = 'dd MMM yyyy'; // 08 Dec 2025
  static const String ddMMMyyyyHHmm =
      'dd MMM yyyy, HH:mm'; // 08 Dec 2025, 14:54
  static const String yyyyMMdd = 'yyyy-MM-dd'; // 2025-12-08
  static const String ddMMyyyy = 'dd/MM/yyyy'; // 08/12/2025
  static const String HHmmss = 'HH:mm:ss'; // 14:54:30
  static const String HHmm = 'HH:mm'; // 14:54
  static const String EEEddMMM = 'EEE, dd MMM'; // Mon, 08 Dec
  static const String MMMMyyyy = 'MMMM yyyy'; // December 2025
  static const String ddMMMMyyyyHHmmss =
      'dd MMMM yyyy HH:mm:ss'; // 08 December 2025 14:54:30

  /// Format date to 'dd MMM yyyy' (08 Dec 2025)
  static String formatDate(DateTime date) {
    return DateFormat(ddMMMyyyy).format(date);
  }

  /// Format date to 'dd/MM/yyyy' (08/12/2025)
  static String formatDateSlash(DateTime date) {
    return DateFormat(ddMMyyyy).format(date);
  }

  /// Format date to 'yyyy-MM-dd' (2025-12-08) - for API
  static String formatDateForApi(DateTime date) {
    return DateFormat(yyyyMMdd).format(date);
  }

  /// Format date with time 'dd MMM yyyy, HH:mm' (08 Dec 2025, 14:54)
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(ddMMMyyyyHHmm).format(dateTime);
  }

  /// Format time only 'HH:mm' (14:54)
  static String formatTime(DateTime dateTime) {
    return DateFormat(HHmm).format(dateTime);
  }

  /// Format time with seconds 'HH:mm:ss' (14:54:30)
  static String formatTimeWithSeconds(DateTime dateTime) {
    return DateFormat(HHmmss).format(dateTime);
  }

  /// Format to day and date 'EEE, dd MMM' (Mon, 08 Dec)
  static String formatDayDate(DateTime date) {
    return DateFormat(EEEddMMM).format(date);
  }

  /// Format to month and year 'MMMM yyyy' (December 2025)
  static String formatMonthYear(DateTime date) {
    return DateFormat(MMMMyyyy).format(date);
  }

  /// Format full date time 'dd MMMM yyyy HH:mm:ss'
  static String formatFullDateTime(DateTime dateTime) {
    return DateFormat(ddMMMMyyyyHHmmss).format(dateTime);
  }

  /// Get relative time (e.g., "2 hours ago", "Yesterday", "Just now")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Parse string to DateTime (yyyy-MM-dd format)
  static DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateFormat(yyyyMMdd).parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Parse string to DateTime (ISO 8601 format)
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get difference in days
  static int daysBetween(DateTime from, DateTime to) {
    from = startOfDay(from);
    to = startOfDay(to);
    return to.difference(from).inDays;
  }

  /// Format attendance date range (for reports)
  static String formatDateRange(DateTime start, DateTime end) {
    if (isToday(start) && isToday(end)) {
      return 'Today';
    } else if (start.year == end.year && start.month == end.month) {
      // Same month: "1-15 Dec 2025"
      return '${start.day}-${end.day} ${DateFormat('MMM yyyy').format(end)}';
    } else if (start.year == end.year) {
      // Same year: "1 Dec - 15 Jan 2025"
      return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
    } else {
      // Different years: "1 Dec 2024 - 15 Jan 2025"
      return '${DateFormat('dd MMM yyyy').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
    }
  }

  /// Get month name
  static String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Get day name
  static String getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }
}
