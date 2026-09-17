import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/produit.dart';

class ProduitService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Liste des produits d'un établissement (ou tous, pour l'instant en test)
  Stream<List<Produit>> produitsDisponibles({String? etablissementId}) {
    Query query = _db.collection('produits');
    if (etablissementId != null) {
      query = query.where('etablissementId', isEqualTo: etablissementId);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((doc) => Produit.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList());
  }
}