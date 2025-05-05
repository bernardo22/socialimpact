// ignore_for_file: unused_import

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Signs up a new user with email, password, and userType.
  Future<User?> signUp({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'userType': userType,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Signs in an existing user with email and password.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Returns the currently logged in user.
  User? get currentUser => _firebaseAuth.currentUser;

  // Stream of authentication state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
