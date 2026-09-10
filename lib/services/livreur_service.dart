import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commande.dart';

class LivreurService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
  }

  // Faire avancer le statut d'une livraison
  Future<void> avancerStatut(String commandeId, String nouveauStatut) async {
    await _db.collection('commandes').doc(commandeId).update({
      'statut': nouveauStatut,
    });
  }
}