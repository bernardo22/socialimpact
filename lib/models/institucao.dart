// ignore_for_file: non_constant_identifier_names

class Instituicao {
  final String instituicaoId; 
  final String nome;
  final String endereco;
  final String contacto;
  final String descricaoDetalhadaDaInstituicao; 
  final String email;

  Instituicao({
    required this.instituicaoId,
    required this.nome,
    required this.endereco,
    required this.contacto,
    required this.descricaoDetalhadaDaInstituicao,
    required this.email,
  });

  factory Instituicao.fromMap(String id, Map<String, dynamic> map) {
    return Instituicao(
      instituicaoId: id, 
      nome: map['nome'] ?? '',
      endereco: map['endereco'] ?? '',
      contacto: map['contacto'] ?? '',
      descricaoDetalhadaDaInstituicao: 
          map['descricao_detalhada_da_instituicao'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'endereco': endereco,
      'contacto': contacto,
      'descricao_detalhada_da_instituicao': descricaoDetalhadaDaInstituicao, 
      'email': email,
    };
  }
}