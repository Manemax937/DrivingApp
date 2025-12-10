import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class QREncryption {
  static final _key = encrypt.Key.fromUtf8(
    '32-character-secret-key-here',
  ); // 32 chars
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  // Encrypt QR data
  static String encryptQRData(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
    return encrypted.base64;
  }

  // Decrypt QR data
  static Map<String, dynamic> decryptQRData(String encryptedData) {
    try {
      final decrypted = _encrypter.decrypt64(encryptedData, iv: _iv);
      return jsonDecode(decrypted) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Invalid QR code');
    }
  }

  // Generate daily secret
  static String generateDailySecret() {
    final now = DateTime.now();
    final dateString = '${now.year}-${now.month}-${now.day}';
    final bytes = utf8.encode(dateString);
    return sha256.convert(bytes).toString().substring(0, 32);
  }

  // Verify QR code authenticity
  static bool verifyQRCode(Map<String, dynamic> qrData) {
    final expiresAt = DateTime.parse(qrData['expires_at'] as String);
    final now = DateTime.now();

    return now.isBefore(expiresAt);
  }
}
