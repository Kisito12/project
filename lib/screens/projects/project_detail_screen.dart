import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/project.dart';
import '../../services/app_state.dart';
import '../../services/project_service.dart';
import '../estimator/estimate_list_screen.dart';
import '../inspections/inspection_list_screen.dart';
import 'assign_engineers_screen.dart';
import 'tasks_tab.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser!;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(project.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Tasks'),
              Tab(text: 'Inspections'),
              Tab(text: 'Estimate'),
            ],
          ),
          actions: [
            if (user.isAdmin)
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
                      project.location,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (user.isAdmin)
                    TextButton.icon(
                      icon: const Icon(Icons.group_add, size: 18),
                      label: const Text('Assign'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AssignEngineersScreen(project: project),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TasksTab(project: project),
                  InspectionListScreen(project: project),
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
