class Doacao {
  final String doacaoId;
  final String doadorId;
  final String projetoCausaId;
  final double valorDoado;
  final DateTime dataDoacao;

  Doacao({
    required this.doacaoId,
    required this.doadorId,
    required this.projetoCausaId,
    required this.valorDoado,
    required this.dataDoacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'doacaoId': doacaoId,
      'doadorId': doadorId,
      'projetoCausaId': projetoCausaId,
      'valorDoado': valorDoado,
      'dataDoacao': dataDoacao.toIso8601String(),
    };
  }

  factory Doacao.fromMap(String id, Map<String, dynamic> data) {
    return Doacao(
      doacaoId: id,
      doadorId: data['doadorId'] ?? '',
      projetoCausaId: data['projetoCausaId'] ?? '',
      valorDoado: (data['valorDoado'] as num?)?.toDouble() ?? 0.0,
      dataDoacao: DateTime.tryParse(data['dataDoacao'] ?? '') ?? DateTime.now(),
    );
  }
}