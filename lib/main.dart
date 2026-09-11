import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/auth_screen.dart';
import 'screens/role_screen.dart';
import 'screens/client/accueil_client.dart';
import 'screens/gerant/accueil_gerant.dart';
import 'screens/livreur/accueil_livreur.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NIAM-NIAM',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RedirectionPrincipale(),
    );
  }
}

// Ce widget décide quel écran afficher selon l'état de connexion et le rôle
class RedirectionPrincipale extends StatelessWidget {
  const RedirectionPrincipale({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().utilisateurConnecte,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Pas connecté → écran de connexion
        if (!snapshot.hasData) {
          return const AuthScreen();
        }

        final uid = snapshot.data!.uid;

        // Connecté → on regarde son rôle dans Firestore en temps réel
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>?;
            final role = data?['role'] ?? '';

            if (role == '') {
              return RoleScreen(uid: uid); // pas encore de rôle choisi
            } else if (role == 'client') {
              return const AccueilClient();
            } else if (role == 'gerant') {
              return const AccueilGerant();
            } else if (role == 'livreur') {
              return const AccueilLivreur();
            } else {
              return RoleScreen(uid: uid);
            }
          },
        );
      },
    );
  }
}