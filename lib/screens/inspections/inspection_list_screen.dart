import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/inspection.dart';
import '../../models/project.dart';
import '../../services/inspection_service.dart';
import 'create_inspection_screen.dart';

class InspectionListScreen extends StatelessWidget {
  final Project project;
  final AppUser user;

  const InspectionListScreen({super.key, required this.project, required this.user});

  @override
  Widget build(BuildContext context) {
    final service = InspectionService();

    return Scaffold(
      body: StreamBuilder<List<Inspection>>(
        stream: service.watchInspectionsForProject(project.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final inspections = snapshot.data!;
          if (inspections.isEmpty) {
            return const Center(child: Text('No inspection reports yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: inspections.length,
            itemBuilder: (context, index) {
              final inspection = inspections[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _SeverityChip(severity: inspection.severity),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              inspection.inspectorName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            '${inspection.createdAt.month}/${inspection.createdAt.day}/${inspection.createdAt.year}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(inspection.summary),
                      if (inspection.photoUrls.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: inspection.photoUrls.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 6),
                            itemBuilder: (context, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: inspection.photoUrls[i],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => const SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CreateInspectionScreen(project: project, user: user)),
        ),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final DefectSeverity severity;

  const _SeverityChip({required this.severity});

  @override
  Widget build(BuildContext context) {
    final Color color;
    switch (severity) {
      case DefectSeverity.low:
        color = Colors.green;
        break;
      case DefectSeverity.medium:
        color = Colors.orange;
        break;
      case DefectSeverity.high:
        color = Colors.deepOrange;
        break;
      case DefectSeverity.critical:
        color = Colors.red;
        break;
    }
    return Chip(
      label: Text(
        severity.name.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
