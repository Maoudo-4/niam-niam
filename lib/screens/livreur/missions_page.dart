import 'package:flutter/material.dart';
import 'mes_missions.dart';
import 'missions_disponibles.dart';

/// Page de l'onglet Commandes pour le livreur :
/// deux sous-onglets, missions disponibles et missions en cours.
class MissionsPage extends StatelessWidget {
  const MissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Missions'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Disponibles'),
              Tab(text: 'En cours'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MissionsDisponibles(),
            MesMissions(),
          ],
        ),
      ),
    );
  }
}