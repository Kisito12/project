import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

class UserDirectoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppUser>> watchFieldEngineers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.fieldEngineer.name)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppUser.fromMap(d.id, d.data())).toList());
  }

  Future<Map<String, AppUser>> fetchUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return {};
    final result = <String, AppUser>{};
    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
      final snap = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        result[doc.id] = AppUser.fromMap(doc.id, doc.data());
      }
    }
    return result;
  }
}
