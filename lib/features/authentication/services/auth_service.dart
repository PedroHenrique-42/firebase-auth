import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_firestore_second/features/authentication/constants/firebase_auth_constants.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Logger().i("Conta logada com sucesso");
      return null;
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case FirebaseAuthConstants.USER_NOT_FOUND:
          return "O e-mail não está cadastrado";
        case FirebaseAuthConstants.WRONG_PASSWORD:
          return "Senha incorreta";
      }
      return error.code;
    }
  }

  Future<String?> registerUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(name);
      return null;
    } on FirebaseAuthException catch (error) {
      switch (error.code) {
        case FirebaseAuthConstants.EMAIL_ALREADY_IN_USE:
          return "O e-mail já está em uso";
      }
      return error.code;
    }
  }

  Future<String?> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (error) {
      if (error.code == "user-not-found") {
        return "E-mail não cadastrado";
      }
      return error.code;
    }
  }

  Future<String?> logoff() async {
    try {
      _firebaseAuth.signOut();
      return null;
    } on FirebaseAuthException catch (error) {
      return error.code;
    }
  }

  Future<String?> removeAccount({required String password}) async {
    try {
      User user = _firebaseAuth.currentUser!; 
      await _firebaseAuth.signInWithEmailAndPassword(
        email: user.email!,
        password: password,
      );
      await user.delete();
      return null;
    } on FirebaseAuthException catch (error) {
      Logger().i(error);
      return error.code;
    }
  }
}
