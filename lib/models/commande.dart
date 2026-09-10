class Commande {
  final String id;
  final String clientId;
  final String etablissementId;
  final String description;
  final double montant;
  final String statut;
  final String? livreurId; // null tant qu'aucun livreur n'est assigné
  final DateTime createdAt;

  Commande({
    required this.id,
    required this.clientId,
    required this.etablissementId,
    required this.description,
    required this.montant,
    required this.statut,
    this.livreurId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'etablissementId': etablissementId,
      'description': description,
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
      description: map['description'] ?? '',
      montant: (map['montant'] ?? 0).toDouble(),
      statut: map['statut'] ?? StatutCommande.confirmee,
      livreurId: map['livreurId'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
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