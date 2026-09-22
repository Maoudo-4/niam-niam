import 'package:cloud_firestore/cloud_firestore.dart';

class FavorisService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // clients/{clientId}/favoris/{etablissementId}
  CollectionReference<Map<String, dynamic>> _col(String clientId) =>
      _db.collection('clients').doc(clientId).collection('favoris');

  // IDs des établissements favoris du client, en temps réel
  Stream<Set<String>> favorisDuClient(String clientId) {
    return _col(clientId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  // Ajoute l'établissement aux favoris, ou le retire s'il y est déjà
  Future<void> basculer(
    String clientId,
    String etablissementId, {
    required bool dejaFavori,
  }) async {
    final ref = _col(clientId).doc(etablissementId);
    if (dejaFavori) {
      await ref.delete();
    } else {
      await ref.set({'createdAt': FieldValue.serverTimestamp()});
    }
  }
}