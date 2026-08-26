import 'package:flutter/material.dart';

import '../../models/company.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';

/// Read-only, platform-level view of a single company's projects - the
/// super admin can see what every company is doing without stepping into
/// their day-to-day project management.
class CompanyProjectsScreen extends StatelessWidget {
  final Company company;

  const CompanyProjectsScreen({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(company.name)),
      body: StreamBuilder<List<Project>>(
        stream: ProjectService().watchProjectsForCompany(company.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data!;
          if (projects.isEmpty) {
            return const Center(child: Text('This company has no projects yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: projects.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final project = projects[index];
              return Card(
                child: ListTile(
                  title: Text(project.name),
                  subtitle: Text(
                    '${project.clientName.isEmpty ? project.location : '${project.clientName} · ${project.location}'}\n'
                    '${project.status.name}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
