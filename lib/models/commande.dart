class Commande {
  final String id;
  final String clientId;
  final String etablissementId;
  final List<LigneCommande> lignes;
  final double montant;
  final String statut;
  final String? livreurId; // null tant qu'aucun livreur n'est assigné
  final DateTime createdAt;

  /// Ancien champ texte libre, gardé pour les commandes créées avant
  /// l'introduction du panier multi-plats (elles n'ont pas de "lignes").
  final String? _descriptionHeritee;

  Commande({
    required this.id,
    required this.clientId,
    required this.etablissementId,
    required this.lignes,
    required this.montant,
    required this.statut,
    this.livreurId,
    required this.createdAt,
    String? descriptionHeritee,
  }) : _descriptionHeritee = descriptionHeritee;

  /// Texte d'affichage : généré à partir des lignes du panier si elles
  /// existent (nouveau format), sinon on retombe sur l'ancien texte libre
  /// (commandes créées avant le panier multi-plats).
  String get description {
    if (lignes.isNotEmpty) {
      return lignes.map((l) => '${l.nom} x${l.quantite}').join(', ');
    }
    return _descriptionHeritee ?? '';
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'etablissementId': etablissementId,
      'lignes': lignes.map((l) => l.toMap()).toList(),
      'montant': montant,
      'statut': statut,
      'livreurId': livreurId,
      'createdAt': createdAt,
    };
  }

  factory Commande.fromMap(String id, Map<String, dynamic> map) {
    return Commande(
      id: id,
      clientId: map['clientId'] ?? '',
      etablissementId: map['etablissementId'] ?? '',
      lignes: ((map['lignes'] as List?) ?? [])
          .map((l) => LigneCommande.fromMap(l as Map<String, dynamic>))
          .toList(),
      montant: (map['montant'] ?? 0).toDouble(),
      statut: map['statut'] ?? StatutCommande.confirmee,
      livreurId: map['livreurId'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      descriptionHeritee: map['description'] as String?,
    );
  }
}

/// Une ligne du panier : un produit, son prix au moment de la commande,
/// et la quantité choisie.
class LigneCommande {
  final String produitId;
  final String nom;
  final double prixUnitaire;
  final int quantite;

  LigneCommande({
    required this.produitId,
    required this.nom,
    required this.prixUnitaire,
    required this.quantite,
  });

  double get sousTotal => prixUnitaire * quantite;

  Map<String, dynamic> toMap() {
    return {
      'produitId': produitId,
      'nom': nom,
      'prixUnitaire': prixUnitaire,
      'quantite': quantite,
    };
  }

  factory LigneCommande.fromMap(Map<String, dynamic> map) {
    return LigneCommande(
      produitId: map['produitId'] ?? '',
      nom: map['nom'] ?? '',
      prixUnitaire: (map['prixUnitaire'] ?? 0).toDouble(),
      quantite: (map['quantite'] ?? 0) as int,
    );
  }
}

class StatutCommande {
  static const confirmee = 'confirmee';
  static const enPreparation = 'en_preparation';
  static const livreurAssigne = 'livreur_assigne';
  static const recuperee = 'recuperee';
  static const enRoute = 'en_route';
  static const livree = 'livree';

  static const ordre = [
    confirmee,
    enPreparation,
    livreurAssigne,
    recuperee,
    enRoute,
    livree,
  ];

  static String libelle(String statut) {
    switch (statut) {
      case confirmee: return 'Commande confirmée';
      case enPreparation: return 'En préparation';
      case livreurAssigne: return 'Livreur assigné';
      case recuperee: return 'Récupérée par le livreur';
      case enRoute: return 'En route';
      case livree: return 'Livrée';
      default: return statut;
    }
  }
}