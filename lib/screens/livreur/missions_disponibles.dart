import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/commande.dart';
import '../../services/livreur_service.dart';

class MissionsDisponibles extends StatelessWidget {
  const MissionsDisponibles({super.key});

  @override
  Widget build(BuildContext context) {
    final service = LivreurService();
    final livreurId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Missions disponibles')),
      body: StreamBuilder<List<Commande>>(
        stream: service.missionsDisponibles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final missions = snapshot.data!;
          if (missions.isEmpty) {
            return const Center(child: Text('Aucune mission disponible pour le moment.'));
          }
          return ListView.builder(
            itemCount: missions.length,
            itemBuilder: (context, i) {
              final commande = missions[i];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(commande.description),
                  subtitle: Text('${commande.montant.toStringAsFixed(0)} FCFA'),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await service.accepterMission(commande.id, livreurId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mission acceptée !')),
                        );
                      }
                    },
                    child: const Text('Accepter'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}