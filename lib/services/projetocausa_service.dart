import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialimpact/models/projeto_causa.dart';

class ProjetoCausaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'Projeto_Causa';

  Future<String> createProjetoCausa(ProjetoCausa projeto) async {
    try{
      final docRef = await _db.collection(collectionPath).add(projeto.toMap());
      return docRef.id;
    } catch(e){
      throw Exception("Erro ao criar Projeto: $e");
    }
  }

  Future<ProjetoCausa?> getProjetoCausaById(String id) async {
    final doc = await _db.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    return ProjetoCausa.fromMap(doc.id, data);
  }

  Stream<List<ProjetoCausa>> getProjetosCausaStream() {
    return _db.collection(collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ProjetoCausa.fromMap(doc.id, data);
      }).toList();
    });
  }

  Future<void> updateProjetoCausa(ProjetoCausa projeto) async {
    if (projeto.projetoCausaId.isEmpty) return;
    await _db.collection(collectionPath).doc(projeto.projetoCausaId).update(projeto.toMap());
  }

  Future<void> deleteProjetoCausa(String id) async {
    await _db.collection(collectionPath).doc(id).delete();
  }
}