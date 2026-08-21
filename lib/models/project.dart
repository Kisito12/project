import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus { planning, active, onHold, completed }

ProjectStatus projectStatusFromString(String value) {
  return ProjectStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => ProjectStatus.planning,
  );
}

class Project {
  final String id;
  final String name;
  final String location;
  final String description;
  final ProjectStatus status;
  final String createdBy;
  final List<String> assignedEngineerIds;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.status,
    required this.createdBy,
    required this.assignedEngineerIds,
    required this.createdAt,
  });

  factory Project.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Project(
      id: doc.id,
      name: data['name'] as String? ?? '',
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: projectStatusFromString(data['status'] as String? ?? 'planning'),
      createdBy: data['createdBy'] as String? ?? '',
      assignedEngineerIds: List<String>.from(data['assignedEngineerIds'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'status': status.name,
      'createdBy': createdBy,
      'assignedEngineerIds': assignedEngineerIds,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
