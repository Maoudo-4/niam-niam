import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';
import '../models/commande.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('notifications');

  // Notifications d'un utilisateur, la plus récente d'abord.
  // Le tri se fait ici plutôt que dans la requête, pour ne pas exiger
  // d'index Firestore supplémentaire.
  Stream<List<AppNotification>> mesNotifications(String uid) {
    return _col
        .where('destinataireId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final liste = snap.docs
          .map((d) => AppNotification.fromMap(d.id, d.data()))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return liste;
    });
  }

  // Nombre de notifications non lues, pour le badge de la cloche
  Stream<int> nombreNonLues(String uid) {
    return _col
        .where('destinataireId', isEqualTo: uid)
        .where('lue', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // Envoie une notification à un utilisateur
  Future<void> envoyer({
    required String destinataireId,
    required String titre,
    required String message,
    String? commandeId,
  }) async {
    await _col.add({
      'destinataireId': destinataireId,
      'titre': titre,
      'message': message,
      'commandeId': commandeId,
      'lue': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Envoie la même notification à tous les livreurs inscrits
  // (une notification par livreur, pour que chacun la marque comme lue à part)
  Future<void> envoyerAuxLivreurs({
    required String titre,
    required String message,
    String? commandeId,
  }) async {
    final livreurs = await _db.collection('livreurs').get();
    final batch = _db.batch();
    for (final doc in livreurs.docs) {
      batch.set(_col.doc(), {
        'destinataireId': doc.id,
        'titre': titre,
        'message': message,
        'commandeId': commandeId,
        'lue': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> marquerCommeLue(String notificationId) async {
    await _col.doc(notificationId).update({'lue': true});
  }

  Future<void> toutMarquerCommeLu(String uid) async {
    final snap = await _col
        .where('destinataireId', isEqualTo: uid)
        .where('lue', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'lue': true});
    }
    await batch.commit();
  }

  // ---- Envois automatiques aux bons moments ----

  // Une commande vient d'être passée : prévient le gérant de l'établissement
  Future<void> notifierNouvelleCommande({
    required String commandeId,
    required String etablissementId,
    required String description,
    required double montant,
  }) async {
    final proprietaireId = await _proprietaireDe(etablissementId);
    if (proprietaireId == null) return;
    await envoyer(
      destinataireId: proprietaireId,
      titre: 'Nouvelle commande',
      message: '$description — ${montant.toStringAsFixed(0)} FCFA. '
          'Consultez vos commandes reçues.',
      commandeId: commandeId,
    );
  }

  // Le statut d'une commande vient de changer : prévient les bonnes personnes
  Future<void> notifierChangementStatut(
      String commandeId, String nouveauStatut) async {
    final doc = await _db.collection('commandes').doc(commandeId).get();
    final data = doc.data();
    if (data == null) return;

    final clientId = data['clientId'] as String? ?? '';
    final etablissementId = data['etablissementId'] as String? ?? '';
    final lignesData = (data['lignes'] as List?) ?? [];
    final description = lignesData
        .map((l) => '${l['nom']} x${l['quantite']}')
        .join(', ');
    final montant = ((data['montant'] ?? 0) as num).toDouble();

    // 1. Le client est prévenu à chaque changement de statut
    if (clientId.isNotEmpty) {
      await envoyer(
        destinataireId: clientId,
        titre: 'Votre commande a changé',
        message: 'Votre commande est maintenant : '
            '${StatutCommande.libelle(nouveauStatut)}. '
            'Consultez-la pour voir le suivi.',
        commandeId: commandeId,
      );
    }

    // 2. Le gérant est prévenu quand le client a reçu sa commande
    if (nouveauStatut == StatutCommande.livree) {
      final proprietaireId = await _proprietaireDe(etablissementId);
      if (proprietaireId != null) {
        await envoyer(
          destinataireId: proprietaireId,
          titre: 'Commande livrée',
          message: 'Le client a reçu sa commande : $description.',
          commandeId: commandeId,
        );
      }
    }

    // 3a. Tous les livreurs sont prévenus quand une mission devient disponible
    if (nouveauStatut == StatutCommande.enPreparation) {
      await envoyerAuxLivreurs(
        titre: 'Nouvelle mission disponible',
        message: '$description — ${montant.toStringAsFixed(0)} FCFA. '
            'Consultez les missions disponibles.',
        commandeId: commandeId,
      );
    }

    // 3b. Le livreur déjà assigné est prévenu que la commande est prête
    if (nouveauStatut == StatutCommande.prete) {
      final livreurId = data['livreurId'] as String?;
      if (livreurId != null && livreurId.isNotEmpty) {
        await envoyer(
          destinataireId: livreurId,
          titre: 'Commande prête',
          message: '$description est prête à être récupérée.',
          commandeId: commandeId,
        );
      }
    }
  }

  // Un livreur vient d'accepter la commande : prévient le client
  Future<void> notifierLivreurAssigne(String commandeId) async {
    final doc = await _db.collection('commandes').doc(commandeId).get();
    final clientId = doc.data()?['clientId'] as String? ?? '';
    if (clientId.isEmpty) return;
    await envoyer(
      destinataireId: clientId,
      titre: 'Livreur assigné',
      message: 'Un livreur a accepté votre commande.',
      commandeId: commandeId,
    );
  }
  
  // uid du gérant propriétaire d'un établissement
  Future<String?> _proprietaireDe(String etablissementId) async {
    if (etablissementId.isEmpty) return null;
    final doc =
        await _db.collection('etablissements').doc(etablissementId).get();
    final id = doc.data()?['proprietaireId'] as String?;
    return (id == null || id.isEmpty) ? null : id;
  }
}