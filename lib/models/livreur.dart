class Livreur {
  final String uid;
  final String prenom;
  final String nom;
  final String telephone;
  final String adresse;
  final String moyenDeplacement;

  Livreur({
    required this.uid,
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.adresse,
    required this.moyenDeplacement,
  });

  String get nomComplet => '$prenom $nom';

  Map<String, dynamic> toMap() => {
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
        'adresse': adresse,
        'moyenDeplacement': moyenDeplacement,
      };

  factory Livreur.fromMap(Map<String, dynamic> map, String uid) => Livreur(
        uid: uid,
        prenom: map['prenom'] ?? '',
        nom: map['nom'] ?? '',
        telephone: map['telephone'] ?? '',
        adresse: map['adresse'] ?? '',
        moyenDeplacement: map['moyenDeplacement'] ?? '',
      );
}