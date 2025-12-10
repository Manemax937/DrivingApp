import 'package:driveapp/features/auth/data/models/user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'user')
  final UserModel user;

  @JsonKey(name: 'first_login')
  final bool firstLogin;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.firstLogin,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
