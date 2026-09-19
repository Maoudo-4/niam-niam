import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';

class ClientService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('clients');

  // Enregistre (ou met à jour) le profil client.
  // L'ID du document = l'uid de l'utilisateur Firebase Auth.
  Future<void> creerProfil(Client client) async {
    await _col.doc(client.uid).set(client.toMap());
  }

  // Récupère le profil d'un client, ou null s'il n'existe pas encore.
  Future<Client?> getProfil(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return Client.fromMap(doc.data()!, uid);
  }

  // Sert à savoir si le client a déjà rempli son formulaire.
  Future<bool> profilExiste(String uid) async {
    final doc = await _col.doc(uid).get();
    return doc.exists;
  }
}
