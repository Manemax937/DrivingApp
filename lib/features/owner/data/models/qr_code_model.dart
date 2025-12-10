import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/qr_code.dart';

part 'qr_code_model.g.dart';

@JsonSerializable()
class QRCodeModel {
  final String id;

  @JsonKey(name: 'school_id')
  final String schoolId;

  @JsonKey(name: 'qr_payload')
  final String qrPayload;

  @JsonKey(name: 'daily_secret')
  final String dailySecret;

  @JsonKey(name: 'valid_from')
  final String validFrom;

  @JsonKey(name: 'valid_until')
  final String validUntil;

  final bool active;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  QRCodeModel({
    required this.id,
    required this.schoolId,
    required this.qrPayload,
    required this.dailySecret,
    required this.validFrom,
    required this.validUntil,
    required this.active,
    this.createdAt,
  });

  /// Create QRCodeModel from JSON
  factory QRCodeModel.fromJson(Map<String, dynamic> json) =>
      _$QRCodeModelFromJson(json);

  /// Convert QRCodeModel to JSON
  Map<String, dynamic> toJson() => _$QRCodeModelToJson(this);

  /// Convert QRCodeModel to QRCode entity
  QRCode toEntity() {
    return QRCode(
      id: id,
      schoolId: schoolId,
      qrPayload: qrPayload,
      dailySecret: dailySecret,
      validFrom: DateTime.parse(validFrom),
      validUntil: DateTime.parse(validUntil),
      active: active,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
    );
  }

  /// Create QRCodeModel from QRCode entity
  factory QRCodeModel.fromEntity(QRCode qrCode) {
    return QRCodeModel(
      id: qrCode.id,
      schoolId: qrCode.schoolId,
      qrPayload: qrCode.qrPayload,
      dailySecret: qrCode.dailySecret,
      validFrom: qrCode.validFrom.toIso8601String(),
      validUntil: qrCode.validUntil.toIso8601String(),
      active: qrCode.active,
      createdAt: qrCode.createdAt?.toIso8601String(),
    );
  }

  /// Copy with method
  QRCodeModel copyWith({
    String? id,
    String? schoolId,
    String? qrPayload,
    String? dailySecret,
    String? validFrom,
    String? validUntil,
    bool? active,
    String? createdAt,
  }) {
    return QRCodeModel(
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
}
