import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialimpact/models/doacao.dart';


class DoacaoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'Doacao';


  Future<void> createDoacao(Doacao doacao) async {  
    final projetoRef = _db.collection('Projeto_Causa').doc(doacao.projetoCausaId);

    await _db.runTransaction((transaction) async {
      final projetoSnapshot = await transaction.get(projetoRef);
      if (!projetoSnapshot.exists) throw Exception('Projeto não encontrado');

      final valorRecebidoAtual = (projetoSnapshot.data()?['valor_recebido'] ?? 0.0) as double;
      final novoValorRecebido = valorRecebidoAtual + doacao.valorDoado;

      final doacaoRef = _db.collection('Doacao').doc();
      transaction.set(doacaoRef, doacao.toMap());

      transaction.update(projetoRef, {'valor_recebido': novoValorRecebido});
    });
  }

  Future<Doacao?> getDoacaoById(String id) async {
    final doc = await _db.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    return Doacao.fromMap(doc.id, data);
  }

  Stream<List<Doacao>> getDoacoesStream() {
    return _db.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Doacao.fromMap(doc.id, data);
      }).toList();
    });
  }

  Stream<List<Doacao>> getDoacoesByProjeto(String projetoCausaId) {
      return _db
      .collection(collectionPath)
      .where('projetoCausaId', isEqualTo: projetoCausaId)
      .snapshots()
      .map((snapshot) {
        final doacoes = snapshot.docs
            .map((doc) => Doacao.fromMap(doc.id, doc.data()))
            .toList();
        return doacoes;
      });
  } 

  Stream<List<Doacao>> getDoacoesByDoador(String doadorId) {
    return _db
      .collection(collectionPath)
      .where('doadorId', isEqualTo: doadorId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Doacao.fromMap(doc.id, doc.data()))
          .toList());
  }

  Future<void> updateDoacao(Doacao doacao) async {
    if (doacao.doacaoId.isEmpty) return;
    await _db.collection(collectionPath).doc(doacao.doacaoId).update(doacao.toMap());
  }

  Future<void> deleteDoacao(String id) async {
    await _db.collection(collectionPath).doc(id).delete();
  }
}