import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:roleplaying_app/src/models/user.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future signIn(String email, String password, ) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      User? user = result.user;
      return UserModel(
          id: user!.uid, email: user.email, nickName: user.displayName);
    } on FirebaseAuthException catch (e) {
      return e;
    }
  }

  Future registration(String email, String password, String displayName) async {
    try {
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      User user = result.user!;
      user.sendEmailVerification();
      user.updateDisplayName(displayName);
      return UserModel(id: user.uid, email: user.email);
    } on FirebaseAuthException catch (e) {
      log(e.toString(), name: "ERROR");
      return e;
    }
  }

  Future logOut() async {
    await _firebaseAuth.signOut();
  }

  Future<bool> isSignedIn() async {
    final currentUser  = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<UserModel> getUserFromFirebase() async {
    return UserModel(id: _firebaseAuth.currentUser!.uid, email: _firebaseAuth.currentUser!.email);
  }
}