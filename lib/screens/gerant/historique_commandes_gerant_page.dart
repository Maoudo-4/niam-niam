import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/avis.dart';
import '../../models/commande.dart';
import '../../models/etablissement.dart';
import '../../services/avis_service.dart';
import '../../services/commande_service.dart';
import '../../services/etablissement_service.dart';
import '../../theme.dart';

/// Commandes livrées de l'établissement du gérant, avec l'avis du client s'il existe.
class HistoriqueCommandesGerantPage extends StatelessWidget {
  const HistoriqueCommandesGerantPage({super.key});

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Commandes reçues')),
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

                    final livrees = cmdSnap.data!.toList()
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    if (livrees.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Aucune commande livrée pour le moment.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return _ListeAvecAvis(
                      etablissementId: etablissement.id,
                      livrees: livrees,
                      date: _date,
                    );
                  },
                );
              },
            ),
    );
  }
}

/// Charge les avis de l'établissement (pas seulement d'un client) et affiche la liste.
class _ListeAvecAvis extends StatelessWidget {
  final String etablissementId;
  final List<Commande> livrees;
  final String Function(DateTime) date;
  const _ListeAvecAvis({
    required this.etablissementId,
    required this.livrees,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, Avis>>(
      stream: AvisService().avisDeLetablissement(etablissementId),
      builder: (context, avisSnap) {
        if (avisSnap.hasError) {
          return Center(child: Text('Erreur : ${avisSnap.error}'));
        }
        if (!avisSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final avis = avisSnap.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: livrees.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final c = livrees[i];
            final a = avis[c.id];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.carte,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.bordure),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(c.description,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brunTexte)),
                      ),
                      Text(date(c.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.brunClair)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${c.montant.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.brunClair)),
                  if (a != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < a.note ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    if (a.commentaire.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(a.commentaire,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.brunTexte)),
                    ],
                  ] else ...[
                    const SizedBox(height: 8),
                    const Text('Pas encore d\'avis',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.brunClair,
                            fontStyle: FontStyle.italic)),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}