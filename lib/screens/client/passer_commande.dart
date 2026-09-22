import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/commande.dart';
import '../../models/etablissement.dart';
import '../../models/produit.dart';
import '../../services/commande_service.dart';
import '../../services/produit_service.dart';
import '../../theme.dart';
import 'suivi_commande.dart';

class PasserCommande extends StatefulWidget {
  final Etablissement etablissement;
  const PasserCommande({super.key, required this.etablissement});

  @override
  State<PasserCommande> createState() => _PasserCommandeState();
}

class _PasserCommandeState extends State<PasserCommande> {
  final _service = CommandeService();
  final _produitService = ProduitService();

  // Quantité choisie par produit (clé = produitId). Absent ou 0 = pas au panier.
  final Map<String, int> _quantites = {};
  bool _envoi = false;

  int _quantite(String produitId) => _quantites[produitId] ?? 0;

  void _changerQuantite(String produitId, int delta) {
    setState(() {
      final nouvelle = _quantite(produitId) + delta;
      _quantites[produitId] = nouvelle < 0 ? 0 : nouvelle;
    });
  }

  List<LigneCommande> _construireLignes(List<Produit> produits) {
    return produits
        .where((p) => _quantite(p.id) > 0)
        .map((p) => LigneCommande(
              produitId: p.id,
              nom: p.nom,
              prixUnitaire: p.prix,
              quantite: _quantite(p.id),
            ))
        .toList();
  }

  Future<void> _payer(List<Produit> produits) async {
    final lignes = _construireLignes(produits);
    if (lignes.isEmpty) return;

    setState(() => _envoi = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final commandeId = await _service.creerCommande(
      clientId: uid,
      etablissementId: widget.etablissement.id,
      lignes: lignes,
    );

    if (!mounted) return;
    setState(() => _envoi = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SuiviCommande(commandeId: commandeId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Commander chez ${widget.etablissement.nom}')),
      body: StreamBuilder<List<Produit>>(
        stream: _produitService.produitsDisponibles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final produits = snapshot.data!
              .where((p) =>
                  p.categorie != 'maiga' &&
                  p.etablissementId == widget.etablissement.id)
              .toList();

          if (produits.isEmpty) {
            return const Center(
              child: Text('Aucun plat disponible pour le moment'),
            );
          }

          final lignes = _construireLignes(produits);
          final total = lignes.fold<double>(0, (t, l) => t + l.sousTotal);
          final nombreArticles = lignes.length;

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: produits.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final p = produits[i];
                    final q = _quantite(p.id);
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.carte,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.bordure),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.nom,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brunTexte)),
                                const SizedBox(height: 4),
                                Text('${p.prix.toStringAsFixed(0)} FCFA',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.brunClair)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: q > 0
                                ? () => _changerQuantite(p.id, -1)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppColors.terracotta,
                          ),
                          Text('$q',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brunTexte)),
                          IconButton(
                            onPressed: () => _changerQuantite(p.id, 1),
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppColors.vert,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.carte,
                  border: Border(top: BorderSide(color: AppColors.bordure)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.brunClair)),
                          Text(
                            '${total.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brunTexte),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 180,
                        child: _envoi
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: nombreArticles > 0
                                    ? () => _payer(produits)
                                    : null,
                                child: Text('Payer ($nombreArticles)'),
                              ),
                      ),
                    ],
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