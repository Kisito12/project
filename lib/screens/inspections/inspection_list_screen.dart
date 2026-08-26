import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/inspection.dart';
import '../../models/project.dart';
import '../../services/inspection_service.dart';
import '../../theme/app_theme.dart';
import 'create_inspection_screen.dart';

class InspectionListScreen extends StatelessWidget {
  final Project project;
  final AppUser user;

  const InspectionListScreen({super.key, required this.project, required this.user});

  @override
  Widget build(BuildContext context) {
    final service = InspectionService();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: StreamBuilder<List<Inspection>>(
        stream: service.watchInspectionsForProject(project.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final inspections = snapshot.data!;
          if (inspections.isEmpty) {
            return const Center(
              child: Text('No inspection reports yet.', style: TextStyle(color: AppTheme.textSecondary)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: inspections.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final inspection = inspections[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.cardShadow,
                ),
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
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                        ),
                        Text(
                          '${inspection.createdAt.month}/${inspection.createdAt.day}/${inspection.createdAt.year}',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(inspection.summary, style: const TextStyle(fontSize: 13.5)),
                    if (inspection.photoUrls.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: inspection.photoUrls.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (context, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: inspection.photoUrls[i],
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => const SizedBox(
                                width: 72,
                                height: 72,
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CreateInspectionScreen(project: project, user: user)),
        ),
        child: const Icon(Icons.add_a_photo, color: Colors.white),
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
