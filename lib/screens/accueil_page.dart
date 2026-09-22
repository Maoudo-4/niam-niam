import 'package:flutter/material.dart';
import '../widgets/accueil_contenu.dart';

/// Page d'accueil commune aux trois rôles (onglet Accueil de la coque).
class AccueilPage extends StatelessWidget {
  // Reçoit le type choisi ('restaurant', 'fast-food' ou 'maïga'),
  // depuis un « Voir tout » ou depuis une pastille de catégorie
  final ValueChanged<String> onVoirTout;
  const AccueilPage({super.key, required this.onVoirTout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NIAM-NIAM'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AccueilContenu(onVoirTout: onVoirTout),
      ),
    );
  }
}