import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/inspection.dart';

class InspectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _inspections =>
      _firestore.collection('inspections');

  Stream<List<Inspection>> watchInspectionsForProject(String projectId) {
    return _inspections
        .where('projectId', isEqualTo: projectId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Inspection.fromDoc).toList());
  }

  Future<List<String>> uploadPhotos(String projectId, List<File> files) async {
    final urls = <String>[];
    for (final file in files) {
      final id = const Uuid().v4();
      final ref = _storage.ref('inspection_photos/$projectId/$id.jpg');
      await ref.putFile(file);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }

  Future<void> createInspection(Inspection inspection) async {
    await _inspections.add(inspection.toMap());
  }
}
