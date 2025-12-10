class StorageKeys {
  // Secure storage keys (for sensitive data)
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String schoolId = 'school_id';
  static const String authToken = 'auth_token';

  // Shared preferences keys (for non-sensitive data)
  static const String isFirstLaunch = 'is_first_launch';
  static const String language = 'language';
  static const String theme = 'theme';
  static const String lastSyncTime = 'last_sync_time';
  static const String notificationsEnabled = 'notifications_enabled';

  // Firebase-specific
  static const String firebaseToken = 'firebase_token';
  static const String isLoggedIn = 'is_logged_in';
  static const String firstLogin = 'first_login';
}
