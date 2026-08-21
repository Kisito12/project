import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/project.dart';
import '../models/project_task.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _firestore.collection('projects');

  Stream<List<Project>> watchProjects() {
    return _projects
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Project.fromDoc).toList());
  }

  /// Projects where the given field engineer is assigned.
  Stream<List<Project>> watchProjectsForEngineer(String engineerId) {
    return _projects
        .where('assignedEngineerIds', arrayContains: engineerId)
        .snapshots()
        .map((snap) => snap.docs.map(Project.fromDoc).toList());
  }

  Future<Project> createProject(Project project) async {
    final ref = await _projects.add(project.toMap());
    final doc = await ref.get();
    return Project.fromDoc(doc);
  }

  Future<void> updateStatus(String projectId, ProjectStatus status) async {
    await _projects.doc(projectId).update({'status': status.name});
  }

  Future<void> setAssignedEngineers(String projectId, List<String> engineerIds) async {
    await _projects.doc(projectId).update({'assignedEngineerIds': engineerIds});
  }

  Future<void> deleteProject(String projectId) async {
    await _projects.doc(projectId).delete();
  }

  // --- Tasks (subcollection) ---

  CollectionReference<Map<String, dynamic>> _tasks(String projectId) =>
      _projects.doc(projectId).collection('tasks');

  Stream<List<ProjectTask>> watchTasks(String projectId) {
    return _tasks(projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ProjectTask.fromDoc).toList());
  }

  Future<void> createTask(String projectId, ProjectTask task) async {
    await _tasks(projectId).add(task.toMap());
  }

  Future<void> updateTaskStatus(String projectId, String taskId, TaskStatus status) async {
    await _tasks(projectId).doc(taskId).update({'status': status.name});
  }

  Future<void> deleteTask(String projectId, String taskId) async {
    await _tasks(projectId).doc(taskId).delete();
  }

  /// Fraction of tasks completed (done) for a project, used for progress bars.
  Future<double> computeProgress(String projectId) async {
    final snap = await _tasks(projectId).get();
    if (snap.docs.isEmpty) return 0;
    final done = snap.docs.where((d) => d.data()['status'] == TaskStatus.done.name).length;
    return done / snap.docs.length;
  }
}
