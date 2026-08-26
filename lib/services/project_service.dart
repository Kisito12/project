import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/building_spec.dart';
import '../models/project.dart';
import '../models/project_task.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _projects =>
      _firestore.collection('projects');

  /// Every project on the platform - for the super admin's oversight view.
  Stream<List<Project>> watchAllProjects() {
    return _projects
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Project.fromDoc).toList());
  }

  /// All of a company's projects - for a company admin.
  Stream<List<Project>> watchProjectsForCompany(String companyId) {
    return _projects
        .where('companyId', isEqualTo: companyId)
        .snapshots()
        .map((snap) => snap.docs.map(Project.fromDoc).toList());
  }

  /// Only the projects a worker is assigned to.
  Stream<List<Project>> watchProjectsForWorker(String workerId) {
    return _projects
        .where('assignedWorkerIds', arrayContains: workerId)
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

  Future<void> setAssignedWorkers(String projectId, List<String> workerIds) async {
    await _projects.doc(projectId).update({'assignedWorkerIds': workerIds});
  }

  Future<void> updateBuildingSpec(String projectId, BuildingSpec spec) async {
    await _projects.doc(projectId).update({'buildingSpec': spec.toMap()});
  }

  Future<String> uploadPlan(String companyId, String projectId, File file, String fileName) async {
    final ref = _storage.ref('plans/$companyId/$projectId/$fileName');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await _projects.doc(projectId).update({'planFileUrl': url, 'planFileName': fileName});
    return url;
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
}
