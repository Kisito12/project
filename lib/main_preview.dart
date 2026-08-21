// Visual QA harness — not part of the shipped app (lib/main.dart is the real
// entry point). Renders the real screens with sample in-memory data instead
// of live Firestore streams, so the UI can be reviewed without Firebase or
// any network connection.
// Run with: flutter run -d chrome -t lib/main_preview.dart
import 'package:flutter/material.dart';

import 'models/estimate.dart';
import 'models/inspection.dart';
import 'models/project.dart';
import 'models/project_task.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/estimator/create_estimate_screen.dart';
import 'screens/estimator/estimate_detail_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PreviewApp());
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    final previewTheme = AppTheme.light.copyWith(
      textTheme: AppTheme.light.textTheme.apply(fontFamily: 'PreviewFont'),
      primaryTextTheme: AppTheme.light.primaryTextTheme.apply(fontFamily: 'PreviewFont'),
    );
    return MaterialApp(
      title: 'CivilSite Preview',
      debugShowCheckedModeBanner: false,
      theme: previewTheme,
      home: const PreviewMenu(),
    );
  }
}

final _sampleProjects = [
  Project(
    id: 'p1',
    name: 'Riverside Apartments',
    location: '14 Riverside Rd, Lagos',
    description: '24-unit residential block',
    status: ProjectStatus.active,
    createdBy: 'admin1',
    assignedEngineerIds: const ['eng1'],
    createdAt: DateTime.now(),
  ),
  Project(
    id: 'p2',
    name: 'Oakwood Bridge Repair',
    location: 'Oakwood Creek Crossing',
    description: 'Structural repair of pier 3',
    status: ProjectStatus.planning,
    createdBy: 'admin1',
    assignedEngineerIds: const [],
    createdAt: DateTime.now(),
  ),
];

final _sampleTasks = [
  ProjectTask(
    id: 't1',
    title: 'Pour foundation slab',
    notes: 'Grade 30 concrete, 150mm thick',
    status: TaskStatus.done,
    assignedToId: 'eng1',
    dueDate: null,
    createdAt: DateTime.now(),
  ),
  ProjectTask(
    id: 't2',
    title: 'Erect block walls - ground floor',
    notes: '',
    status: TaskStatus.inProgress,
    assignedToId: 'eng1',
    dueDate: null,
    createdAt: DateTime.now(),
  ),
  ProjectTask(
    id: 't3',
    title: 'Roof truss installation',
    notes: 'Awaiting timber delivery',
    status: TaskStatus.todo,
    assignedToId: null,
    dueDate: null,
    createdAt: DateTime.now(),
  ),
];

final _sampleInspection = Inspection(
  id: 'i1',
  projectId: 'p1',
  inspectorId: 'eng1',
  inspectorName: 'Ada Okafor',
  summary:
      'Hairline cracking observed on the east retaining wall, likely shrinkage. '
      'Recommend monitoring over next 2 weeks before remedial action.',
  severity: DefectSeverity.medium,
  photoUrls: const [],
  createdAt: DateTime.now(),
);

final _sampleEstimate = Estimate(
  id: 'e1',
  projectId: 'p1',
  title: 'Riverside Apartments — Full Build Estimate',
  createdBy: 'admin1',
  createdAt: DateTime.now(),
  items: [
    EstimateItem.newItem(
      phase: ConstructionPhase.foundation,
      description: 'Excavation & hardcore filling',
      quantity: 120,
      unit: 'm3',
      unitMaterialCost: 18,
      laborCost: 900,
    ),
    EstimateItem.newItem(
      phase: ConstructionPhase.foundation,
      description: 'Concrete strip foundation, Grade 25',
      quantity: 45,
      unit: 'm3',
      unitMaterialCost: 145,
      laborCost: 2200,
    ),
    EstimateItem.newItem(
      phase: ConstructionPhase.superstructure,
      description: 'Sandcrete block walling, 225mm',
      quantity: 600,
      unit: 'blocks',
      unitMaterialCost: 3.2,
      laborCost: 1800,
    ),
    EstimateItem.newItem(
      phase: ConstructionPhase.roofing,
      description: 'Timber trusses & aluminium roofing sheets',
      quantity: 280,
      unit: 'm2',
      unitMaterialCost: 22,
      laborCost: 3100,
    ),
    EstimateItem.newItem(
      phase: ConstructionPhase.finishes,
      description: 'Plastering, painting & tiling',
      quantity: 1,
      unit: 'lump sum',
      unitMaterialCost: 14500,
      laborCost: 6200,
    ),
  ],
);

class PreviewMenu extends StatelessWidget {
  const PreviewMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CivilSite — Screen Preview')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(context, 'Login', const LoginScreen()),
          _tile(context, 'Register', const RegisterScreen()),
          _tile(context, 'Project list (mock)', PreviewProjectList(projects: _sampleProjects)),
          _tile(context, 'Project — Tasks tab (mock)',
              PreviewTasksTab(tasks: _sampleTasks)),
          _tile(context, 'Project — Inspections tab (mock)',
              PreviewInspectionsTab(inspection: _sampleInspection)),
          _tile(context, 'Cost estimate builder (live, no data needed)',
              CreateEstimateScreen(project: _dummyProjectForBuilder)),
          _tile(context, 'Cost estimate detail (mock)',
              EstimateDetailScreen(estimate: _sampleEstimate)),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, String label, Widget screen) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        ),
      ),
    );
  }
}

final _dummyProjectForBuilder = Project(
  id: 'p1',
  name: 'Riverside Apartments',
  location: '14 Riverside Rd, Lagos',
  description: '',
  status: ProjectStatus.active,
  createdBy: 'admin1',
  assignedEngineerIds: const [],
  createdAt: DateTime.now(),
);

// --- Lightweight mock renderers mirroring the real screens' layout ---

class PreviewProjectList extends StatelessWidget {
  final List<Project> projects;

  const PreviewProjectList({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CivilSite'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Chip(
                label: Text('Admin'),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Icon(Icons.logout),
          SizedBox(width: 12),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: projects.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            child: ListTile(
              title: Text(project.name),
              subtitle: Text('${project.location}\n${_statusLabel(project.status)}'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
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

class PreviewTasksTab extends StatelessWidget {
  final List<ProjectTask> tasks;

  const PreviewTasksTab({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final doneCount = tasks.where((t) => t.status == TaskStatus.done).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Riverside Apartments — Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progress: $doneCount / ${tasks.length} tasks complete'),
                const SizedBox(height: 4),
                LinearProgressIndicator(value: doneCount / tasks.length),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: tasks
                  .map(
                    (task) => CheckboxListTile(
                      value: task.status == TaskStatus.done,
                      onChanged: (_) {},
                      title: Text(
                        task.title,
                        style: task.status == TaskStatus.done
                            ? const TextStyle(decoration: TextDecoration.lineThrough)
                            : null,
                      ),
                      subtitle: task.notes.isEmpty ? null : Text(task.notes),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}

class PreviewInspectionsTab extends StatelessWidget {
  final Inspection inspection;

  const PreviewInspectionsTab({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riverside Apartments — Inspections')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          inspection.severity.name.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                        backgroundColor: Colors.orange,
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          inspection.inspectorName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(inspection.summary),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add_a_photo)),
    );
  }
}
