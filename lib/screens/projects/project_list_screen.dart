import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/company.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import 'create_project_screen.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatelessWidget {
  final Company company;
  final AppUser user;

  const ProjectListScreen({super.key, required this.company, required this.user});

  @override
  Widget build(BuildContext context) {
    final projectService = ProjectService();
    final stream = user.isCompanyAdmin
        ? projectService.watchProjectsForCompany(company.id)
        : projectService.watchProjectsForWorker(user.uid);

    return Scaffold(
      body: StreamBuilder<List<Project>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data!;
          if (projects.isEmpty) {
            return Center(
              child: Text(
                user.isCompanyAdmin
                    ? 'No projects yet. Tap + to create one.'
                    : 'No projects assigned to you yet.',
                textAlign: TextAlign.center,
              ),
            );
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
                    '${_statusLabel(project.status)}',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProjectDetailScreen(project: project, user: user),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: user.isCompanyAdmin
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CreateProjectScreen(company: company)),
              ),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _statusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On hold';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }
}
