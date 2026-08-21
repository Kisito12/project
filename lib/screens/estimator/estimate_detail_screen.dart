import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/estimate.dart';

class EstimateDetailScreen extends StatelessWidget {
  final Estimate estimate;

  const EstimateDetailScreen({super.key, required this.estimate});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: '\$');
    final phasesWithItems =
        ConstructionPhase.values.where((p) => estimate.itemsForPhase(p).isNotEmpty);

    return Scaffold(
      appBar: AppBar(title: Text(estimate.title)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final phase in phasesWithItems) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                phase.label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Card(
              child: Column(
                children: [
                  for (final item in estimate.itemsForPhase(phase))
                    ListTile(
                      dense: true,
                      title: Text(item.description),
                      subtitle: Text(
                        '${item.quantity} ${item.unit} × ${currency.format(item.unitMaterialCost)} '
                        '+ labor ${currency.format(item.laborCost)}',
                      ),
                      trailing: Text(currency.format(item.total)),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Phase total: ${currency.format(estimate.phaseTotal(phase))}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _totalRow('Materials', currency.format(estimate.materialTotal)),
                  _totalRow('Labor', currency.format(estimate.laborTotal)),
                  const Divider(),
                  _totalRow(
                    'Grand total',
                    currency.format(estimate.grandTotal),
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
