import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/company.dart';
import '../services/app_state.dart';
import '../services/company_service.dart';
import 'auth/login_screen.dart';
import 'company_home_screen.dart';
import 'super_admin/super_admin_home_screen.dart';

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

    final user = appState.currentUser;
    if (user == null) {
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

    if (user.isSuperAdmin) {
      return const SuperAdminHomeScreen();
    }

    // Company admin / worker: gate on the company's approval status.
    return StreamBuilder<Company?>(
      stream: CompanyService().watchCompany(user.companyId ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final company = snapshot.data;
        if (company == null) {
          return _MessageScreen(
            message: 'Your company account could not be found.',
            onSignOut: () => appState.authService.signOut(),
          );
        }
        switch (company.status) {
          case CompanyStatus.pending:
            return _MessageScreen(
              message:
                  '"${company.name}" is awaiting approval from the platform. '
                  'You\'ll get access as soon as it\'s approved.',
              onSignOut: () => appState.authService.signOut(),
            );
          case CompanyStatus.suspended:
            return _MessageScreen(
              message: '"${company.name}" has been suspended on the platform.',
              onSignOut: () => appState.authService.signOut(),
            );
          case CompanyStatus.approved:
            return CompanyHomeScreen(company: company);
        }
      },
    );
  }
}

class _MessageScreen extends StatelessWidget {
  final String message;
  final VoidCallback onSignOut;

  const _MessageScreen({required this.message, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hourglass_top, size: 48, color: Colors.black38),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextButton(onPressed: onSignOut, child: const Text('Sign out')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
