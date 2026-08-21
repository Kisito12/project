import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    if (appState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!appState.isSignedIn) {
      return const LoginScreen();
    }

    if (appState.currentUser == null) {
      // Signed in with Firebase Auth but the user profile document is
      // missing (e.g. deleted from Firestore) - treat as signed out.
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your account profile could not be found.'),
              TextButton(
                onPressed: () => appState.authService.signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}
