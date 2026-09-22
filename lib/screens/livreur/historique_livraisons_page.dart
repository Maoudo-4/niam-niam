import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/commande.dart';
import '../../services/livreur_service.dart';
import '../../theme.dart';

/// Missions terminées par le livreur (statut « livrée »).
class HistoriqueLivraisonsPage extends StatelessWidget {
  const HistoriqueLivraisonsPage({super.key});

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des livraisons')),
      body: uid == null
          ? const Center(child: Text('Vous devez être connecté'))
          : StreamBuilder<List<Commande>>(
              stream: LivreurService().missionsLivrees(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final livraisons = snapshot.data!.toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (livraisons.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aucune livraison terminée pour le moment.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: livraisons.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final c = livraisons[i];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.carte,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.bordure),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.terracotta.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle,
                                color: AppColors.terracotta, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.description,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brunTexte)),
                                const SizedBox(height: 2),
                                Text(_date(c.createdAt),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.brunClair)),
                              ],
                            ),
                          ),
                          Text(
                            '${c.montant.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brunTexte),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}