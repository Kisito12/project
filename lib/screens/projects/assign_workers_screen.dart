import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../services/user_directory_service.dart';

class AssignWorkersScreen extends StatefulWidget {
  final Project project;

  const AssignWorkersScreen({super.key, required this.project});

  @override
  State<AssignWorkersScreen> createState() => _AssignWorkersScreenState();
}

class _AssignWorkersScreenState extends State<AssignWorkersScreen> {
  late Set<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.project.assignedWorkerIds.toSet();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ProjectService().setAssignedWorkers(widget.project.id, _selected.toList());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign workers'),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check),
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
      body: StreamBuilder<List<AppUser>>(
        stream: UserDirectoryService().watchCompanyWorkers(widget.project.companyId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final workers = snapshot.data!;
          if (workers.isEmpty) {
            return const Center(child: Text('No workers have joined your company yet.'));
          }
          return ListView(
            children: workers
                .map(
                  (w) => CheckboxListTile(
                    title: Text(w.name),
                    subtitle: Text(w.email),
                    value: _selected.contains(w.uid),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selected.add(w.uid);
                        } else {
                          _selected.remove(w.uid);
                        }
                      });
                    },
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
