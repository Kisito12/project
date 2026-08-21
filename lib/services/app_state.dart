import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import 'auth_service.dart';

/// Tracks the signed-in Firebase user and their app profile (role etc.),
/// re-loading the profile whenever the auth state changes.
class AppState extends ChangeNotifier {
  final AuthService _authService;

  AppUser? _currentUser;
  bool _loading = true;

  AppState(this._authService) {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  AppUser? get currentUser => _currentUser;
  bool get loading => _loading;
  bool get isSignedIn => _currentUser != null;

  AuthService get authService => _authService;

  Future<void> _onAuthChanged(User? user) async {
    _loading = true;
    notifyListeners();
    if (user == null) {
      _currentUser = null;
    } else {
      _currentUser = await _authService.fetchCurrentAppUser();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> refreshCurrentUser() async {
    _currentUser = await _authService.fetchCurrentAppUser();
    notifyListeners();
  }
}
