import 'package:flutter/material.dart';
import '../../models/produit.dart';
import '../../services/produit_service.dart';
import '../../theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/commande_service.dart';
import 'suivi_commande.dart';

class PasserCommande extends StatefulWidget {
  const PasserCommande({super.key});

  @override
  State<PasserCommande> createState() => _PasserCommandeState();
}

class _PasserCommandeState extends State<PasserCommande> {
  final _service = CommandeService();
  final _produitService = ProduitService();
  Produit? _produitChoisi;
  int _quantite = 1;
  bool _envoi = false;

    Future<void> _commander() async {
    if (_produitChoisi == null) return;

    setState(() => _envoi = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final commandeId = await _service.creerCommande(
      clientId: uid,
      etablissementId: _produitChoisi!.etablissementId,
      description: '${_produitChoisi!.nom} x$_quantite',
      montant: _produitChoisi!.prix * _quantite,
    );

    setState(() => _envoi = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SuiviCommande(commandeId: commandeId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passer une commande')),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Détails de la commande',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brunTexte)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.carte,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.bordure),
                ),
                child: StreamBuilder<List<Produit>>(
                  stream: _produitService.produitsDisponibles(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final produits = snapshot.data!
                        .where((p) => p.categorie != 'maiga')
                        .toList();
                    return DropdownButtonFormField<Produit>(
                      decoration: const InputDecoration(labelText: 'Choisir un plat'),
                      value: _produitChoisi,
                      items: produits.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p.nom} — ${p.prix.toStringAsFixed(0)} FCFA'),
                        );
                      }).toList(),
                      onChanged: (p) => setState(() => _produitChoisi = p),
                    );
                  },
                ),
                          ),
            if (_produitChoisi != null) ...[
              const SizedBox(height: 20),
              const Text('Quantité',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brunTexte)),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: _quantite > 1
                        ? () => setState(() => _quantite--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColors.terracotta,
                  ),
                  Text('$_quantite',
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brunTexte)),
                  IconButton(
                    onPressed: () => setState(() => _quantite++),
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.vert,
                  ),
                ],
              ),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.carte,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.bordure),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontSize: 12, color: AppColors.brunClair)),
                       Text(
                        '${((_produitChoisi?.prix ?? 0) * _quantite).toStringAsFixed(0)} FCFA',
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
                            onPressed: _commander,
                            child: const Text('Payer (simulé)'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}