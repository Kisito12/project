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
    final baseTheme = AppTheme.light;
    final previewTheme = baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(fontFamily: 'PreviewFont'),
      primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: 'PreviewFont'),
      // appBarTheme.titleTextStyle is set independently of textTheme, so the
      // override above doesn't reach it - patch it separately here so app
      // bar titles render in this sandbox (no effect on the shipped app).
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: baseTheme.appBarTheme.titleTextStyle?.copyWith(fontFamily: 'PreviewFont'),
      ),
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
    final active = projects.where((p) => p.status == ProjectStatus.active).length;
    final planning = projects.where((p) => p.status == ProjectStatus.planning).length;
    final completed = projects.where((p) => p.status == ProjectStatus.completed).length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Text('AO',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi Ada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('Okafor Builders Ltd · Company Admin',
                          style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.logout, color: AppTheme.textSecondary),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _previewStat('$active', 'Active', AppTheme.primary)),
                const SizedBox(width: 10),
                Expanded(child: _previewStat('$planning', 'Planning', const Color(0xFFE0A32E))),
                const SizedBox(width: 10),
                Expanded(child: _previewStat('$completed', 'Completed', const Color(0xFF5B8DEF))),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Projects', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration:
                      BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(999)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('New', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final project in projects) ...[
              _previewProjectCard(project),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }

  Widget _previewStat(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _previewProjectCard(Project project) {
    final (label, color) = switch (project.status) {
      ProjectStatus.planning => ('Planning', const Color(0xFFE0A32E)),
      ProjectStatus.active => ('Active', AppTheme.primary),
      ProjectStatus.onHold => ('On hold', const Color(0xFF9AA5A0)),
      ProjectStatus.completed => ('Done', const Color(0xFF5B8DEF)),
    };
    final progress = switch (project.status) {
      ProjectStatus.planning => 0.08,
      ProjectStatus.active => 0.62,
      ProjectStatus.onHold => 0.4,
      ProjectStatus.completed => 1.0,
    };
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: const Color(0xFFEFF3EF), borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.home_work_outlined, color: AppTheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(project.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration:
                          BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
                      child: Text(label,
                          style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text('${project.clientName} · ${project.location}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFEFF3EF),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
