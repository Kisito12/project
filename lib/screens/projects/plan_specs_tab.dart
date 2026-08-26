import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/app_user.dart';
import '../../models/building_spec.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../estimator/create_estimate_screen.dart';

/// Where the architect's plan drawing lives, and where its dimensions are
/// turned into a structured [BuildingSpec] used to auto-suggest a full
/// foundation-to-roofing cost estimate. The app does not read the plan
/// image itself - whoever is looking at it enters the room dimensions here.
class PlanSpecsTab extends StatefulWidget {
  final Project project;
  final AppUser user;

  const PlanSpecsTab({super.key, required this.project, required this.user});

  @override
  State<PlanSpecsTab> createState() => _PlanSpecsTabState();
}

class _PlanSpecsTabState extends State<PlanSpecsTab> {
  late BuildingSpec _spec = widget.project.buildingSpec;
  late final _floorsController = TextEditingController(text: _spec.floors.toString());
  late final _lengthController =
      TextEditingController(text: _spec.footprintLengthM == 0 ? '' : '${_spec.footprintLengthM}');
  late final _widthController =
      TextEditingController(text: _spec.footprintWidthM == 0 ? '' : '${_spec.footprintWidthM}');
  late final _heightController = TextEditingController(text: '${_spec.wallHeightM}');
  bool _uploadingPlan = false;
  bool _savingSpec = false;

  @override
  void dispose() {
    _floorsController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool get _canEdit => widget.user.isCompanyAdmin;

  Future<void> _uploadPlan() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() => _uploadingPlan = true);
    try {
      await ProjectService().uploadPlan(
        widget.project.companyId,
        widget.project.id,
        File(file.path),
        file.name,
      );
    } finally {
      if (mounted) setState(() => _uploadingPlan = false);
    }
  }

  BuildingSpec _readSpecFromForm() {
    return _spec.copyWith(
      floors: int.tryParse(_floorsController.text) ?? 1,
      footprintLengthM: double.tryParse(_lengthController.text) ?? 0,
      footprintWidthM: double.tryParse(_widthController.text) ?? 0,
      wallHeightM: double.tryParse(_heightController.text) ?? 3.0,
    );
  }

  Future<void> _saveSpec() async {
    setState(() {
      _spec = _readSpecFromForm();
      _savingSpec = true;
    });
    try {
      await ProjectService().updateBuildingSpec(widget.project.id, _spec);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Building specs saved')));
      }
    } finally {
      if (mounted) setState(() => _savingSpec = false);
    }
  }

  Future<void> _addRoom() async {
    final room = await showDialog<RoomSpec>(
      context: context,
      builder: (context) => const _AddRoomDialog(),
    );
    if (room != null) {
      setState(() => _spec = _readSpecFromForm().copyWith(rooms: [..._spec.rooms, room]));
    }
  }

  void _removeRoom(RoomSpec room) {
    setState(() {
      _spec = _readSpecFromForm().copyWith(
        rooms: _spec.rooms.where((r) => r.id != room.id).toList(),
      );
    });
  }

  Future<void> _generateEstimate() async {
    final spec = _readSpecFromForm();
    if (spec.footprintAreaM2 <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the building footprint (length × width) first')),
      );
      return;
    }
    setState(() => _spec = spec);
    await ProjectService().updateBuildingSpec(widget.project.id, spec);
    final items = TakeoffCalculator.generate(spec);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateEstimateScreen(
          project: widget.project,
          initialItems: items,
          initialTitle: '${widget.project.name} — Auto Estimate',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Architect\'s plan', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _PlanCard(
          project: widget.project,
          canEdit: _canEdit,
          uploading: _uploadingPlan,
          onUpload: _uploadPlan,
        ),
        const SizedBox(height: 24),
        Text('Building specs', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        const Text(
          'Enter the dimensions from the plan below - this drives the auto-generated '
          'estimate (foundation, walls, roofing, electrical, plumbing, finishes).',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        if (!_canEdit)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Only a company admin can edit specs.',
                style: TextStyle(fontSize: 12, color: Colors.black54)),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _floorsController,
                enabled: _canEdit,
                decoration: const InputDecoration(labelText: 'Floors'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _heightController,
                enabled: _canEdit,
                decoration: const InputDecoration(labelText: 'Wall height (m)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _lengthController,
                enabled: _canEdit,
                decoration: const InputDecoration(labelText: 'Footprint length (m)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _widthController,
                enabled: _canEdit,
                decoration: const InputDecoration(labelText: 'Footprint width (m)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<FoundationType>(
          initialValue: _spec.foundationType,
          decoration: const InputDecoration(labelText: 'Foundation type'),
          items: FoundationType.values
              .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
              .toList(),
          onChanged: _canEdit ? (t) => setState(() => _spec = _spec.copyWith(foundationType: t)) : null,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<RoofType>(
          initialValue: _spec.roofType,
          decoration: const InputDecoration(labelText: 'Roof type'),
          items: RoofType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
          onChanged: _canEdit ? (t) => setState(() => _spec = _spec.copyWith(roofType: t)) : null,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Rooms', style: Theme.of(context).textTheme.titleSmall),
            if (_canEdit)
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add room'),
                onPressed: _addRoom,
              ),
          ],
        ),
        for (final room in _spec.rooms)
          ListTile(
            dense: true,
            title: Text('${room.name} (${room.type.label})'),
            subtitle: Text('${room.lengthM}m × ${room.widthM}m = ${room.areaM2.toStringAsFixed(1)}m²'),
            trailing: _canEdit
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _removeRoom(room),
                  )
                : null,
          ),
        if (_canEdit) ...[
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: _savingSpec ? null : _saveSpec,
            child: _savingSpec
                ? const SizedBox(
                    height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save specs'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.calculate),
            label: const Text('Generate estimate from specs'),
            onPressed: _generateEstimate,
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Project project;
  final bool canEdit;
  final bool uploading;
  final VoidCallback onUpload;

  const _PlanCard({
    required this.project,
    required this.canEdit,
    required this.uploading,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (project.planFileUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: project.planFileUrl!,
                  fit: BoxFit.contain,
                  height: 220,
                  placeholder: (_, _) =>
                      const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No plan uploaded yet.', textAlign: TextAlign.center),
              ),
            if (canEdit) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: uploading
                    ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload_file),
                label: Text(project.planFileUrl == null ? 'Upload plan' : 'Replace plan'),
                onPressed: uploading ? null : onUpload,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddRoomDialog extends StatefulWidget {
  const _AddRoomDialog();

  @override
  State<_AddRoomDialog> createState() => _AddRoomDialogState();
}

class _AddRoomDialogState extends State<_AddRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  RoomType _type = RoomType.bedroom;

  @override
  void dispose() {
    _nameController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add room'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Room name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              autofocus: true,
            ),
            DropdownButtonFormField<RoomType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: RoomType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
              onChanged: (t) => setState(() => _type = t ?? RoomType.bedroom),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lengthController,
                    decoration: const InputDecoration(labelText: 'Length (m)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: _numberValidator,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    decoration: const InputDecoration(labelText: 'Width (m)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: _numberValidator,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(context).pop(
              RoomSpec.newRoom(
                name: _nameController.text.trim(),
                type: _type,
                lengthM: double.parse(_lengthController.text),
                widthM: double.parse(_widthController.text),
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
