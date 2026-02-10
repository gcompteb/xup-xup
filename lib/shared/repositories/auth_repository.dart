import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import '../../core/constants/firestore_constants.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    googleSignIn: GoogleSignIn(),
  );
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return ref.read(authRepositoryProvider).getCurrentUser();
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = currentFirebaseUser;
    if (firebaseUser == null) return null;

    final doc = await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(firebaseUser.uid)
        .get();

    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    
    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }

    final appUser = AppUser(
      uid: user.uid,
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .set(appUser.toFirestore());

    return appUser;
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user!;
    final doc = await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }

    final appUser = AppUser(
      uid: user.uid,
      email: user.email ?? email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .set(appUser.toFirestore());

    return appUser;
  }

  Future<AppUser> signInWithGoogle() async {
    UserCredential userCredential;
    String? email;
    String? displayName;
    String? photoUrl;

    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();
      userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
      final user = userCredential.user!;
      email = user.email;
      displayName = user.displayName;
      photoUrl = user.photoURL;
    } else {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      userCredential = await _firebaseAuth.signInWithCredential(credential);
      email = userCredential.user?.email ?? googleUser.email;
      displayName = userCredential.user?.displayName ?? googleUser.displayName;
      photoUrl = userCredential.user?.photoURL ?? googleUser.photoUrl;
    }

    final user = userCredential.user!;

    final doc = await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return AppUser.fromFirestore(doc);
    }

    final appUser = AppUser(
      uid: user.uid,
      email: email ?? '',
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(FirestoreConstants.usersCollection)
        .doc(user.uid)
        .set(appUser.toFirestore());

    return appUser;
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
