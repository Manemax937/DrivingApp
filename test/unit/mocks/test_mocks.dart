import 'package:driveapp/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:driveapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

@GenerateMocks([FlutterSecureStorage, FirebaseAuthDataSource, AuthRepository])
void main() {}

// Run this command to generate mocks:
// flutter pub run build_runner build
