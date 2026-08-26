import 'package:cloud_firestore/cloud_firestore.dart';

enum CompanyStatus { pending, approved, suspended }

CompanyStatus companyStatusFromString(String value) {
  return CompanyStatus.values.firstWhere(
    (s) => s.name == value,
    orElse: () => CompanyStatus.pending,
  );
}

/// A construction company operating on the platform. Each company manages
/// its own projects and workers; the platform's super admin approves new
/// companies and can suspend them.
class Company {
  final String id;
  final String name;
  final String contactEmail;
  final String phone;
  final CompanyStatus status;
  final String ownerId;
  final DateTime createdAt;

  const Company({
    required this.id,
    required this.name,
    required this.contactEmail,
    required this.phone,
    required this.status,
    required this.ownerId,
    required this.createdAt,
  });

  factory Company.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Company(
      id: doc.id,
      name: data['name'] as String? ?? '',
      contactEmail: data['contactEmail'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      status: companyStatusFromString(data['status'] as String? ?? 'pending'),
      ownerId: data['ownerId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'contactEmail': contactEmail,
      'phone': phone,
      'status': status.name,
      'ownerId': ownerId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
