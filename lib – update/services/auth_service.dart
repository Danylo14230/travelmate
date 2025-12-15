// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Anonymous
  Future<UserCredential> signInAnonymously() async {
    return await _auth.signInAnonymously();
  }

  // Email sign-in
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Register with email (creates or links if anonymous)
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final current = _auth.currentUser;
    // If anonymous, link credentials to keep user data
    if (current != null && current.isAnonymous) {
      final cred = EmailAuthProvider.credential(email: email, password: password);
      final userCred = await current.linkWithCredential(cred);
      if (displayName != null) {
        await userCred.user?.updateDisplayName(displayName);
      }
      return userCred;
    } else {
      final userCred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (displayName != null) {
        await userCred.user?.updateDisplayName(displayName);
      }
      // Optionally: await userCred.user?.sendEmailVerification();
      return userCred;
    }
  }

  // Google
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('Користувач скасував вхід через Google');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    // if current is anonymous -> link (optional)
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      return await current.linkWithCredential(credential);
    }
    return await _auth.signInWithCredential(credential);
  }

  // Apple
  Future<UserCredential> signInWithApple() async {
    final result = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: result.identityToken,
      accessToken: result.authorizationCode,
    );
    final current = _auth.currentUser;
    if (current != null && current.isAnonymous) {
      return await current.linkWithCredential(oauthCredential);
    }
    return await _auth.signInWithCredential(oauthCredential);
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
