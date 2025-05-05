// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class AcaoVoluntariado {
  final String acaoVoluntariadoId;
  final String instituicaoId; 
  final DateTime dataInicio; 
  final DateTime? dataFim;  
  final String descricaoDetalhada; 
  final String nome;
  final String numeroAcao; 
  final DateTime? diaHoraEnviarNotificacao; 

  AcaoVoluntariado({
    required this.acaoVoluntariadoId,
    required this.instituicaoId,
    required this.dataInicio,
    this.dataFim, 
    required this.descricaoDetalhada,
    required this.nome,
    required this.numeroAcao,
    this.diaHoraEnviarNotificacao,
  });

  factory AcaoVoluntariado.fromMap(String id, Map<String, dynamic> map) {
    return AcaoVoluntariado(
      acaoVoluntariadoId: id,
      instituicaoId: map['InstituiçãoID'] ?? '', 
      dataInicio: map['data_inicio'] is Timestamp 
        ? (map['data_inicio'] as Timestamp).toDate() 
        : DateTime.tryParse(map['data_inicio'] ?? '') ?? DateTime.now(), 
      dataFim: map['data_fim'] is Timestamp 
        ? (map['data_fim'] as Timestamp).toDate() 
        : (map['data_fim'] != null ? DateTime.tryParse(map['data_fim']) : null),
      descricaoDetalhada: map['descricao_detalhada'] ?? '',
      nome: map['nome'] ?? '',
      numeroAcao: map['numero_acao'] ?? '',
      diaHoraEnviarNotificacao: map['dia_hora_de_enviar_notificacao'] is Timestamp 
        ? (map['dia_hora_de_enviar_notificacao'] as Timestamp).toDate() 
        : (map['dia_hora_de_enviar_notificacao'] != null 
            ? DateTime.tryParse(map['dia_hora_de_enviar_notificacao']) 
            : null),
      );
  }


  Map<String, dynamic> toMap() {
    return {
      'InstituiçãoID': instituicaoId,
      'data_inicio': Timestamp.fromDate(dataInicio),
      'data_fim': dataFim != null ? Timestamp.fromDate(dataFim!) : null,
      'descricao_detalhada': descricaoDetalhada,
      'nome': nome,
      'numero_acao': numeroAcao,
      'dia_hora_de_enviar_notificacao': diaHoraEnviarNotificacao != null
          ? Timestamp.fromDate(diaHoraEnviarNotificacao!)
          : null,
    };
  }

}