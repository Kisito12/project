import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../estimator/estimate_list_screen.dart';
import '../inspections/inspection_list_screen.dart';
import 'assign_workers_screen.dart';
import 'plan_specs_tab.dart';
import 'tasks_tab.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;
  final AppUser user;

  const ProjectDetailScreen({super.key, required this.project, required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.name),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Plan & Specs'),
              Tab(text: 'Tasks'),
              Tab(text: 'Inspections'),
              Tab(text: 'Estimate'),
            ],
          ),
          actions: [
            if (user.isCompanyAdmin)
              PopupMenuButton<ProjectStatus>(
                icon: const Icon(Icons.more_vert),
                onSelected: (status) =>
                    ProjectService().updateStatus(project.id, status),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: ProjectStatus.planning, child: Text('Mark: Planning')),
                  PopupMenuItem(value: ProjectStatus.active, child: Text('Mark: Active')),
                  PopupMenuItem(value: ProjectStatus.onHold, child: Text('Mark: On hold')),
                  PopupMenuItem(value: ProjectStatus.completed, child: Text('Mark: Completed')),
                ],
              ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      project.clientName.isEmpty
                          ? project.location
                          : '${project.clientName} · ${project.location}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (user.isCompanyAdmin)
                    TextButton.icon(
                      icon: const Icon(Icons.group_add, size: 18),
                      label: const Text('Assign'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AssignWorkersScreen(project: project),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PlanSpecsTab(project: project, user: user),
                  TasksTab(project: project, user: user),
                  InspectionListScreen(project: project, user: user),
                  EstimateListScreen(project: project),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
