import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../services/project_service.dart';
import '../../services/user_directory_service.dart';

class AssignEngineersScreen extends StatefulWidget {
  final Project project;

  const AssignEngineersScreen({super.key, required this.project});

  @override
  State<AssignEngineersScreen> createState() => _AssignEngineersScreenState();
}

class _AssignEngineersScreenState extends State<AssignEngineersScreen> {
  late Set<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.project.assignedEngineerIds.toSet();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ProjectService().setAssignedEngineers(widget.project.id, _selected.toList());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign field engineers'),
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
        stream: UserDirectoryService().watchFieldEngineers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final engineers = snapshot.data!;
          if (engineers.isEmpty) {
            return const Center(child: Text('No field engineers registered yet.'));
          }
          return ListView(
            children: engineers
                .map(
                  (e) => CheckboxListTile(
                    title: Text(e.name),
                    subtitle: Text(e.email),
                    value: _selected.contains(e.uid),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selected.add(e.uid);
                        } else {
                          _selected.remove(e.uid);
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
