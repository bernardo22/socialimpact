// ignore_for_file: non_constant_identifier_names

class Doador {
  final String doadorId; 
  final String nome;
  final String email;
  final String contacto;
  final String nif;

  Doador({
    required this.doadorId,
    required this.nome,
    required this.email,
    required this.contacto,
    required this.nif,
  });

  factory Doador.fromMap(String id, Map<String, dynamic> map) {
    return Doador(
      doadorId: id, 
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      contacto: map['contacto'] ?? '',
      nif: map['nif'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'contacto': contacto,
      'nif': nif,
    };
  }
}