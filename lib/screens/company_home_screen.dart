import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/company.dart';
import '../services/app_state.dart';
import 'projects/project_list_screen.dart';

/// Home screen for a company admin or company worker, scoped to their
/// (already-approved) company. The greeting header, stats, and project list
/// all live in [ProjectListScreen] so the whole thing reads as one page.
class CompanyHomeScreen extends StatelessWidget {
  final Company company;

  const CompanyHomeScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser!;
    return ProjectListScreen(company: company, user: user);
  }
}
