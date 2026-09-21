import 'package:flutter/material.dart';
import '../../models/etablissement.dart';
import '../../services/etablissement_service.dart';
import 'fiche_etablissement_screen.dart';

class ListeEtablissementsScreen extends StatelessWidget {
  final String? type; // null = tous les établissements
  const ListeEtablissementsScreen({super.key, this.type});

  String get _titre => switch (type) {
        'restaurant' => 'Restaurants',
        'fast-food' => 'Fast-foods',
        'maïga' => 'Maïgas',
        _ => 'Établissements',
      };

  @override
  Widget build(BuildContext context) {
    final EtablissementService service = EtablissementService();

    return Scaffold(
      appBar: AppBar(title: Text(_titre)),
      body: StreamBuilder<List<Etablissement>>(
        stream: service.getEtablissements(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final etablissements = (snapshot.data ?? [])
              .where((e) => type == null || e.type == type)
              .toList();

          if (etablissements.isEmpty) {
            return const Center(child: Text('Aucun établissement pour le moment'));
          }

          return ListView.builder(
            itemCount: etablissements.length,
            itemBuilder: (context, index) {
              final e = etablissements[index];
              return ListTile(
                leading: const Icon(Icons.restaurant),
                title: Text(e.nom),
                subtitle: Text('${e.type} • ${e.categoriePrix} • ${e.adresse}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(e.noteMoyenne.toStringAsFixed(1)),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FicheEtablissementScreen(etablissement: e),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}