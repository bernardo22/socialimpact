class Participante {
  final String participanteAcaoVoluntariadoId;
  final String voluntarioId;
  final String acaoVoluntariadoId;
  final DateTime dataInscricao;
  final bool cancelou;
  final bool participou;

  Participante({
    required this.participanteAcaoVoluntariadoId,
    required this.voluntarioId,
    required this.acaoVoluntariadoId,
    required this.dataInscricao,
    required this.cancelou,
    required this.participou,
  });

  Map<String, dynamic> toMap() {
    return {
      'participanteAcaoVoluntariadoId': participanteAcaoVoluntariadoId,
      'voluntarioId': voluntarioId,
      'acaoVoluntariadoId': acaoVoluntariadoId,
      'dataInscricao': dataInscricao.toIso8601String(),
      'cancelou': cancelou,
      'participou': participou,
    };
  }

  factory Participante.fromMap(String id, Map<String, dynamic> data) {
    return Participante(
      participanteAcaoVoluntariadoId: id,
      voluntarioId: data['voluntarioId'] ?? '',
      acaoVoluntariadoId: data['acaoVoluntariadoId'] ?? '',
      dataInscricao: DateTime.parse(data['dataInscricao'] ?? DateTime.now().toIso8601String()),
      cancelou: data['cancelou'] ?? false,
      participou: data['participou'] ?? false,
    );
  }

  Participante copyWith({
    String? participanteAcaoVoluntariadoId,
    String? voluntarioId,
    String? acaoVoluntariadoId,
    DateTime? dataInscricao,
    bool? cancelou,
    bool? participou,
  }) {
    return Participante(
      participanteAcaoVoluntariadoId: participanteAcaoVoluntariadoId ?? this.participanteAcaoVoluntariadoId,
      voluntarioId: voluntarioId ?? this.voluntarioId,
      acaoVoluntariadoId: acaoVoluntariadoId ?? this.acaoVoluntariadoId,
      dataInscricao: dataInscricao ?? this.dataInscricao,
      cancelou: cancelou ?? this.cancelou,
      participou: participou ?? this.participou,
    );
  }
}