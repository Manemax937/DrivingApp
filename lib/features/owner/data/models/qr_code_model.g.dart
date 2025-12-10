// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QRCodeModel _$QRCodeModelFromJson(Map<String, dynamic> json) => QRCodeModel(
  id: json['id'] as String,
  schoolId: json['school_id'] as String,
  qrPayload: json['qr_payload'] as String,
  dailySecret: json['daily_secret'] as String,
  validFrom: json['valid_from'] as String,
  validUntil: json['valid_until'] as String,
  active: json['active'] as bool,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$QRCodeModelToJson(QRCodeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'school_id': instance.schoolId,
      'qr_payload': instance.qrPayload,
      'daily_secret': instance.dailySecret,
      'valid_from': instance.validFrom,
      'valid_until': instance.validUntil,
      'active': instance.active,
      'created_at': instance.createdAt,
    };
