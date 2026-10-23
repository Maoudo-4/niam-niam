import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/etablissement.dart';
import '../../services/etablissement_service.dart';
import '../../services/favoris_service.dart';
import '../../services/role_actuel.dart';
import '../../theme.dart';
import '../../widgets/carte_etablissement.dart' show couleurPourType;
import '../../widgets/cloche_notifications.dart';
import 'fiche_etablissement_screen.dart';
import '../recherche_page.dart';

const _bleu = Color(0xFF0072CE);

class ListeEtablissementsScreen extends StatelessWidget {
  final String? type; // null = tous les établissements
  const ListeEtablissementsScreen({super.key, this.type});

  String get _titre => switch (type) {
        'restaurant' => 'Restaurants',
        'fast-food' => 'Fast-foods',
        'maïga' => 'Maïgas',
        _ => 'Établissements',
      };

  @override
  Widget build(BuildContext context) {
    final EtablissementService service = EtablissementService();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final estClient = estClientNotifier.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titre),
        actions: [
          IconButton(
            tooltip: 'Rechercher',
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecherchePage()),
            ),
          ),
          const ClocheNotifications(),
        ],
      ),
      body: StreamBuilder<List<Etablissement>>(
        stream: service.getEtablissements(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final etablissements = (snapshot.data ?? [])
              .where((e) => type == null || e.type == type)
              .toList();

          if (etablissements.isEmpty) {
            return const Center(
                child: Text('Aucun établissement pour le moment'));
          }

          return StreamBuilder<Set<String>>(
            stream: (uid == null || !estClient)
                ? null
                : FavorisService().favorisDuClient(uid),
            builder: (context, favSnap) {
              final favoris = favSnap.data ?? <String>{};
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: etablissements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final e = etablissements[i];
                  final estFavori = favoris.contains(e.id);
                  return _CarteListe(
                    etablissement: e,
                    estFavori: estFavori,
                    afficherFavori: estClient && uid != null,
                    onFavori: uid == null
                        ? null
                        : () => FavorisService()
                            .basculer(uid, e.id, dejaFavori: estFavori),
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

/// Une carte de la liste : icône du type, nom, type, adresse, note, cœur et prix.
class _CarteListe extends StatelessWidget {
  final Etablissement etablissement;
  final bool estFavori;
  final bool afficherFavori;
  final VoidCallback? onFavori;
  const _CarteListe({
    required this.etablissement,
    required this.estFavori,
    required this.afficherFavori,
    required this.onFavori,
  });

  String get _libelleType => switch (etablissement.type) {
        'fast-food' => 'Fast-food',
        'maïga' || 'maiga' => 'Maïga',
        _ => 'Restaurant',
      };

  @override
  Widget build(BuildContext context) {
    final e = etablissement;
    final couleur = couleurPourType(e.type);

    return Material(
      color: AppColors.carte,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FicheEtablissementScreen(etablissement: e),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.bordure),
          ),
          child: Row(
            children: [
              e.photoUrl.isEmpty
                  ? Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: couleur.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconePourType(e.type),
                          color: couleur, size: 28),
                    )
                  : ClipOval(
                      child: Image.network(e.photoUrl,
                          fit: BoxFit.cover, width: 56, height: 56),
                    ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.nom,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brunTexte)),
                    const SizedBox(height: 2),
                    Text(_libelleType,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _bleu)),
                    const SizedBox(height: 2),
                    Text(e.adresse,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.brunClair)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_border,
                            color: AppColors.or, size: 16),
                        const SizedBox(width: 4),
                        Text(e.noteMoyenne.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.brunTexte)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (afficherFavori) ...[
                    GestureDetector(
                      onTap: onFavori,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          estFavori ? Icons.favorite : Icons.favorite_border,
                          color: estFavori
                              ? AppColors.terracotta
                              : AppColors.brunClair,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(e.categoriePrix,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.brunTexte)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}