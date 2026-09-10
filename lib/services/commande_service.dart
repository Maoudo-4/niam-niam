import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commande.dart';

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

  // Faire avancer le statut (utilisé plus tard côté gérant/livreur)
  Future<void> mettreAJourStatut(String commandeId, String nouveauStatut) async {
    await _db.collection('commandes').doc(commandeId).update({
      'statut': nouveauStatut,
    });
  }
}