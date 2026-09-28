import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commande.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

class CommandeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Créer une nouvelle commande
  Future<String> creerCommande({
    required String clientId,
    required String etablissementId,
    required String description,
    required double montant,
  }) async {
    final doc = await _db.collection('commandes').add({
      'clientId': clientId,
      'etablissementId': etablissementId,
      'description': description,
      'montant': montant,
      'statut': StatutCommande.confirmee,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Prévient le gérant, sans bloquer la commande si l'envoi échoue
    try {
      await NotificationService().notifierNouvelleCommande(
        commandeId: doc.id,
        etablissementId: etablissementId,
        description: description,
        montant: montant,
      );
    } catch (e) {
      debugPrint('Notification non envoyée : $e');
    }

    return doc.id; // utile pour rediriger vers l'écran de suivi
  }

  // Écouter une commande en temps réel (pour le suivi)
  Stream<Commande?> suivreCommande(String commandeId) {
    return _db.collection('commandes').doc(commandeId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Commande.fromMap(doc.id, doc.data()!);
    });
  }

  // Lister les commandes d'un client (historique)
  Stream<List<Commande>> commandesDuClient(String clientId) {
    return _db
        .collection('commandes')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Commande.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Commandes livrées d'un établissement (historique côté gérant)
  Stream<List<Commande>> commandesLivreesDeLetablissement(
      String etablissementId) {
    return _db
        .collection('commandes')
        .where('etablissementId', isEqualTo: etablissementId)
        .where('statut', isEqualTo: StatutCommande.livree)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Commande.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Commandes en cours (non livrées) d'un établissement, pour l'onglet
  // "Commandes reçues" du gérant. Triées des plus anciennes aux plus
  // récentes (les plus anciennes sont traitées en premier).
  Stream<List<Commande>> commandesEnCoursDeLetablissement(
      String etablissementId) {
    return _db
        .collection('commandes')
        .where('etablissementId', isEqualTo: etablissementId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Commande.fromMap(doc.id, doc.data()))
            .where((c) => c.statut != StatutCommande.livree)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
  }
  // Faire avancer le statut (utilisé plus tard côté gérant/livreur)
  Future<void> mettreAJourStatut(String commandeId, String nouveauStatut) async {
    await _db.collection('commandes').doc(commandeId).update({
      'statut': nouveauStatut,
    });
    try {
      await NotificationService()
          .notifierChangementStatut(commandeId, nouveauStatut);
    } catch (e) {
      debugPrint('Notification non envoyée : $e');
    }
  }
  Future<void> supprimerCommande(String commandeId) async {
    await _db.collection('commandes').doc(commandeId).delete();
  }
}