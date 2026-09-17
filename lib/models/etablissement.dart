class Etablissement {
  final String id;
  final String nom;
  final String type; // 'restaurant', 'fast-food', 'maiga'
  final String description;
  final String adresse;
  final double latitude;
  final double longitude;
  final String categoriePrix; // '€', '€€', '€€€'
  final String photoUrl;
  final double noteMoyenne;
  final int nombreAvis;
  final String proprietaireId; // uid du gérant (Firebase Auth)

  Etablissement({
    required this.id,
    required this.nom,
    required this.type,
    required this.description,
    required this.adresse,
    required this.latitude,
    required this.longitude,
    required this.categoriePrix,
    required this.photoUrl,
    this.noteMoyenne = 0.0,
    this.nombreAvis = 0,
    required this.proprietaireId,
  });

  // Convertir un document Firestore en objet Etablissement
  factory Etablissement.fromMap(Map<String, dynamic> map, String id) {
    return Etablissement(
      id: id,
      nom: map['nom'] ?? '',
      type: map['type'] ?? 'restaurant',
      description: map['description'] ?? '',
      adresse: map['adresse'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      categoriePrix: map['categoriePrix'] ?? '€',
      photoUrl: map['photoUrl'] ?? '',
      noteMoyenne: (map['noteMoyenne'] ?? 0.0).toDouble(),
      nombreAvis: map['nombreAvis'] ?? 0,
      proprietaireId: map['proprietaireId'] ?? '',
    );
  }

  // Convertir l'objet en Map pour l'envoyer à Firestore
  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'type': type,
      'description': description,
      'adresse': adresse,
      'latitude': latitude,
      'longitude': longitude,
      'categoriePrix': categoriePrix,
      'photoUrl': photoUrl,
      'noteMoyenne': noteMoyenne,
      'nombreAvis': nombreAvis,
      'proprietaireId': proprietaireId,
    };
  }
}