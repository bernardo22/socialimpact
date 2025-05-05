// ignore_for_file: non_constant_identifier_names

class Voluntario {
  final String voluntarioId;
  final String nome;
  final String email;
  final String contacto;

  Voluntario({
    required this.voluntarioId,
    required this.nome,
    required this.email,
    required this.contacto,
  });

  factory Voluntario.fromMap(String id, Map<String, dynamic> map) {
    return Voluntario(
      voluntarioId: id, 
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      contacto: map['contacto'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'contacto': contacto,
    };
  }
}