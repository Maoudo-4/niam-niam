import 'package:flutter/material.dart';
import '../models/etablissement.dart';
import '../models/produit.dart';
import '../services/etablissement_service.dart';
import '../services/produit_service.dart';
import '../theme.dart';
import 'client/fiche_etablissement_screen.dart';

/// Page de recherche, ouverte depuis la loupe de l'accueil.
/// Cherche des établissements (nom, type, adresse) et des plats (nom),
/// sans tenir compte des majuscules ni des accents.
class RecherchePage extends StatefulWidget {
  const RecherchePage({super.key});

  @override
  State<RecherchePage> createState() => _RecherchePageState();
}

class _RecherchePageState extends State<RecherchePage> {
  final _controller = TextEditingController();

  // Les flux sont créés une seule fois, pour ne pas se relancer à chaque lettre
  late final Stream<List<Etablissement>> _etablissements =
      EtablissementService().getEtablissements();
  late final Stream<List<Produit>> _produits =
      ProduitService().produitsDisponibles();

  String _requete = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Minuscules et sans accents : « Maïga » devient « maiga »
  String _normaliser(String texte) {
    const avec = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿ';
    const sans = 'aaaaaaceeeeiiiinooooouuuuyy';
    final buffer = StringBuffer();
    for (final c in texte.toLowerCase().split('')) {
      final i = avec.indexOf(c);
      buffer.write(i == -1 ? c : sans[i]);
    }
    return buffer.toString();
  }

  // Tous les mots tapés doivent se retrouver dans le texte
  bool _contientTous(String texte, String requete) {
    final cible = _normaliser(texte);
    final mots =
        _normaliser(requete).split(' ').where((m) => m.isNotEmpty);
    return mots.every((m) => cible.contains(m));
  }

  void _choisirSuggestion(String texte) {
    _controller.text = texte;
    _controller.selection = TextSelection.collapsed(offset: texte.length);
    setState(() => _requete = texte);
  }

  void _ouvrirFiche(Etablissement e) {
    FocusScope.of(context).unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FicheEtablissementScreen(etablissement: e),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requete = _requete.trim();

    final bordure = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide.none,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (v) => setState(() => _requete = v),
            style: const TextStyle(color: AppColors.brunTexte),
            decoration: InputDecoration(
              hintText: 'Rechercher un plat ou un établissement',
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.brunClair),
              suffixIcon: _requete.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.cancel,
                          color: AppColors.brunClair),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _requete = '');
                      },
                    ),
              border: bordure,
              enabledBorder: bordure,
              focusedBorder: bordure,
            ),
          ),
        ),
      ),
      body: requete.isEmpty ? _suggestions() : _resultats(requete),
    );
  }

  // Avant de taper : des raccourcis vers les trois types d'établissements
  Widget _suggestions() {
    Widget puce(String label, IconData icone) => ActionChip(
          avatar: Icon(icone, size: 18, color: AppColors.terracotta),
          label: Text(label),
          onPressed: () => _choisirSuggestion(label),
        );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _TitreSection('Suggestions'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            puce('Restaurant', Icons.restaurant),
            puce('Fast-food', Icons.lunch_dining),
            puce('Maïga', Icons.storefront),
          ],
        ),
      ],
    );
  }

  Widget _resultats(String requete) {
    return StreamBuilder<List<Etablissement>>(
      stream: _etablissements,
      builder: (context, etabSnap) {
        return StreamBuilder<List<Produit>>(
          stream: _produits,
          builder: (context, prodSnap) {
            if (etabSnap.hasError || prodSnap.hasError) {
              return Center(
                child: Text('Erreur : ${etabSnap.error ?? prodSnap.error}'),
              );
            }
            if (!etabSnap.hasData || !prodSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final etablissements = etabSnap.data!;
            final parId = {for (final e in etablissements) e.id: e};

            final etabTrouves = etablissements
                .where((e) =>
                    _contientTous('${e.nom} ${e.type} ${e.adresse}', requete))
                .toList();

            // Un plat n'est affiché que si son établissement existe encore
            final platsTrouves = prodSnap.data!
                .where((p) =>
                    parId.containsKey(p.etablissementId) &&
                    _contientTous(p.nom, requete))
                .toList();

            if (etabTrouves.isEmpty && platsTrouves.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Aucun résultat pour « $requete »',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (etabTrouves.isNotEmpty) ...[
                  const _TitreSection('Établissements'),
                  const SizedBox(height: 12),
                  for (final e in etabTrouves) ...[
                    _CarteResultat(
                      etablissement: e,
                      onTap: () => _ouvrirFiche(e),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
                if (platsTrouves.isNotEmpty) ...[
                  if (etabTrouves.isNotEmpty) const SizedBox(height: 12),
                  const _TitreSection('Plats'),
                  const SizedBox(height: 12),
                  for (final p in platsTrouves) ...[
                    _CartePlat(
                      plat: p,
                      nomEtablissement: parId[p.etablissementId]!.nom,
                      onTap: () => _ouvrirFiche(parId[p.etablissementId]!),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            );
          },
        );
      },
    );
  }
}

/// Titre d'une section de la page (Suggestions, Établissements, Plats).
class _TitreSection extends StatelessWidget {
  final String texte;
  const _TitreSection(this.texte);

  @override
  Widget build(BuildContext context) {
    return Text(
      texte,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.brunTexte,
      ),
    );
  }
}

/// Un établissement trouvé : icône, nom, type et adresse, note à droite.
class _CarteResultat extends StatelessWidget {
  final Etablissement etablissement;
  final VoidCallback onTap;
  const _CarteResultat({required this.etablissement, required this.onTap});

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
          padding: const EdgeInsets.all(14),
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
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 2),
              Text(
                etablissement.nombreAvis == 0
                    ? 'Nouveau'
                    : etablissement.noteMoyenne.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 13, color: AppColors.brunTexte),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un plat trouvé : nom, établissement qui le propose, prix à droite.
class _CartePlat extends StatelessWidget {
  final Produit plat;
  final String nomEtablissement;
  final VoidCallback onTap;
  const _CartePlat({
    required this.plat,
    required this.nomEtablissement,
    required this.onTap,
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
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant_menu,
                    color: AppColors.terracotta, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plat.nom,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brunTexte)),
                    const SizedBox(height: 2),
                    Text('chez $nomEtablissement',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.brunClair)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${plat.prix.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brunTexte),
              ),
            ],
          ),
        ),
      ),
    );
  }
}