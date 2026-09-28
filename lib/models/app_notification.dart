/// Une notification affichée dans la cloche de l'utilisateur.
class AppNotification {
  final String id;
  final String destinataireId; // uid de l'utilisateur concerné
  final String titre;
  final String message;
  final String? commandeId; // commande concernée, s'il y en a une
  final bool lue;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.destinataireId,
    required this.titre,
    required this.message,
    this.commandeId,
    required this.lue,
    required this.createdAt,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> map) {
    return AppNotification(
      id: id,
      destinataireId: map['destinataireId'] ?? '',
      titre: map['titre'] ?? '',
      message: map['message'] ?? '',
      commandeId: map['commandeId'],
      lue: map['lue'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }
}