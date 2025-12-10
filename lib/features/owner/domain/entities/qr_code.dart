import 'package:equatable/equatable.dart';

/// QR Code entity
class QRCode extends Equatable {
  final String id;
  final String schoolId;
  final String qrPayload;
  final String dailySecret;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool active;
  final DateTime? createdAt;

  const QRCode({
    required this.id,
    required this.schoolId,
    required this.qrPayload,
    required this.dailySecret,
    required this.validFrom,
    required this.validUntil,
    required this.active,
    this.createdAt,
  });

  /// Check if QR code is currently valid
  bool get isValid {
    final now = DateTime.now();
    return active && now.isAfter(validFrom) && now.isBefore(validUntil);
  }

  /// Check if QR code is expired
  bool get isExpired {
    return DateTime.now().isAfter(validUntil);
  }

  /// Get remaining validity duration
  Duration get remainingValidity {
    final now = DateTime.now();
    if (now.isAfter(validUntil)) {
      return Duration.zero;
    }
    return validUntil.difference(now);
  }

  /// Copy with method
  QRCode copyWith({
    String? id,
    String? schoolId,
    String? qrPayload,
    String? dailySecret,
    DateTime? validFrom,
    DateTime? validUntil,
    bool? active,
    DateTime? createdAt,
  }) {
    return QRCode(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      qrPayload: qrPayload ?? this.qrPayload,
      dailySecret: dailySecret ?? this.dailySecret,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    schoolId,
    qrPayload,
    dailySecret,
    validFrom,
    validUntil,
    active,
    createdAt,
  ];
}
