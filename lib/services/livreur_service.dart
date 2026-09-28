import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/commande.dart';
import '../models/livreur.dart';
import 'notification_service.dart'; 

class LivreurService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // profil livreur (collection 'livreurs', ID = uid)
  CollectionReference<Map<String, dynamic>> get _livreurs =>
      _db.collection('livreurs');

  Future<void> creerProfil(Livreur livreur) async {
    await _livreurs.doc(livreur.uid).set(livreur.toMap());
  }

  Future<Livreur?> getProfil(String uid) async {
    final doc = await _livreurs.doc(uid).get();
    if (!doc.exists) return null;
    return Livreur.fromMap(doc.data()!, uid);
  }

  Future<bool> profilExiste(String uid) async {
    final doc = await _livreurs.doc(uid).get();
    return doc.exists;
  }

  // Modifie prénom, nom, téléphone, adresse et moyen de déplacement
  Future<void> mettreAJourProfil(Livreur livreur) async {
    await _livreurs.doc(livreur.uid).update(livreur.toMap());
  }

  // Livraisons terminées par CE livreur (pour son historique)
  Stream<List<Commande>> missionsLivrees(String livreurId) {
    return _db
        .collection('commandes')
        .where('livreurId', isEqualTo: livreurId)
        .where('statut', isEqualTo: StatutCommande.livree)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Commande.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Missions disponibles : en préparation, sans livreur assigné
  Stream<List<Commande>> missionsDisponibles() {
    return _db
        .collection('commandes')
        .where('statut', isEqualTo: StatutCommande.enPreparation)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Commande.fromMap(doc.id, doc.data()))
            .where((c) => c.livreurId == null)
            .toList());
  }

  // Missions en cours pour CE livreur
  Stream<List<Commande>> mesMissions(String livreurId) {
    return _db
        .collection('commandes')
        .where('livreurId', isEqualTo: livreurId)
        .where('statut', whereIn: [
          StatutCommande.livreurAssigne,
          StatutCommande.recuperee,
          StatutCommande.enRoute,
        ])
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Commande.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Accepter une mission
  Future<void> accepterMission(String commandeId, String livreurId) async {
    await _db.collection('commandes').doc(commandeId).update({
      'livreurId': livreurId,
      'statut': StatutCommande.livreurAssigne,
    });
    // prévient le client, sans bloquer la mission si l'envoi échoue
    try {
      await NotificationService()
          .notifierChangementStatut(commandeId, StatutCommande.livreurAssigne);
    } catch (e) {
      debugPrint('Notification non envoyée : $e');
    }
  }

  // Faire avancer le statut d'une livraison
  Future<void> avancerStatut(String commandeId, String nouveauStatut) async {
    await _db.collection('commandes').doc(commandeId).update({
      'statut': nouveauStatut,
    });
    // prévient le client (et le gérant à la livraison)
    try {
      await NotificationService()
          .notifierChangementStatut(commandeId, nouveauStatut);
    } catch (e) {
      debugPrint('Notification non envoyée : $e');
    }
  }
}