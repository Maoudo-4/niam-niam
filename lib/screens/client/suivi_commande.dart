import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../models/commande.dart';
import '../../services/commande_service.dart';
import '../../services/livreur_service.dart';
import '../../services/appel_service.dart';

class SuiviCommande extends StatelessWidget {
  final String commandeId;
  const SuiviCommande({super.key, required this.commandeId});

  
  IconData _icone(String statut) {
    switch (statut) {
      case StatutCommande.confirmee: return Icons.receipt_long;
      case StatutCommande.enPreparation: return Icons.soup_kitchen;
      case StatutCommande.prete: return Icons.check_circle_outline;
      case StatutCommande.livreurAssigne: return Icons.person_pin_circle;
      case StatutCommande.recuperee: return Icons.shopping_bag;
      case StatutCommande.enRoute: return Icons.delivery_dining;
      case StatutCommande.livree: return Icons.home;
      default: return Icons.circle;
    }
  }
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

          return SingleChildScrollView(
            child: Padding(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Ta commande',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.brunTexte)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: couleurStatut(commande.statut)
                                    .withValues(alpha: 0.15),
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
                        const SizedBox(height: 12),
                        if (commande.lignes.isNotEmpty)
                          ...commande.lignes.map((l) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('${l.nom} x${l.quantite}',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.brunTexte)),
                                    ),
                                    Text(
                                        '${l.sousTotal.toStringAsFixed(0)} FCFA',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.brunClair)),
                                  ],
                                ),
                              ))
                        else
                          Text(commande.description,
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.brunTexte)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.brunTexte)),
                            Text('${commande.montant.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brunTexte)),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                const Text('Suivi',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brunTexte)),
                const SizedBox(height: 12),
                ...List.generate(StatutCommande.ordre.length, (i) {
                    final statut = StatutCommande.ordre[i];
                    final atteinte = i <= etapeActuelle;
                    final estDernier = i == StatutCommande.ordre.length - 1;

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: atteinte ? AppColors.vert : AppColors.creme,
                                  border: Border.all(
                                    color: atteinte ? AppColors.vert : AppColors.bordure,
                                    width: 2,
                                  ),
                                ),
                                 child: Icon(
                                  _icone(statut),
                                  size: 18,
                                  color: atteinte ? Colors.white : AppColors.brunClair,
                                ),
                              ),
                              if (!estDernier)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    color: atteinte ? AppColors.vert : AppColors.bordure,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            child: Text(
                              StatutCommande.libelle(statut),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: atteinte ? FontWeight.w600 : FontWeight.normal,
                                color: atteinte ? AppColors.brunTexte : AppColors.brunClair,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                if (commande.livreurId != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.carte,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.bordure),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.creme,
                          child: Icon(Icons.person, color: AppColors.terracotta),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Ton livreur',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brunTexte)),
                        ),
                        IconButton(
                          tooltip: 'Appeler le livreur',
                          icon: const Icon(Icons.call, color: AppColors.vert),
                          onPressed: () async {
                            // Le numéro est dans le profil du livreur
                            String numero = '';
                            try {
                              final livreur = await LivreurService()
                                  .getProfil(commande.livreurId!);
                              numero = livreur?.telephone ?? '';
                            } catch (_) {}
                            if (!context.mounted) return;
                            await appeler(context, numero);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                if (commande.statut == StatutCommande.enRoute) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirmer = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer la réception'),
                            content: const Text(
                                'Confirmez-vous avoir reçu et payé votre commande auprès du livreur ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Confirmer'),
                              ),
                            ],
                          ),
                        );
                        if (confirmer == true) {
                          await CommandeService().mettreAJourStatut(
                              commande.id, StatutCommande.livree);
                        }
                      },
                      child: const Text('Commande reçue'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          );
        },
      ),
    );
  }
}
