import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialimpact/models/participante.dart';

class ParticipanteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'Participantes_da_acao_de_voluntariado';

  Future<String> createParticipante(Participante participante) async {
    final docRef = await _db.collection(collectionPath).add(participante.toMap());
    await docRef.update({'participanteAcaoVoluntariadoId': docRef.id});
    return docRef.id;
  }

  Future<Participante?> getParticipanteById(String id) async {
    final doc = await _db.collection(collectionPath).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    return Participante.fromMap(doc.id, data);
  }

  Stream<List<Participante>> getParticipantesStream() {
     return _db.collection(collectionPath).snapshots().map((snapshot) {
      final participants = snapshot.docs
          .map((doc) => Participante.fromMap(doc.id, doc.data()))
          .toList();
      print('Buscar ${participants.length} participantse do Firestore');
      return participants;
    });
  }

  Future<void> updateParticipante(Participante participante) async {
    if (participante.participanteAcaoVoluntariadoId.isEmpty) {
      throw Exception('ParticipanteAcaoVoluntariadoId não pode ser vasio para update');
    }
    await _db
        .collection(collectionPath)
        .doc(participante.participanteAcaoVoluntariadoId)
        .update(participante.toMap());
  }

  Stream<List<Participante>> getParticipantesByVoluntario(String voluntarioId) {
    return _db
        .collection(collectionPath)
        .where('voluntarioId', isEqualTo: voluntarioId)
        .snapshots()
        .map((snapshot) {
      final participantes = snapshot.docs
          .map((doc) => Participante.fromMap(doc.id, doc.data()))
          .toList();
      print('Fetched ${participantes.length} participantes for voluntario $voluntarioId');
      return participantes;
    });
  }

  Future<void> deleteParticipante(String id) async {
    await _db.collection(collectionPath).doc(id).delete();
  }
}