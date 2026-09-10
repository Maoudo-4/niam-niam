import 'package:flutter/material.dart';
import '../../models/commande.dart';
import '../../services/commande_service.dart';

class SuiviCommande extends StatelessWidget {
  final String commandeId;
  const SuiviCommande({super.key, required this.commandeId});

  @override
  Widget build(BuildContext context) {
    final service = CommandeService();

    return Scaffold(
      appBar: AppBar(title: const Text('Suivi de la commande')),
      body: StreamBuilder<Commande?>(
        stream: service.suivreCommande(commandeId),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final commande = snapshot.data!;
          final etapeActuelle = StatutCommande.ordre.indexOf(commande.statut);

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(commande.description, style: const TextStyle(fontSize: 18)),
                Text('${commande.montant.toStringAsFixed(0)} FCFA'),
                const SizedBox(height: 24),
                ...List.generate(StatutCommande.ordre.length, (i) {
                  final statut = StatutCommande.ordre[i];
                  final atteinte = i <= etapeActuelle;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Icon(
                          atteinte ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: atteinte ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          StatutCommande.libelle(statut),
                          style: TextStyle(
                            fontWeight: atteinte ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}