class Client {
  final String uid;
  final String prenom;
  final String nom;
  final String telephone;
  final String adresse;

  Client({
    required this.uid,
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.adresse,
  });

  // Pratique pour afficher le nom complet dans l'appli
  String get nomComplet => '$prenom $nom';

  // Objet Dart -> Map pour Firestore
  // (l'uid n'est pas dedans, il sert d'ID au document)
  Map<String, dynamic> toMap() => {
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
        'adresse': adresse,
      };

  // Map Firestore -> objet Dart
  factory Client.fromMap(Map<String, dynamic> map, String uid) => Client(
        uid: uid,
        prenom: map['prenom'] ?? '',
        nom: map['nom'] ?? '',
        telephone: map['telephone'] ?? '',
        adresse: map['adresse'] ?? '',
      );
}
