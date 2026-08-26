// Visual QA harness — not part of the shipped app (lib/main.dart is the real
// entry point). Renders the real screens with sample data so the UI can be
// reviewed without Firebase or any network connection.
// Run with: flutter run -d chrome -t lib/main_preview.dart
import 'package:flutter/material.dart';

import 'models/building_spec.dart';
import 'models/company.dart';
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

final _sampleCompany = Company(
  id: 'c1',
  name: 'Okafor Builders Ltd',
  contactEmail: 'admin@okaforbuilders.test',
  phone: '+234 800 000 0000',
  status: CompanyStatus.approved,
  ownerId: 'admin1',
  createdAt: DateTime.now(),
);

final _sampleCompanies = [
  _sampleCompany,
  Company(
    id: 'c2',
    name: 'Bridgeway Construction',
    contactEmail: 'hello@bridgeway.test',
    phone: '+234 800 111 2222',
    status: CompanyStatus.pending,
    ownerId: 'admin2',
    createdAt: DateTime.now(),
  ),
];

final _sampleSpec = BuildingSpec(
  floors: 1,
  footprintLengthM: 12,
  footprintWidthM: 9,
  wallHeightM: 3.0,
  foundationType: FoundationType.strip,
  roofType: RoofType.gable,
  rooms: [
    RoomSpec.newRoom(name: 'Living Room', type: RoomType.living, lengthM: 5, widthM: 4),
    RoomSpec.newRoom(name: 'Master Bedroom', type: RoomType.bedroom, lengthM: 4, widthM: 3.5),
    RoomSpec.newRoom(name: 'Bedroom 2', type: RoomType.bedroom, lengthM: 3.5, widthM: 3),
    RoomSpec.newRoom(name: 'Kitchen', type: RoomType.kitchen, lengthM: 3, widthM: 3),
    RoomSpec.newRoom(name: 'Bathroom', type: RoomType.bathroom, lengthM: 2, widthM: 2),
  ],
);

final _sampleProjects = [
  Project(
    id: 'p1',
    companyId: 'c1',
    name: 'Riverside Family House',
    location: '14 Riverside Rd, Lagos',
    description: '3-bedroom bungalow',
    clientName: 'Mr. & Mrs. Adeyemi',
    clientPhone: '+234 800 555 1234',
    clientAddress: '14 Riverside Rd, Lagos',
    status: ProjectStatus.active,
    createdBy: 'admin1',
    assignedWorkerIds: const ['worker1'],
    planFileUrl: null,
    planFileName: null,
    buildingSpec: _sampleSpec,
    createdAt: DateTime.now(),
  ),
  Project(
    id: 'p2',
    companyId: 'c1',
    name: 'Oakwood Renovation',
    location: 'Oakwood Creek Crossing',
    description: 'Kitchen & roof renovation',
    clientName: 'Mr. Bello',
    clientPhone: '+234 800 555 9999',
    clientAddress: 'Oakwood Creek Crossing',
    status: ProjectStatus.planning,
    createdBy: 'admin1',
    assignedWorkerIds: const [],
    planFileUrl: null,
    planFileName: null,
    buildingSpec: BuildingSpec.empty(),
    createdAt: DateTime.now(),
  ),
];

final _sampleTasks = [
  ProjectTask(
    id: 't1',
    title: 'Pour foundation slab',
    notes: 'Grade 30 concrete, 150mm thick',
    status: TaskStatus.done,
    assignedToId: 'worker1',
    dueDate: null,
    createdAt: DateTime.now(),
  ),
  ProjectTask(
    id: 't2',
    title: 'Erect block walls - ground floor',
    notes: '',
    status: TaskStatus.inProgress,
    assignedToId: 'worker1',
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
  companyId: 'c1',
  projectId: 'p1',
  inspectorId: 'worker1',
  inspectorName: 'Tunde Balogun',
  summary:
      'Hairline cracking observed on the east retaining wall, likely shrinkage. '
      'Recommend monitoring over next 2 weeks before remedial action.',
  severity: DefectSeverity.medium,
  photoUrls: const [],
  createdAt: DateTime.now(),
);

final _sampleEstimate = Estimate(
  id: 'e1',
  companyId: 'c1',
  projectId: 'p1',
  title: 'Riverside Family House — Auto Estimate',
  createdBy: 'admin1',
  createdAt: DateTime.now(),
  items: [
    ...TakeoffCalculator.generate(_sampleSpec),
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
          _tile(context, 'Register (company / worker)', const RegisterScreen()),
          _tile(context, 'Super Admin — company list (mock)',
              PreviewCompanyList(companies: _sampleCompanies)),
          _tile(context, 'Company home — project list (mock)',
              PreviewProjectList(projects: _sampleProjects)),
          _tile(context, 'Project — Plan & Specs tab (mock)',
              PreviewPlanSpecsTab(spec: _sampleSpec)),
          _tile(context, 'Project — Tasks tab (mock)', PreviewTasksTab(tasks: _sampleTasks)),
          _tile(context, 'Project — Inspections tab (mock)',
              PreviewInspectionsTab(inspection: _sampleInspection)),
          _tile(context, 'Cost estimate builder, pre-filled from specs (live)',
              CreateEstimateScreen(
                project: _sampleProjects[0],
                initialItems: TakeoffCalculator.generate(_sampleSpec),
                initialTitle: 'Riverside Family House — Auto Estimate',
              )),
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

// --- Lightweight mock renderers mirroring the real screens' layout ---

class PreviewCompanyList extends StatelessWidget {
  final List<Company> companies;

  const PreviewCompanyList({super.key, required this.companies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CivilSite Platform'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Chip(
                label: Text('Super Admin'),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Icon(Icons.logout),
          SizedBox(width: 12),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: companies.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final company = companies[index];
          return Card(
            child: ListTile(
              title: Text(company.name),
              subtitle: Text('${company.contactEmail}\n${company.status.name}'),
              isThreeLine: true,
              trailing: const Icon(Icons.more_vert),
            ),
          );
        },
      ),
    );
  }
}

class PreviewProjectList extends StatelessWidget {
  final List<Project> projects;

  const PreviewProjectList({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Okafor Builders Ltd'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Chip(
                label: Text('Company Admin'),
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
              subtitle: Text('${project.clientName} · ${project.location}\n${project.status.name}'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
    );
  }
}

class PreviewPlanSpecsTab extends StatelessWidget {
  final BuildingSpec spec;

  const PreviewPlanSpecsTab({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riverside Family House — Plan & Specs')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Architect\'s plan', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.picture_as_pdf, size: 48, color: Colors.black38),
                  const SizedBox(height: 8),
                  const Text('site-plan-riverside.jpg'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Replace plan'),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Building specs', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('${spec.floors} floor(s) · ${spec.footprintLengthM}m × ${spec.footprintWidthM}m footprint'),
          Text('${spec.foundationType.label} · ${spec.roofType.label}'),
          const SizedBox(height: 12),
          Text('Rooms', style: Theme.of(context).textTheme.titleSmall),
          for (final room in spec.rooms)
            ListTile(
              dense: true,
              title: Text('${room.name} (${room.type.label})'),
              subtitle: Text('${room.lengthM}m × ${room.widthM}m = ${room.areaM2.toStringAsFixed(1)}m²'),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.calculate),
            label: const Text('Generate estimate from specs'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class PreviewTasksTab extends StatelessWidget {
  final List<ProjectTask> tasks;

  const PreviewTasksTab({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final doneCount = tasks.where((t) => t.status == TaskStatus.done).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Riverside Family House — Tasks')),
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
      appBar: AppBar(title: const Text('Riverside Family House — Inspections')),
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
