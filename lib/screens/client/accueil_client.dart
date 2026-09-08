import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AccueilClient extends StatelessWidget {
  const AccueilClient({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Client'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().deconnecter(),
          ),
        ],
      ),
      body: const Center(child: Text('Bienvenue, client 👋')),
    );
  }
}