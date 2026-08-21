import 'package:cloud_firestore/cloud_firestore.dart';

enum DefectSeverity { low, medium, high, critical }

DefectSeverity defectSeverityFromString(String value) {
  return DefectSeverity.values.firstWhere(
    (s) => s.name == value,
    orElse: () => DefectSeverity.low,
  );
}

class Inspection {
  final String id;
  final String projectId;
  final String inspectorId;
  final String inspectorName;
  final String summary;
  final DefectSeverity severity;
  final List<String> photoUrls;
  final DateTime createdAt;

  const Inspection({
    required this.id,
    required this.projectId,
    required this.inspectorId,
    required this.inspectorName,
    required this.summary,
    required this.severity,
    required this.photoUrls,
    required this.createdAt,
  });

  factory Inspection.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Inspection(
      id: doc.id,
      projectId: data['projectId'] as String? ?? '',
      inspectorId: data['inspectorId'] as String? ?? '',
      inspectorName: data['inspectorName'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      severity: defectSeverityFromString(data['severity'] as String? ?? 'low'),
      photoUrls: List<String>.from(data['photoUrls'] as List? ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'inspectorId': inspectorId,
      'inspectorName': inspectorName,
      'summary': summary,
      'severity': severity.name,
      'photoUrls': photoUrls,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
