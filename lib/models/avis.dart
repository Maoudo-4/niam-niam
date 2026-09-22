/// Un avis laisse par un client sur une commande livree.
/// L'ID du document est l'ID de la commande : une commande = un seul avis.
class Avis {
  final String id; // = id de la commande notee
  final String clientId;
  final String etablissementId;
  final int note; // de 1 a 5
  final String commentaire;
  final DateTime createdAt;

  Avis({
    required this.id,
    required this.clientId,
    required this.etablissementId,
    required this.note,
    required this.commentaire,
    required this.createdAt,
  });

  factory Avis.fromMap(String id, Map<String, dynamic> map) {
    return Avis(
      id: id,
      clientId: map['clientId'] ?? '',
      etablissementId: map['etablissementId'] ?? '',
      note: ((map['note'] ?? 0) as num).toInt(),
      commentaire: map['commentaire'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}