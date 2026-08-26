import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../theme/app_theme.dart';
import '../estimator/estimate_list_screen.dart';
import '../inspections/inspection_list_screen.dart';
import 'assign_workers_screen.dart';
import 'plan_specs_tab.dart';
import 'tasks_tab.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;
  final AppUser user;

  const ProjectDetailScreen({super.key, required this.project, required this.user});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    final user = widget.user;

    final pages = [
      PlanSpecsTab(project: project, user: user),
      TasksTab(project: project, user: user),
      InspectionListScreen(project: project, user: user),
      EstimateListScreen(project: project),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(project.name),
        actions: [
          if (user.isCompanyAdmin)
            IconButton(
              icon: const Icon(Icons.group_add),
              tooltip: 'Assign workers',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AssignWorkersScreen(project: project)),
              ),
            ),
          if (user.isCompanyAdmin)
            PopupMenuButton<ProjectStatus>(
              icon: const Icon(Icons.more_vert),
              onSelected: (status) => ProjectService().updateStatus(project.id, status),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                project.clientName.isEmpty
                    ? project.location
                    : '${project.clientName} · ${project.location}',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
          ),
          Expanded(child: IndexedStack(index: _index, children: pages)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist_outlined), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'Inspect'),
          BottomNavigationBarItem(icon: Icon(Icons.calculate_outlined), label: 'Estimate'),
        ],
      ),
    );
  }
}
