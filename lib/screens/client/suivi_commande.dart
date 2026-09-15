import 'package:flutter/material.dart';
import '../../theme.dart';
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
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.carte,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.bordure),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(commande.description,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brunTexte)),
                            const SizedBox(height: 4),
                            Text('${commande.montant.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(color: AppColors.brunClair)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: couleurStatut(commande.statut).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            StatutCommande.libelle(commande.statut),
                            style: TextStyle(
                                color: couleurStatut(commande.statut),
                                fontWeight: FontWeight.w600,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
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