import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/app_user.dart';
import '../../models/inspection.dart';
import '../../models/project.dart';
import '../../services/inspection_service.dart';

class CreateInspectionScreen extends StatefulWidget {
  final Project project;
  final AppUser user;

  const CreateInspectionScreen({super.key, required this.project, required this.user});

  @override
  State<CreateInspectionScreen> createState() => _CreateInspectionScreenState();
}

class _CreateInspectionScreenState extends State<CreateInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  DefectSeverity _severity = DefectSeverity.low;
  final List<File> _photos = [];
  bool _submitting = false;

  @override
  void dispose() {
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (file != null) {
      setState(() => _photos.add(File(file.path)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final service = InspectionService();
      final photoUrls = await service.uploadPhotos(widget.project.id, _photos);
      await service.createInspection(
        Inspection(
          id: '',
          companyId: widget.project.companyId,
          projectId: widget.project.id,
          inspectorId: widget.user.uid,
          inspectorName: widget.user.name,
          summary: _summaryController.text.trim(),
          severity: _severity,
          photoUrls: photoUrls,
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
      appBar: AppBar(title: const Text('New inspection report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: 'Findings / defect notes',
                ),
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<DefectSeverity>(
                initialValue: _severity,
                decoration: const InputDecoration(labelText: 'Severity'),
                items: DefectSeverity.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase())))
                    .toList(),
                onChanged: (v) => setState(() => _severity = v ?? DefectSeverity.low),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._photos.map(
                    (f) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(f, width: 80, height: 80, fit: BoxFit.cover),
                    ),
                  ),
                  InkWell(
                    onTap: _pickPhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
