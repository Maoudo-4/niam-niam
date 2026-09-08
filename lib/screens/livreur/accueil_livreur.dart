import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AccueilLivreur extends StatelessWidget {
  const AccueilLivreur({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Livreur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().deconnecter(),
          ),
        ],
      ),
      body: const Center(child: Text('Bienvenue, livreur 👋')),
    );
  }
}