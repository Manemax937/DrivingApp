import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for secure storage (for sensitive data like tokens)
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

/// Provider for shared preferences (for non-sensitive data)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

/// Storage service that combines both secure and non-secure storage
class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _sharedPreferences;

  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences sharedPreferences,
  }) : _secureStorage = secureStorage,
       _sharedPreferences = sharedPreferences;

  // Secure storage methods (for tokens, passwords, etc.)
  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _secureStorage.deleteAll();
  }

  Future<Map<String, String>> readAll() async {
    return await _secureStorage.readAll();
  }

  // Shared preferences methods (for non-sensitive data)
  Future<bool> writeString(String key, String value) async {
    return await _sharedPreferences.setString(key, value);
  }

  String? readString(String key) {
    return _sharedPreferences.getString(key);
  }

  Future<bool> writeBool(String key, bool value) async {
    return await _sharedPreferences.setBool(key, value);
  }

  bool? readBool(String key) {
    return _sharedPreferences.getBool(key);
  }

  Future<bool> writeInt(String key, int value) async {
    return await _sharedPreferences.setInt(key, value);
  }

  int? readInt(String key) {
    return _sharedPreferences.getInt(key);
  }

  Future<bool> writeDouble(String key, double value) async {
    return await _sharedPreferences.setDouble(key, value);
  }

  double? readDouble(String key) {
    return _sharedPreferences.getDouble(key);
  }

  Future<bool> writeStringList(String key, List<String> value) async {
    return await _sharedPreferences.setStringList(key, value);
  }

  List<String>? readStringList(String key) {
    return _sharedPreferences.getStringList(key);
  }

  Future<bool> remove(String key) async {
    return await _sharedPreferences.remove(key);
  }

  Future<bool> clear() async {
    return await _sharedPreferences.clear();
  }

  bool containsKey(String key) {
    return _sharedPreferences.containsKey(key);
  }

  Set<String> getKeys() {
    return _sharedPreferences.getKeys();
  }
}

/// Provider for the complete storage service (THIS IS THE MISSING ONE)
final storageProvider = Provider<StorageService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);

  return StorageService(
    secureStorage: secureStorage,
    sharedPreferences: sharedPreferences,
  );
});

/// Convenience provider just for secure storage
final storageServiceProvider = Provider<StorageService>((ref) {
  return ref.watch(storageProvider);
});
