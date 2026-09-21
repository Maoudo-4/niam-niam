import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/avis.dart';

class AvisService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Avis donnés par ce client, en temps réel.
  // Clé = id de la commande notée (c'est aussi l'id du document d'avis).
  Stream<Map<String, Avis>> avisDuClient(String clientId) {
    return _db
        .collection('avis')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snap) => {
              for (final doc in snap.docs)
                doc.id: Avis.fromMap(doc.id, doc.data()),
            });
  }

  // Enregistre l'avis ET met à jour la note de l'établissement,
  // en une seule transaction (tout réussit ou rien n'est modifié).
  Future<void> ajouterAvis({
    required String commandeId,
    required String clientId,
    required String etablissementId,
    required int note,
    String commentaire = '',
  }) async {
    final avisRef = _db.collection('avis').doc(commandeId);
    final etabRef = _db.collection('etablissements').doc(etablissementId);

    await _db.runTransaction((tx) async {
      // Toutes les lectures d'abord, les écritures ensuite
      final avisSnap = await tx.get(avisRef);
      if (avisSnap.exists) {
        throw Exception('Cette commande a déjà reçu un avis');
      }
      final etabSnap = await tx.get(etabRef);
      if (!etabSnap.exists) {
        throw Exception('Établissement introuvable');
      }

      final data = etabSnap.data()!;
      final ancienneMoyenne = ((data['noteMoyenne'] ?? 0.0) as num).toDouble();
      final ancienNombre = ((data['nombreAvis'] ?? 0) as num).toInt();
      final nouveauNombre = ancienNombre + 1;
      final nouvelleMoyenne =
          (ancienneMoyenne * ancienNombre + note) / nouveauNombre;

      tx.set(avisRef, {
        'clientId': clientId,
        'etablissementId': etablissementId,
        'note': note,
        'commentaire': commentaire,
        'createdAt': FieldValue.serverTimestamp(),
      });
      tx.update(etabRef, {
        'noteMoyenne': nouvelleMoyenne,
        'nombreAvis': nouveauNombre,
      });
    });
  }
}