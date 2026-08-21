import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/estimate.dart';
import '../../models/project.dart';
import '../../services/estimate_service.dart';
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
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: estimates.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final estimate = estimates[index];
              return Card(
                child: ListTile(
                  title: Text(estimate.title),
                  subtitle: Text(
                    'Materials ${currency.format(estimate.materialTotal)} · '
                    'Labor ${currency.format(estimate.laborTotal)}',
                  ),
                  trailing: Text(
                    currency.format(estimate.grandTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => EstimateDetailScreen(estimate: estimate)),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CreateEstimateScreen(project: project)),
        ),
        icon: const Icon(Icons.calculate),
        label: const Text('New estimate'),
      ),
    );
  }
}
