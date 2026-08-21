import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/estimate.dart';

class EstimateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _estimates =>
      _firestore.collection('estimates');

  Stream<List<Estimate>> watchEstimatesForProject(String projectId) {
    return _estimates
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Estimate.fromDoc).toList());
  }

  Future<void> saveEstimate(Estimate estimate) async {
    await _estimates.add(estimate.toMap());
  }

  Future<void> deleteEstimate(String estimateId) async {
    await _estimates.doc(estimateId).delete();
  }
}
