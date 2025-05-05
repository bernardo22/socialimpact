import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialimpact/models/institucao.dart';

class InstituicaoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'Instituicao';

  Future<String> createInstituicao(Instituicao instituicao) async {
    final docRef = await _db.collection(collectionPath).add(instituicao.toMap());
    await docRef.update({'instituicaoId': docRef.id});
    return docRef.id;
  }

  Future<void> updateInstituicao(Instituicao instituicao) async {
    await _db
        .collection(collectionPath)
        .doc(instituicao.instituicaoId)
        .update(instituicao.toMap());
  }

  Future<void> deleteInstituicao(String instituicaoId) async {
    await _db.collection(collectionPath).doc(instituicaoId).delete();
  }

  Future<Instituicao?> getInstituicaoById(String id) async {
    final doc = await _db.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    return Instituicao.fromMap(doc.id, doc.data()!);
  }

  Future<Instituicao?> getInstituicaoByEmail(String email) async {
    final query = await _db
        .collection(collectionPath)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return Instituicao.fromMap(query.docs.first.id, query.docs.first.data());
  }

  Stream<List<Instituicao>> getInstituicaoStream() {
    return _db.collection(collectionPath).snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Instituicao.fromMap(doc.id, doc.data()))
            .toList());
  }
}