import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/estimate.dart';
import '../../models/project.dart';
import '../../services/app_state.dart';
import '../../services/estimate_service.dart';

class CreateEstimateScreen extends StatefulWidget {
  final Project project;

  /// Pre-fills the estimate with quantities suggested by the plan/spec
  /// takeoff, still fully editable before saving.
  final List<EstimateItem> initialItems;
  final String initialTitle;

  const CreateEstimateScreen({
    super.key,
    required this.project,
    this.initialItems = const [],
    this.initialTitle = 'Cost Estimate',
  });

  @override
  State<CreateEstimateScreen> createState() => _CreateEstimateScreenState();
}

class _CreateEstimateScreenState extends State<CreateEstimateScreen> {
  late final _titleController = TextEditingController(text: widget.initialTitle);
  late final List<EstimateItem> _items = List.of(widget.initialItems);
  bool _submitting = false;

  final _currency = NumberFormat.currency(symbol: '\$');

  double get _materialTotal => _items.fold(0, (sum, i) => sum + i.materialTotal);
  double get _laborTotal => _items.fold(0, (sum, i) => sum + i.laborCost);
  double get _grandTotal => _materialTotal + _laborTotal;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _addItem(ConstructionPhase phase) async {
    final result = await showDialog<EstimateItem>(
      context: context,
      builder: (context) => _AddItemDialog(phase: phase),
    );
    if (result != null) {
      setState(() => _items.add(result));
    }
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add at least one line item')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final user = context.read<AppState>().currentUser!;
      await EstimateService().saveEstimate(
        Estimate(
          id: '',
          companyId: widget.project.companyId,
          projectId: widget.project.id,
          title: _titleController.text.trim().isEmpty
              ? 'Cost Estimate'
              : _titleController.text.trim(),
          items: _items,
          createdBy: user.uid,
          createdAt: DateTime.now(),
        ),
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build cost estimate'),
        actions: [
          IconButton(
            icon: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save),
            onPressed: _submitting ? null : _save,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Estimate title'),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (final phase in ConstructionPhase.values)
                  ExpansionTile(
                    title: Text(phase.label),
                    subtitle: Text(
                      _currency.format(
                        _items
                            .where((i) => i.phase == phase)
                            .fold<double>(0, (sum, i) => sum + i.total),
                      ),
                    ),
                    children: [
                      for (final item in _items.where((i) => i.phase == phase))
                        ListTile(
                          dense: true,
                          title: Text(item.description),
                          subtitle: Text(
                            '${item.quantity} ${item.unit} × ${_currency.format(item.unitMaterialCost)} '
                            '+ labor ${_currency.format(item.laborCost)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => setState(() => _items.remove(item)),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add item'),
                          onPressed: () => _addItem(phase),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Materials ${_currency.format(_materialTotal)} · '
                  'Labor ${_currency.format(_laborTotal)}',
                ),
                Text(
                  'Total: ${_currency.format(_grandTotal)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final ConstructionPhase phase;

  const _AddItemDialog({required this.phase});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController(text: 'unit');
  final _materialCostController = TextEditingController(text: '0');
  final _laborCostController = TextEditingController(text: '0');

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _materialCostController.dispose();
    _laborCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add item — ${widget.phase.label}'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                autofocus: true,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: _numberValidator,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _materialCostController,
                decoration: const InputDecoration(labelText: 'Unit material cost'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _numberValidator,
              ),
              TextFormField(
                controller: _laborCostController,
                decoration: const InputDecoration(labelText: 'Labor cost'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: _numberValidator,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              EstimateItem.newItem(
                phase: widget.phase,
                description: _descriptionController.text.trim(),
                quantity: double.parse(_quantityController.text),
                unit: _unitController.text.trim(),
                unitMaterialCost: double.parse(_materialCostController.text),
                laborCost: double.parse(_laborCostController.text),
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  String? _numberValidator(String? v) {
    if (v == null || double.tryParse(v) == null) return 'Enter a number';
    return null;
  }
}
