import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart'; // NOUVEAU
import '../../models/commande.dart';
import '../../models/etablissement.dart';
import '../../models/produit.dart';
import '../../services/commande_service.dart';
import '../../services/produit_service.dart';
import '../../theme.dart';
import 'choisir_position_page.dart'; // NOUVEAU
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

  // NOUVEAU : lieu de livraison et point de repère
  LatLng? _positionLivraison;
  final _repereController = TextEditingController();

  // NOUVEAU
  @override
  void dispose() {
    _repereController.dispose();
    super.dispose();
  }

  // NOUVEAU : ouvre l'écran de choix de position et récupère le résultat
  Future<void> _choisirPosition() async {
    final resultat = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChoisirPositionPage(positionInitiale: _positionLivraison),
      ),
    );
    if (resultat != null) setState(() => _positionLivraison = resultat);
  }

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
    if (lignes.isEmpty || _positionLivraison == null) return; // MODIFIÉ

    setState(() => _envoi = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final commandeId = await _service.creerCommande(
      clientId: uid,
      etablissementId: widget.etablissement.id,
      lignes: lignes,
      latitudeLivraison: _positionLivraison!.latitude, // NOUVEAU
      longitudeLivraison: _positionLivraison!.longitude, // NOUVEAU
      repereLivraison: _repereController.text.trim(), // NOUVEAU
    );

    if (!mounted) return;
    setState(() => _envoi = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SuiviCommande(commandeId: commandeId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icone = iconePourType(widget.etablissement.type);
    return Scaffold(
      appBar: AppBar(title: Text('Commander chez ${widget.etablissement.nom}')),
      body: StreamBuilder<List<Produit>>(
        stream: _produitService.produitsDisponibles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final produits = snapshot.data!
              .where((p) => p.etablissementId == widget.etablissement.id)
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
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.creme,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icone,
                                color: AppColors.terracotta, size: 24),
                          ),
                          const SizedBox(width: 12),
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

              // NOUVEAU : bloc lieu de livraison + point de repère
              Container(
                color: AppColors.carte,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _choisirPosition,
                        icon: Icon(_positionLivraison == null
                            ? Icons.location_on_outlined
                            : Icons.check_circle),
                        label: Text(_positionLivraison == null
                            ? 'Choisir le lieu de livraison'
                            : 'Lieu de livraison choisi ✓ (modifier)'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _repereController,
                      decoration: const InputDecoration(
                        hintText:
                            'Point de repère (ex : en face de la pharmacie)',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                    ),
                  ],
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
                                // MODIFIÉ : exige aussi la position
                                onPressed: (nombreArticles > 0 &&
                                        _positionLivraison != null)
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