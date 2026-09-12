import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/commande.dart';
import '../../services/commande_service.dart';
import 'suivi_commande.dart';

class MesCommandes extends StatelessWidget {
  const MesCommandes({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CommandeService();
    final clientId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: StreamBuilder<List<Commande>>(
        stream: service.commandesDuClient(clientId),
        builder: (context, snapshot) {
            if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
              child: Text('Erreur : ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final commandes = snapshot.data!;
          if (commandes.isEmpty) {
            return const Center(child: Text('Aucune commande pour le moment.'));
          }
          return ListView.builder(
            itemCount: commandes.length,
            itemBuilder: (context, i) {
              final commande = commandes[i];
              return Dismissible(
                key: Key(commande.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Supprimer la commande ?'),
                      content: const Text('Cette action est irréversible.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) => service.supprimerCommande(commande.id),
                child: Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(commande.description),
                    subtitle: Text(
                      '${commande.montant.toStringAsFixed(0)} FCFA — ${StatutCommande.libelle(commande.statut)}',
                    ),
                    trailing: commande.statut == StatutCommande.livree
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SuiviCommande(commandeId: commande.id),
                        ),
                      );
                    },
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