import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme/app_theme.dart';
import 'projects/project_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CivilSite'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Chip(
                label: Text(user.isAdmin ? 'Admin' : 'Field Engineer'),
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
      body: const ProjectListScreen(),
    );
  }
}
