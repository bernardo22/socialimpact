import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialimpact/models/voluntario.dart';

class VoluntarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'Voluntario';

  Future<String> createVoluntario(Voluntario voluntario) async {
    final docRef = await _db.collection(collectionPath).add(voluntario.toMap());
    await docRef.update({'voluntarioId': docRef.id});
    return docRef.id;
  }

  Future<void> updateVoluntario(Voluntario voluntario) async {
    await _db
        .collection(collectionPath)
        .doc(voluntario.voluntarioId)
        .update(voluntario.toMap());
  }

  Future<void> deleteVoluntario(String voluntarioId) async {
    await _db.collection(collectionPath).doc(voluntarioId).delete();
  }

  Future<Voluntario?> getVoluntarioById(String id) async {
    final doc = await _db.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return Voluntario.fromMap(doc.id, doc.data()!);
  }

  Future<Voluntario?> getVoluntarioByEmail(String email) async {
    final query = await _db
        .collection(collectionPath)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return Voluntario.fromMap(query.docs.first.id, query.docs.first.data());
  }

  Stream<List<Voluntario>> getVoluntarioStream() {
    return _db.collection(collectionPath).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Voluntario.fromMap(doc.id, doc.data()))
            .toList());
  }
}