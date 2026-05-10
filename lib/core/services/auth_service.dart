import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign Up
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'age': age,
          'gender': gender,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get User Data from Firestore
  Future<DocumentSnapshot?> getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _firestore.collection('users').doc(user.uid).get();
    }
    return null;
  }

  // Get User Scans History
  Stream<QuerySnapshot> getUserScans() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .orderBy('createdAt', descending: true)
          .snapshots();
    }
    return const Stream.empty();
  }

  // Save Scan Result
  Future<void> saveScanResult({
    required String diagnosis,
    required Map<String, String> confidenceScores,
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .add({
        'status': diagnosis,
        'isHealthy': diagnosis == 'Normal Heart Rhythm',
        'score': confidenceScores[diagnosis] ?? '0%',
        'confidenceScores': confidenceScores,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
