import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/company.dart';
import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'projects/project_list_screen.dart';

/// Home screen for a company admin or company worker, scoped to their
/// (already-approved) company.
class CompanyHomeScreen extends StatelessWidget {
  final Company company;

  const CompanyHomeScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text(company.name),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Chip(
                label: Text(user.isCompanyAdmin ? 'Company Admin' : 'Worker'),
                backgroundColor: Colors.white,
                labelStyle: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => appState.authService.signOut(),
          ),
        ],
      ),
      body: ProjectListScreen(company: company, user: user),
    );
  }
}
