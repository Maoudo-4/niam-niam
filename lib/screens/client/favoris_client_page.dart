import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/etablissement.dart';
import '../../services/etablissement_service.dart';
import '../../services/favoris_service.dart';
import '../../theme.dart';
import 'fiche_etablissement_screen.dart';

/// Liste des établissements favoris du client.
class FavorisClientPage extends StatefulWidget {
  const FavorisClientPage({super.key});

  @override
  State<FavorisClientPage> createState() => _FavorisClientPageState();
}

class _FavorisClientPageState extends State<FavorisClientPage> {
  final _favorisService = FavorisService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  // Les flux sont créés une seule fois, pour éviter de les relancer à chaque
  // mise à jour de l'écran
  late final Stream<Set<String>>? _favoris = _uid == null
      ? null
      : _favorisService.favorisDuClient(_uid);
  late final Stream<List<Etablissement>> _etablissements =
      EtablissementService().getEtablissements();

  Future<void> _retirer(String etablissementId) async {
    try {
      await _favorisService.basculer(
        _uid!,
        etablissementId,
        dejaFavori: true,
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
      appBar: AppBar(title: const Text('Mes favoris')),
      body: _favoris == null
          ? const Center(child: Text('Vous devez être connecté'))
          : StreamBuilder<Set<String>>(
              stream: _favoris,
              builder: (context, favSnap) {
                if (favSnap.hasError) {
                  return Center(child: Text('Erreur : ${favSnap.error}'));
                }
                if (!favSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final ids = favSnap.data!;
                if (ids.isEmpty) return const _AucunFavori();

                return StreamBuilder<List<Etablissement>>(
                  stream: _etablissements,
                  builder: (context, etabSnap) {
                    if (etabSnap.hasError) {
                      return Center(
                          child: Text('Erreur : ${etabSnap.error}'));
                    }
                    if (!etabSnap.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    final favoris = etabSnap.data!
                        .where((e) => ids.contains(e.id))
                        .toList();
                    if (favoris.isEmpty) return const _AucunFavori();

                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: favoris.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final e = favoris[i];
                        return _CarteFavori(
                          etablissement: e,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FicheEtablissementScreen(etablissement: e),
                            ),
                          ),
                          onRetirer: () => _retirer(e.id),
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

/// Une ligne de la liste : icône, nom, type et adresse, cœur pour retirer.
class _CarteFavori extends StatelessWidget {
  final Etablissement etablissement;
  final VoidCallback onTap;
  final VoidCallback onRetirer;
  const _CarteFavori({
    required this.etablissement,
    required this.onTap,
    required this.onRetirer,
  });

  @override
  Widget build(BuildContext context) {
    final forme = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.bordure),
    );

    return Material(
      color: AppColors.carte,
      shape: forme,
      child: InkWell(
        customBorder: forme,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant,
                    color: AppColors.terracotta, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(etablissement.nom,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brunTexte)),
                    const SizedBox(height: 2),
                    Text('${etablissement.type} • ${etablissement.adresse}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.brunClair)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Retirer des favoris',
                icon:
                    const Icon(Icons.favorite, color: AppColors.terracotta),
                onPressed: onRetirer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AucunFavori extends StatelessWidget {
  const _AucunFavori();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aucun favori pour le moment.\nTouchez le cœur sur la fiche d\'un '
          'établissement pour l\'ajouter ici.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}