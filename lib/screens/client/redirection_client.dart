import 'package:flutter/material.dart';
import '../../services/client_service.dart';
import 'accueil_client.dart';
import 'inscription_client_screen.dart';

class RedirectionClient extends StatefulWidget {
  final String uid;
  const RedirectionClient({super.key, required this.uid});

  @override
  State<RedirectionClient> createState() => _RedirectionClientState();
}

class _RedirectionClientState extends State<RedirectionClient> {
  final ClientService _service = ClientService();
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
          return const AccueilClient();
        }

        return InscriptionClientScreen(onProfilCree: _rafraichir);
      },
    );
  }
}