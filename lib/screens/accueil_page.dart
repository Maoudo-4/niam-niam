import 'package:flutter/material.dart';
import '../widgets/accueil_contenu.dart';
import '../widgets/confirmer_deconnexion.dart';

/// Page d'accueil commune aux trois rôles (onglet Accueil de la coque).
class AccueilPage extends StatelessWidget {
  // Reçoit le type de la section dont on a cliqué « Voir tout »
  final ValueChanged<String> onVoirTout;

  const AccueilPage({super.key, required this.onVoirTout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NIAM-NIAM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => confirmerDeconnexion(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AccueilContenu(onVoirTout: onVoirTout),
      ),
    );
  }
}