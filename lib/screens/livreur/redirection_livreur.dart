import 'package:flutter/material.dart';
import '../../services/livreur_service.dart';
import 'accueil_livreur.dart';
import 'inscription_livreur_screen.dart';

class RedirectionLivreur extends StatefulWidget {
  final String uid;
  const RedirectionLivreur({super.key, required this.uid});

  @override
  State<RedirectionLivreur> createState() => _RedirectionLivreurState();
}

class _RedirectionLivreurState extends State<RedirectionLivreur> {
  final LivreurService _service = LivreurService();
  late Future<bool> _profilFuture;

  @override
  void initState() {
    super.initState();
    _profilFuture = _service.profilExiste(widget.uid);
  }

  // Appelé quand le formulaire est enregistré : on revérifie le profil
  void _rafraichir() {
    setState(() {
      _profilFuture = _service.profilExiste(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _profilFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('❌ Impossible de charger votre profil'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _rafraichir,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.data == true) {
          return const AccueilLivreur();
        }

        return InscriptionLivreurScreen(onProfilCree: _rafraichir);
      },
    );
  }
}