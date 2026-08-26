import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/company.dart';

class CompanyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _companies =>
      _firestore.collection('companies');

  /// All companies - for the super admin's oversight screen.
  Stream<List<Company>> watchAllCompanies() {
    return _companies
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Company.fromDoc).toList());
  }

  /// Only approved companies - shown to a worker choosing who to join.
  Stream<List<Company>> watchApprovedCompanies() {
    return _companies
        .where('status', isEqualTo: CompanyStatus.approved.name)
        .snapshots()
        .map((snap) => snap.docs.map(Company.fromDoc).toList());
  }

  Future<Company?> fetchCompany(String companyId) async {
    final doc = await _companies.doc(companyId).get();
    if (!doc.exists) return null;
    return Company.fromDoc(doc);
  }

  Stream<Company?> watchCompany(String companyId) {
    return _companies.doc(companyId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Company.fromDoc(doc);
    });
  }

  Future<Company> createCompany(Company company) async {
    final ref = await _companies.add(company.toMap());
    final doc = await ref.get();
    return Company.fromDoc(doc);
  }

  Future<void> setStatus(String companyId, CompanyStatus status) async {
    await _companies.doc(companyId).update({'status': status.name});
  }
}
