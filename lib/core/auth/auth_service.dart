import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/auth_config.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static GoogleSignIn _createGoogleSignIn() {
    if (kIsWeb && AuthConfig.googleWebClientId != null) {
      return GoogleSignIn(clientId: AuthConfig.googleWebClientId);
    }
    return GoogleSignIn();
  }

  /// Login con email y contraseña
  static Future<UserCredential?> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Envía correo de restablecimiento de contraseña (Firebase Auth).
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Login con Google
  static Future<UserCredential?> signInWithGoogle() async {
    final googleSignIn = _createGoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await _auth.signInWithCredential(credential);
  }

  /// Login con Apple
  static Future<UserCredential?> signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    return await _auth.signInWithProvider(appleProvider);
  }

  /// Registro con email y contraseña
  static Future<UserCredential?> signUpWithEmail(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Sesión de invitado (sin correo). Requiere tener "Anónimo" activado en Firebase Auth.
  static Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  /// Cerrar sesión
  static Future<void> signOut() async {
    try {
      await _createGoogleSignIn().signOut();
    } catch (_) {
      // En web sin clientId configurado, GoogleSignIn puede fallar. Ignorar.
    }
    await _auth.signOut();
  }

  /// Elimina la cuenta del usuario y todos sus datos de Firestore.
  /// Si es el único miembro de la familia, elimina también la familia completa.
  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final uid = user.uid;
    final userDoc = _firestore.collection('users').doc(uid);
    final userSnap = await userDoc.get();
    final familyId = userSnap.data()?['familyId'] as String?;

    if (familyId != null && familyId.isNotEmpty) {
      final familyDoc = _firestore.collection('families').doc(familyId);
      final familySnap = await familyDoc.get();
      final members = List<String>.from(
        (familySnap.data()?['members'] as List?) ?? [],
      );

      if (members.length <= 1) {
        // Único miembro: borrar toda la familia y sus subcolecciones
        for (final sub in ['weight_records', 'diaper_records', 'feeding_records']) {
          final snap = await familyDoc.collection(sub).get();
          for (final doc in snap.docs) {
            await doc.reference.delete();
          }
        }
        await familyDoc.delete();
      } else {
        // Hay más miembros: solo desvincularse
        members.remove(uid);
        await familyDoc.update({'members': members});
      }
    }

    await userDoc.delete();

    try {
      await _createGoogleSignIn().signOut();
    } catch (_) {}

    await user.delete();
  }
}
