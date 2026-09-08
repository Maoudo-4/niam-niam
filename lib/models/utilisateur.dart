class Utilisateur {
  final String uid;
  final String nom;
  final String email;
  final String role; // "client", "gerant", ou "livreur"

  Utilisateur({
    required this.uid,
    required this.nom,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'email': email,
      'role': role,
    };
  }

  factory Utilisateur.fromMap(String uid, Map<String, dynamic> map) {
    return Utilisateur(
      uid: uid,
      nom: map['nom'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
    );
  }
}