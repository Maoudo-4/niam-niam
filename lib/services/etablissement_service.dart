import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/etablissement.dart';

class EtablissementService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('etablissements');

  // Récupérer tous les établissements
  Stream<List<Etablissement>> getEtablissements() {
    return _collection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Etablissement.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // Ajouter un établissement
  Future<void> ajouterEtablissement(Etablissement etablissement) async {
    await _collection.add(etablissement.toMap());
  }

  // Récupérer un établissement par son id
  Future<Etablissement?> getEtablissementParId(String id) async {
    final doc = await _collection.doc(id).get();
    if (doc.exists) {
      return Etablissement.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // vérifier si un gérant a déjà un établissement
  Future<Etablissement?> getEtablissementParProprietaire(String uid) async {
    final query = await _collection
        .where('proprietaireId', isEqualTo: uid)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return Etablissement.fromMap(
          query.docs.first.data() as Map<String, dynamic>, query.docs.first.id);
    }
    return null;
  }
}