import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/avis.dart';
import '../../models/commande.dart';
import '../../models/etablissement.dart';
import '../../services/avis_service.dart';
import '../../services/commande_service.dart';
import '../../services/etablissement_service.dart';
import '../../theme.dart';
import '../../widgets/dialog_notation.dart';

/// Commandes livrées du client, avec l'avis donné ou un bouton pour noter.
class HistoriqueCommandesPage extends StatefulWidget {
  const HistoriqueCommandesPage({super.key});

  @override
  State<HistoriqueCommandesPage> createState() =>
      _HistoriqueCommandesPageState();
}

class _HistoriqueCommandesPageState extends State<HistoriqueCommandesPage> {
  final _avisService = AvisService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  // Les flux sont créés une seule fois pour ne pas clignoter à chaque mise à jour
  late final Stream<List<Commande>>? _commandes =
      _uid == null ? null : CommandeService().commandesDuClient(_uid);
  late final Stream<List<Etablissement>> _etablissements =
      EtablissementService().getEtablissements();
  late final Stream<Map<String, Avis>>? _avis =
      _uid == null ? null : _avisService.avisDuClient(_uid);

  String _date(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _noter(Commande commande, String nomEtablissement) async {
    final resultat = await afficherDialogNotation(
      context,
      nomEtablissement: nomEtablissement,
    );
    if (resultat == null || !mounted) return;

    try {
      await _avisService.ajouterAvis(
        commandeId: commande.id,
        clientId: _uid!,
        etablissementId: commande.etablissementId,
        note: resultat.note,
        commentaire: resultat.commentaire,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Merci pour votre avis !')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des commandes')),
      body: _commandes == null
          ? const Center(child: Text('Vous devez être connecté'))
          : StreamBuilder<List<Commande>>(
              stream: _commandes,
              builder: (context, cmdSnap) {
                if (cmdSnap.hasError) {
                  return Center(child: Text('Erreur : ${cmdSnap.error}'));
                }
                if (!cmdSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Seulement les commandes livrées, la plus récente d'abord
                final livrees = cmdSnap.data!
                    .where((c) => c.statut == StatutCommande.livree)
                    .toList()
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

                return StreamBuilder<List<Etablissement>>(
                  stream: _etablissements,
                  builder: (context, etabSnap) {
                    return StreamBuilder<Map<String, Avis>>(
                      stream: _avis,
                      builder: (context, avisSnap) {
                        if (etabSnap.hasError || avisSnap.hasError) {
                          return Center(
                            child: Text(
                                'Erreur : ${etabSnap.error ?? avisSnap.error}'),
                          );
                        }
                        if (!etabSnap.hasData || !avisSnap.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final noms = {
                          for (final e in etabSnap.data!) e.id: e.nom,
                        };
                        final avis = avisSnap.data!;

                        return ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: livrees.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final c = livrees[i];
                            final nom =
                                noms[c.etablissementId] ?? 'Établissement';
                            return _CarteCommande(
                              nomEtablissement: nom,
                              date: _date(c.createdAt),
                              commande: c,
                              avis: avis[c.id],
                              onNoter: () => _noter(c, nom),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

/// Une commande livrée : infos + avis donné ou bouton « Noter ».
class _CarteCommande extends StatelessWidget {
  final String nomEtablissement;
  final String date;
  final Commande commande;
  final Avis? avis;
  final VoidCallback onNoter;
  const _CarteCommande({
    required this.nomEtablissement,
    required this.date,
    required this.commande,
    required this.avis,
    required this.onNoter,
  });

  @override
  Widget build(BuildContext context) {
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
                child: Text(nomEtablissement,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brunTexte)),
              ),
              Text(date,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.brunClair)),
            ],
          ),
          const SizedBox(height: 6),
          Text(commande.description,
              style:
                  const TextStyle(fontSize: 14, color: AppColors.brunTexte)),
          const SizedBox(height: 2),
          Text('${commande.montant.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.brunClair)),
          const Divider(height: 24),
          if (avis == null)
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onNoter,
                icon: const Icon(Icons.star_border),
                label: const Text('Noter cet établissement'),
              ),
            )
          else ...[
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < avis!.note ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Votre avis',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.brunClair)),
              ],
            ),
            if (avis!.commentaire.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(avis!.commentaire,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.brunTexte)),
            ],
          ],
        ],
      ),
    );
  }
}