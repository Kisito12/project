import 'package:cloud_firestore/cloud_firestore.dart';

import 'building_spec.dart';

enum ProjectStatus { planning, active, onHold, completed }

ProjectStatus projectStatusFromString(String value) {
  return ProjectStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => ProjectStatus.planning,
  );
}

class Project {
  final String id;
  final String companyId;
  final String name;
  final String location;
  final String description;
  final String clientName;
  final String clientPhone;
  final String clientAddress;
  final ProjectStatus status;
  final String createdBy;
  final List<String> assignedWorkerIds;
  final String? planFileUrl;
  final String? planFileName;
  final BuildingSpec buildingSpec;
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.companyId,
    required this.name,
    required this.location,
    required this.description,
    required this.clientName,
    required this.clientPhone,
    required this.clientAddress,
    required this.status,
    required this.createdBy,
    required this.assignedWorkerIds,
    required this.planFileUrl,
    required this.planFileName,
    required this.buildingSpec,
    required this.createdAt,
  });

  factory Project.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Project(
      id: doc.id,
      companyId: data['companyId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      location: data['location'] as String? ?? '',
      description: data['description'] as String? ?? '',
      clientName: data['clientName'] as String? ?? '',
      clientPhone: data['clientPhone'] as String? ?? '',
      clientAddress: data['clientAddress'] as String? ?? '',
      status: projectStatusFromString(data['status'] as String? ?? 'planning'),
      createdBy: data['createdBy'] as String? ?? '',
      assignedWorkerIds: List<String>.from(data['assignedWorkerIds'] as List? ?? []),
      planFileUrl: data['planFileUrl'] as String?,
      planFileName: data['planFileName'] as String?,
      buildingSpec: BuildingSpec.fromMap(data['buildingSpec'] as Map<String, dynamic>?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'name': name,
      'location': location,
      'description': description,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'clientAddress': clientAddress,
      'status': status.name,
      'createdBy': createdBy,
      'assignedWorkerIds': assignedWorkerIds,
      'planFileUrl': planFileUrl,
      'planFileName': planFileName,
      'buildingSpec': buildingSpec.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
