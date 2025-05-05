// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class ProjetoCausa {
  final String projetoCausaId;
  final String instituicaoId; 
  final String categoria;
  final String nome;
  final DateTime dataProjeto;
  final double valorNecessario; 
  final double valorRecebido; 
  final String descricaoDetalhadaDoProjeto; 

  ProjetoCausa({
    required this.projetoCausaId,
    required this.instituicaoId,
    required this.categoria,
    required this.nome,
    required this.dataProjeto,
    required this.valorNecessario,
    required this.valorRecebido,
    required this.descricaoDetalhadaDoProjeto,
  });

  factory ProjetoCausa.fromMap(String id, Map<String, dynamic> map) {
    return ProjetoCausa(
      projetoCausaId: id,
      instituicaoId: map['InstituicaoID'] ?? '',
      categoria: map['categoria'] ?? '',
      nome: map['nome'] ?? '',
      dataProjeto: map['data_projeto'] != null
          ? (map['data_projeto'] as Timestamp).toDate()
          : DateTime.now(), 
      valorNecessario: (map['valor_necessario'] ?? 0.0).toDouble(),
      valorRecebido: (map['valor_recebido'] ?? 0.0).toDouble(),
      descricaoDetalhadaDoProjeto: map['descricao_detalhada_do_projeto'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'InstituicaoID': instituicaoId,
      'categoria': categoria,
      'nome': nome,
      'data_projeto': Timestamp.fromDate(dataProjeto), 
      'valor_necessario': valorNecessario,
      'valor_recebido': valorRecebido,
      'descricao_detalhada_do_projeto': descricaoDetalhadaDoProjeto,
    };
  }
}