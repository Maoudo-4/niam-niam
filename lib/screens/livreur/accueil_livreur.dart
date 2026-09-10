import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'missions_disponibles.dart';
import 'mes_missions.dart';

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MissionsDisponibles())),
              child: const Text('Voir les missions disponibles'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MesMissions())),
              child: const Text('Mes missions en cours'),
            ),
          ],
        ),
      ),
    );
  }
}