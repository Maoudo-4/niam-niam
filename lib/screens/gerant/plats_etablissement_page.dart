import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/etablissement.dart';
import '../../models/produit.dart';
import '../../services/etablissement_service.dart';
import '../../services/produit_service.dart';
import '../../theme.dart';

/// Gestion des plats du gérant : ajouter ou supprimer.
class PlatsEtablissementPage extends StatefulWidget {
  const PlatsEtablissementPage({super.key});

  @override
  State<PlatsEtablissementPage> createState() =>
      _PlatsEtablissementPageState();
}

class _PlatsEtablissementPageState extends State<PlatsEtablissementPage> {
  final _etablissementService = EtablissementService();
  final _produitService = ProduitService();
  late Future<Etablissement?> _etablissementFuture;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _etablissementFuture = uid == null
        ? Future<Etablissement?>.value(null)
        : _etablissementService.getEtablissementParProprietaire(uid);
  }

  // Le type de l'établissement s'écrit « maïga », la catégorie du plat « maiga »
  String _categorieProduit(Etablissement e) =>
      e.type == 'maïga' ? 'maiga' : e.type;

  Future<void> _ajouterPlat(Etablissement e) async {
    final plat = await showDialog<_NouveauPlat>(
      context: context,
      builder: (_) => const _DialogAjoutPlat(),
    );
    if (plat == null) return;

    try {
      await _produitService.ajouterProduit(
        etablissementId: e.id,
        nom: plat.nom,
        prix: plat.prix,
        categorie: _categorieProduit(e),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur : $err')),
      );
    }
  }

  Future<bool> _confirmerSuppression(String nomPlat) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer ce plat ?'),
        content: Text(
            'Voulez-vous vraiment retirer « $nomPlat » de votre menu ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirme ?? false;
  }

  Future<void> _supprimerPlat(Produit p) async {
    final confirme = await _confirmerSuppression(p.nom);
    if (!confirme) return;

    try {
      await _produitService.supprimerProduit(p.id);
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur : $err')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes plats'),
        centerTitle: true,
      ),
      body: FutureBuilder<Etablissement?>(
        future: _etablissementFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }
          final e = snapshot.data;
          if (e == null) {
            return const Center(child: Text('Aucun établissement trouvé'));
          }

          return Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<Produit>>(
                  stream:
                      _produitService.produitsDisponibles(etablissementId: e.id),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Center(child: Text('Erreur : ${snap.error}'));
                    }
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final plats = snap.data!;
                    if (plats.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Aucun plat pour le moment. Ajoutez-en pour que '
                            'les clients puissent commander chez vous.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      itemCount: plats.length,
                      itemBuilder: (context, i) {
                        final p = plats[i];
                        return ListTile(
                          leading: const Icon(Icons.restaurant_menu,
                              color: AppColors.terracotta),
                          title: Text(p.nom),
                          subtitle: Text('${p.prix.toStringAsFixed(0)} FCFA'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _supprimerPlat(p),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Bouton pleine largeur, collé en bas
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _ajouterPlat(e),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un plat'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Résultat de la fenêtre d'ajout.
class _NouveauPlat {
  final String nom;
  final double prix;
  _NouveauPlat(this.nom, this.prix);
}

/// Petite fenêtre : nom + prix du plat.
class _DialogAjoutPlat extends StatefulWidget {
  const _DialogAjoutPlat();

  @override
  State<_DialogAjoutPlat> createState() => _DialogAjoutPlatState();
}

class _DialogAjoutPlatState extends State<_DialogAjoutPlat> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prixController = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  double? _lirePrix(String? v) =>
      double.tryParse((v ?? '').trim().replaceAll(',', '.'));

  void _valider() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      _NouveauPlat(_nomController.text.trim(), _lirePrix(_prixController.text)!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un plat'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nom du plat'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Nom requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix (FCFA)'),
              validator: (v) {
                final p = _lirePrix(v);
                return (p == null || p <= 0) ? 'Prix invalide' : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(onPressed: _valider, child: const Text('Ajouter')),
      ],
    );
  }
}