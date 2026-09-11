import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'passer_commande.dart';
import 'mes_commandes.dart';
import '../../widgets/confirmer_deconnexion.dart';

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
            onPressed: () => confirmerDeconnexion(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PasserCommande()),
                );
              },
              child: const Text('Passer une commande (test)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MesCommandes()),
                );
              },
              child: const Text('Mes commandes'),
            ),
          ],
        ),
      ),
    );
  }
}