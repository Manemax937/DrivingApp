// lib/main.dart
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'firebase_options.dart';
import 'shared/providers/storage_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 1) Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// 2) Activate App Check (DEBUG MODE)
  // This **must** happen BEFORE any Firebase usage.
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  /// 3) TEMP: Anonymous login (only for testing Storage)
  await FirebaseAuth.instance.signInAnonymously();

  /// 4) Debug print
  await superDebug();
  await debugPutDataTest();

  /// 5) SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  /// 6) Launch app
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const DrivingSchoolApp(),
    ),
  );
}

/// DEBUG LOGGER – **Do not remove until uploads work**
Future<void> superDebug() async {
  try {
    final app = Firebase.app();
    final opts = app.options;
    final user = FirebaseAuth.instance.currentUser;

    print('==================== SUPER DEBUG ====================');
    print('app.name: ${app.name}');
    print('projectId: ${opts.projectId}');
    print('storageBucket: ${opts.storageBucket}');
    print('appId: ${opts.appId}');
    print('apiKey: ${opts.apiKey}');
    print('-------------------- AUTH INFO --------------------');
    print('currentUser: $user');
    print('uid: ${user?.uid}');

    if (user != null) {
      final token = await user.getIdToken(true);
      print("idToken received: ${token?.substring(0, 60)}...");
      print("token length: ${token?.length}");
    }

    print('------------------ STORAGE SDK ---------------------');
    final rootRef = FirebaseStorage.instance.ref();
    print('rootRef.bucket: ${rootRef.bucket}');
    print('rootRef.fullPath: ${rootRef.fullPath}');
    print('====================================================');
  } catch (e, st) {
    print('SUPER DEBUG ERROR: $e');
    print(st);
  }
}

Future<void> debugPutDataTest() async {
  final user = FirebaseAuth.instance.currentUser;
  print('DEBUG PUTDATA: currentUser uid=${user?.uid}');
  if (user == null) {
    print('DEBUG PUTDATA: user is null');
    return;
  }

  try {
    await user.getIdToken(true);
    print('DEBUG PUTDATA: forced id token refresh');
  } catch (e) {
    print('DEBUG PUTDATA: id token refresh error: $e');
  }

  final ref = FirebaseStorage.instance.ref(
    'form14_photos/debug/${user.uid}/test.bin',
  );
  print('DEBUG PUTDATA: uploading to ${ref.fullPath} (bucket ${ref.bucket})');

  try {
    final snap = await ref.putData(Uint8List.fromList(List<int>.filled(10, 0)));
    final url = await ref.getDownloadURL();
    print('DEBUG PUTDATA: success, downloadUrl=$url');
  } on FirebaseException catch (e, st) {
    print(
      'DEBUG PUTDATA: FirebaseException code=${e.code} message=${e.message}',
    );
    print(st);
  } catch (e, st) {
    print('DEBUG PUTDATA: other exception: $e');
    print(st);
  }
}
