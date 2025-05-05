import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialimpact/models/acao_voluntariado.dart';

class AcaoVoluntariadoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'Acao_de_voluntariado';

  Future<String> createAcao(AcaoVoluntariado acao) async {
    try{
      final docRef = await _db.collection(collectionPath).add(acao.toMap());
      return docRef.id;
    } catch(e){
      throw Exception("Erro ao criar ação de voluntariado: $e");
    }
  }

  Future<AcaoVoluntariado?> getAcaoById(String id) async {
    final doc = await _db.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    return AcaoVoluntariado.fromMap(doc.id, data);
  }

  Stream<List<AcaoVoluntariado>> getAcoesStream() {
    return _db.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AcaoVoluntariado.fromMap(doc.id, data);
      }).toList();
    });
  }

  // To verify, method to filter actions by institution
  Stream<List<AcaoVoluntariado>> getActionsByInstitution(String institutionId) {
  return _db
      .collection(collectionPath)
      .where('InstituiçãoID', isEqualTo: institutionId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => AcaoVoluntariado.fromMap(doc.id, doc.data()))
          .toList());
}

  Future<void> updateAcao(AcaoVoluntariado acao) async {
    if (acao.acaoVoluntariadoId.isEmpty) return;
    await _db.collection(collectionPath).doc(acao.acaoVoluntariadoId).update(acao.toMap());
  }

  Future<void> deleteAcao(String id) async {
    await _db.collection(collectionPath).doc(id).delete();
  }
}