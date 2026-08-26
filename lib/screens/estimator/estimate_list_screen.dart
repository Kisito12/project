import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/estimate.dart';
import '../../models/project.dart';
import '../../services/estimate_service.dart';
import '../../theme/app_theme.dart';
import 'create_estimate_screen.dart';
import 'estimate_detail_screen.dart';

class EstimateListScreen extends StatelessWidget {
  final Project project;

  const EstimateListScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final service = EstimateService();
    final currency = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: StreamBuilder<List<Estimate>>(
        stream: service.watchEstimatesForProject(project.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final estimates = snapshot.data!;
          if (estimates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No cost estimates yet. Build one covering foundation through '
                  'roofing, with materials and labor.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: estimates.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final estimate = estimates[index];
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EstimateDetailScreen(estimate: estimate)),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3EF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calculate_outlined, color: AppTheme.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(estimate.title,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5)),
                            const SizedBox(height: 3),
                            Text(
                              'Materials ${currency.format(estimate.materialTotal)} · '
                              'Labor ${currency.format(estimate.laborTotal)}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currency.format(estimate.grandTotal),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CreateEstimateScreen(project: project)),
        ),
        icon: const Icon(Icons.calculate, color: Colors.white),
        label: const Text('New estimate', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
