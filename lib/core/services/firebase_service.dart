import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Collections
  static const String usersCollection = 'users';
  static const String schoolsCollection = 'schools';
  static const String studentsCollection = 'students';
  static const String attendanceCollection = 'attendance';
  static const String qrCodesCollection = 'qr_codes';

  // Get current user
  static User? get currentUser => auth.currentUser;

  // Get current user ID
  static String? get currentUserId => auth.currentUser?.uid;

  // Check if user is signed in
  static bool get isSignedIn => auth.currentUser != null;
}
