import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/utilisateur.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get utilisateurConnecte => _auth.authStateChanges();

  // Inscription
  Future<String?> inscrire(String email, String motDePasse, String nom) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: motDePasse,
      );
      // On crée le document utilisateur dans Firestore, sans rôle pour l'instant
      await _db.collection('users').doc(result.user!.uid).set({
        'nom': nom,
        'email': email,
        'role': '', // sera rempli à l'écran de choix du rôle
      });
      return null; // pas d'erreur
    } on FirebaseAuthException catch (e) {
      return e.message; // on renvoie le message d'erreur
    }
  }

  // Connexion
  Future<String?> connecter(String email, String motDePasse) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: motDePasse);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Déconnexion
  Future<void> deconnecter() async {
    await _auth.signOut();
  }

  // Récupérer le rôle de l'utilisateur connecté
  Future<String?> getRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'];
  }

// Enregistrer le rôle choisi
Future<void> setRole(String uid, String role) async {
  await _db.collection('users').doc(uid).set(
    {'role': role},
    SetOptions(merge: true), // crée le document s'il n'existe pas, sinon met juste à jour le champ
  );
}
}