import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/commande.dart';
import '../../models/etablissement.dart';
import '../../services/commande_service.dart';
import '../../services/etablissement_service.dart';
import '../../theme.dart';

/// Commandes en cours (non livrées) de l'établissement du gérant.
/// Permet de faire avancer une commande : confirmée -> en préparation ->
/// prête (en recherche de livreur). Le reste du parcours (récupération,
/// route, livraison) est piloté par le livreur, pas le gérant.
class CommandesRecuesPage extends StatelessWidget {
  const CommandesRecuesPage({super.key});

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
                      .commandesEnCoursDeLetablissement(etablissement.id),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Center(child: Text('Erreur : ${snap.error}'));
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final commandes = snap.data!;
                    if (commandes.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Aucune commande en cours pour le moment.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: commandes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) =>
                          _CarteCommande(commande: commandes[i]),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _CarteCommande extends StatelessWidget {
  final Commande commande;
  const _CarteCommande({required this.commande});

  String _heure(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  /// Action gérant possible pour ce statut, ou null si ça ne dépend plus
  /// du gérant (assignation/livraison gérées ailleurs).
  ({String label, String prochainStatut})? _actionGerant(String statut) {
    switch (statut) {
      case StatutCommande.confirmee:
        return (
          label: 'Commencer la préparation',
          prochainStatut: StatutCommande.enPreparation,
        );
      case StatutCommande.enPreparation:
        return (
          label: 'Marquer comme prête',
          prochainStatut: StatutCommande.livreurAssigne,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final couleur = couleurStatut(commande.statut);
    final action = _actionGerant(commande.statut);

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
                child: Text(
                  commande.description,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brunTexte),
                ),
              ),
              Text(
                _heure(commande.createdAt),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.brunClair),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  StatutCommande.libelle(commande.statut),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: couleur),
                ),
              ),
              const Spacer(),
              Text('${commande.montant.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brunTexte)),
            ],
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => CommandeService()
                    .mettreAJourStatut(commande.id, action.prochainStatut),
                child: Text(action.label),
              ),
            ),
          ],
        ],
      ),
    );
  }
}