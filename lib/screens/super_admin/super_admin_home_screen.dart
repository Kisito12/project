import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/company.dart';
import '../../services/app_state.dart';
import '../../services/company_service.dart';
import 'company_projects_screen.dart';

/// Home screen for the platform's super admin: oversight of every company
/// on the platform, with the ability to approve or suspend them.
class SuperAdminHomeScreen extends StatelessWidget {
  const SuperAdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CivilSite Platform'),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Chip(
                label: Text('Super Admin'),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
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
      body: StreamBuilder<List<Company>>(
        stream: CompanyService().watchAllCompanies(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final companies = snapshot.data!;
          if (companies.isEmpty) {
            return const Center(child: Text('No companies have registered yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: companies.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final company = companies[index];
              return Card(
                child: ListTile(
                  title: Text(company.name),
                  subtitle: Text('${company.contactEmail}\n${_statusLabel(company.status)}'),
                  isThreeLine: true,
                  trailing: PopupMenuButton<CompanyStatus>(
                    onSelected: (status) => CompanyService().setStatus(company.id, status),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: CompanyStatus.approved, child: Text('Approve')),
                      PopupMenuItem(value: CompanyStatus.suspended, child: Text('Suspend')),
                      PopupMenuItem(value: CompanyStatus.pending, child: Text('Mark pending')),
                    ],
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CompanyProjectsScreen(company: company)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _statusLabel(CompanyStatus status) {
    switch (status) {
      case CompanyStatus.pending:
        return 'Pending approval';
      case CompanyStatus.approved:
        return 'Approved';
      case CompanyStatus.suspended:
        return 'Suspended';
    }
  }
}
