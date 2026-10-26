import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/commande.dart';
import '../../services/livreur_service.dart';
import 'carte_livreur_page.dart';

/// Liste des missions en cours du livreur.
/// Affichée dans l'onglet Commandes du livreur (voir MissionsPage) :
/// pas de Scaffold ni d'AppBar ici, c'est MissionsPage qui les fournit.
class MesMissions extends StatelessWidget {
  const MesMissions({super.key});

  // Détermine le prochain statut à proposer.
  // "Récupérée" est désormais confirmée par le gérant, et "Livrée" par le
  // client — le livreur ne gère que le passage "en route".
  String? _prochainStatut(String statutActuel) {
    switch (statutActuel) {
      case StatutCommande.recuperee:
        return StatutCommande.enRoute;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = LivreurService();
    final livreurId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<List<Commande>>(
      stream: service.mesMissions(livreurId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final missions = snapshot.data!;
        if (missions.isEmpty) {
          return const Center(child: Text('Aucune mission en cours.'));
        }
        return ListView.builder(
          itemCount: missions.length,
          itemBuilder: (context, i) {
            final commande = missions[i];
            final prochain = _prochainStatut(commande.statut);
            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(commande.description),
                subtitle: Text(StatutCommande.libelle(commande.statut)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Voir sur la carte',
                      icon: const Icon(Icons.map_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CarteLivreurPage(commandeId: commande.id),
                        ),
                      ),
                    ),
                    if (prochain != null)
                      ElevatedButton(
                        onPressed: () =>
                            service.avancerStatut(commande.id, prochain),
                        child: Text(StatutCommande.libelle(prochain)),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}