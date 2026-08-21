import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/project.dart';
import '../../models/project_task.dart';
import '../../services/app_state.dart';
import '../../services/project_service.dart';
import '../../services/user_directory_service.dart';

class TasksTab extends StatelessWidget {
  final Project project;

  const TasksTab({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser!;
    final projectService = ProjectService();

    return Scaffold(
      body: StreamBuilder<List<ProjectTask>>(
        stream: projectService.watchTasks(project.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks yet.'));
          }
          final doneCount = tasks.where((t) => t.status == TaskStatus.done).length;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress: $doneCount / ${tasks.length} tasks complete'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: tasks.isEmpty ? 0 : doneCount / tasks.length,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return CheckboxListTile(
                      value: task.status == TaskStatus.done,
                      title: Text(
                        task.title,
                        style: task.status == TaskStatus.done
                            ? const TextStyle(decoration: TextDecoration.lineThrough)
                            : null,
                      ),
                      subtitle: task.notes.isEmpty ? null : Text(task.notes),
                      onChanged: (checked) {
                        projectService.updateTaskStatus(
                          project.id,
                          task.id,
                          checked == true ? TaskStatus.done : TaskStatus.todo,
                        );
                      },
                      secondary: user.isAdmin
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  projectService.deleteTask(project.id, task.id),
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    String? assignedToId;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<AppUser>>(
                stream: UserDirectoryService().watchFieldEngineers(),
                builder: (context, snapshot) {
                  final engineers = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    initialValue: assignedToId,
                    decoration: const InputDecoration(labelText: 'Assign to (optional)'),
                    items: engineers
                        .map((e) => DropdownMenuItem(value: e.uid, child: Text(e.name)))
                        .toList(),
                    onChanged: (v) => assignedToId = v,
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                ProjectService().createTask(
                  project.id,
                  ProjectTask(
                    id: '',
                    title: titleController.text.trim(),
                    notes: notesController.text.trim(),
                    status: TaskStatus.todo,
                    assignedToId: assignedToId,
                    dueDate: null,
                    createdAt: DateTime.now(),
                  ),
                );
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
