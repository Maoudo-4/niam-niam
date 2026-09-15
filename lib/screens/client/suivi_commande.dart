import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/commande.dart';
import '../../services/commande_service.dart';
import '../../theme.dart';

class SuiviCommande extends StatelessWidget {
  final String commandeId;
  const SuiviCommande({super.key, required this.commandeId});

  IconData _icone(String statut) {
    switch (statut) {
      case StatutCommande.confirmee: return Icons.receipt_long;
      case StatutCommande.enPreparation: return Icons.soup_kitchen;
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
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final commande = snapshot.data!;
          final etapeActuelle = StatutCommande.ordre.indexOf(commande.statut);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte résumé commande
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
                const Text('Suivi',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brunTexte)),
                const SizedBox(height: 12),

                // Timeline verticale
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
                                size: 20,
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

                // Carte livreur (affichée seulement une fois assigné)
                if (commande.livreurId != null) ...[
                  const SizedBox(height: 8),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(commande.livreurId)
                        .get(),
                    builder: (context, livreurSnap) {
                      final nom = (livreurSnap.data?.data()
                              as Map<String, dynamic>?)?['nom'] ??
                          'Livreur';
                      return Container(
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nom,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.brunTexte)),
                                  const Text('Ton livreur',
                                      style: TextStyle(
                                          fontSize: 12, color: AppColors.brunClair)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.vert,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.call, color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}