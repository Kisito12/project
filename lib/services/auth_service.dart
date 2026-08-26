import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<AppUser?> fetchCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(user.uid, doc.data()!);
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  /// Creates the Firebase Auth account only. Callers that need a companyId
  /// assigned (e.g. after creating a new company for a company admin) should
  /// use this together with [createUserProfile], rather than [register].
  Future<String> createAuthAccount({required String email, required String password}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user!.uid;
  }

  Future<void> createUserProfile(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  /// Convenience for the simple case where companyId is already known.
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String? companyId,
  }) async {
    final uid = await createAuthAccount(email: email, password: password);
    await createUserProfile(
      AppUser(uid: uid, name: name, email: email.trim(), role: role, companyId: companyId),
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
