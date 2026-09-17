class Produit {
  final String id;
  final String etablissementId;
  final String nom;
  final double prix;
  final String categorie; // ex. "restaurant", "fast-food", "maiga"

  Produit({
    required this.id,
    required this.etablissementId,
    required this.nom,
    required this.prix,
    required this.categorie,
  });

  factory Produit.fromMap(String id, Map<String, dynamic> map) {
    return Produit(
      id: id,
      etablissementId: map['etablissementId'] ?? '',
      nom: map['nom'] ?? '',
      prix: (map['prix'] ?? 0).toDouble(),
      categorie: map['categorie'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) => other is Produit && other.id == id;

  @override
  int get hashCode => id.hashCode;

}