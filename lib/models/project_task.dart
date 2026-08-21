import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskStatus { todo, inProgress, done }

TaskStatus taskStatusFromString(String value) {
  return TaskStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => TaskStatus.todo,
  );
}

class ProjectTask {
  final String id;
  final String title;
  final String notes;
  final TaskStatus status;
  final String? assignedToId;
  final DateTime? dueDate;
  final DateTime createdAt;

  const ProjectTask({
    required this.id,
    required this.title,
    required this.notes,
    required this.status,
    required this.assignedToId,
    required this.dueDate,
    required this.createdAt,
  });

  factory ProjectTask.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ProjectTask(
      id: doc.id,
      title: data['title'] as String? ?? '',
      notes: data['notes'] as String? ?? '',
      status: taskStatusFromString(data['status'] as String? ?? 'todo'),
      assignedToId: data['assignedToId'] as String?,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'notes': notes,
      'status': status.name,
      'assignedToId': assignedToId,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
