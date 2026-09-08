import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AccueilGerant extends StatelessWidget {
  const AccueilGerant({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Gérant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().deconnecter(),
          ),
        ],
      ),
      body: const Center(child: Text('Bienvenue, gérant 👋')),
    );
  }
}