import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/commande.dart';
import '../../models/etablissement.dart';
import '../../services/commande_service.dart';
import '../../services/etablissement_service.dart';
import '../../theme.dart';

/// Statistiques simples du gérant : commandes livrées, revenu, note.
class StatistiquesGerantPage extends StatelessWidget {
  const StatistiquesGerantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: uid == null
          ? const Center(child: Text('Vous devez être connecté'))
          : FutureBuilder<Etablissement?>(
              future:
                  EtablissementService().getEtablissementParProprietaire(uid),
              builder: (context, etabSnap) {
                if (etabSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final etablissement = etabSnap.data;
                if (etablissement == null) {
                  return const Center(
                      child: Text('Aucun établissement trouvé'));
                }

                return StreamBuilder<List<Commande>>(
                  stream: CommandeService()
                      .commandesLivreesDeLetablissement(etablissement.id),
                  builder: (context, cmdSnap) {
                    if (cmdSnap.hasError) {
                      return Center(child: Text('Erreur : ${cmdSnap.error}'));
                    }
                    if (!cmdSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final livrees = cmdSnap.data!;
                    final nombreCommandes = livrees.length;
                    final revenuTotal =
                        livrees.fold<double>(0, (s, c) => s + c.montant);

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        _CarteStat(
                          icone: Icons.receipt_long,
                          titre: 'Commandes livrées',
                          valeur: '$nombreCommandes',
                        ),
                        const SizedBox(height: 12),
                        _CarteStat(
                          icone: Icons.payments,
                          titre: 'Revenu total',
                          valeur:
                              '${revenuTotal.toStringAsFixed(0)} FCFA',
                        ),
                        const SizedBox(height: 12),
                        _CarteStat(
                          icone: Icons.star,
                          titre: 'Note moyenne',
                          valeur: etablissement.nombreAvis == 0
                              ? 'Aucun avis'
                              : '${etablissement.noteMoyenne.toStringAsFixed(1)} / 5 '
                                  '(${etablissement.nombreAvis} avis)',
                        ),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }
}

/// Une carte : icône, titre, grande valeur.
class _CarteStat extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String valeur;
  const _CarteStat({
    required this.icone,
    required this.titre,
    required this.valeur,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.carte,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bordure),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icone, color: AppColors.terracotta, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.brunClair)),
                const SizedBox(height: 4),
                Text(valeur,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brunTexte)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}