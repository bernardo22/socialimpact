import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialimpact/models/doador.dart';

class DoadorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'Doador';

  Future<String> createDoador(Doador doador) async {
    final docRef = await _db.collection(collectionPath).add(doador.toMap());
    await docRef.update({'doadorId': docRef.id});
    return docRef.id;
  }

  Future<void> updateDoador(Doador doador) async {
    await _db
        .collection(collectionPath)
        .doc(doador.doadorId)
        .update(doador.toMap());
  }

  Future<void> deleteDoador(String doadorId) async {
    await _db.collection(collectionPath).doc(doadorId).delete();
  }

  Future<Doador?> getDoadorById(String id) async {
    final doc = await _db.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return Doador.fromMap(doc.id, doc.data()!);
  }

  Future<Doador?> getDoadorByEmail(String email) async {
    final query = await _db
        .collection(collectionPath)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return Doador.fromMap(query.docs.first.id, query.docs.first.data());
  }

  Stream<List<Doador>> getDoadorStream() {
    return _db.collection(collectionPath).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Doador.fromMap(doc.id, doc.data()))
            .toList());
  }
}