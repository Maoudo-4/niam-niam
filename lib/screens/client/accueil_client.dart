import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import 'passer_commande.dart';
import 'mes_commandes.dart';
import '../../widgets/confirmer_deconnexion.dart';
import '../../models/etablissement.dart';
import '../../services/etablissement_service.dart';
import '../../widgets/carte_etablissement.dart';

class AccueilClient extends StatelessWidget {
  const AccueilClient({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NIAM-NIAM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => confirmerDeconnexion(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Qu\'est-ce qu\'on mange aujourd\'hui ?',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brunTexte)),
            const SizedBox(height: 20),

            const Text('Catégories',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brunTexte)),
            const SizedBox(height: 12),
            Row(
              children: [
                _CategoriePastille(icone: Icons.restaurant, label: 'Restaurant'),
                const SizedBox(width: 12),
                _CategoriePastille(icone: Icons.lunch_dining, label: 'Fast-food'),
                const SizedBox(width: 12),
                _CategoriePastille(icone: Icons.storefront, label: 'Maïga'),
              ],
            ),

              const SizedBox(height: 28),
              const Text('Top Restaurants',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brunTexte)),
              const SizedBox(height: 12),
              SizedBox(
                height: 170,
                child: StreamBuilder<List<Etablissement>>(
                  stream: EtablissementService().getEtablissements(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final restaurants = snapshot.data!
                        .where((e) => e.type == 'restaurant')
                        .toList();
                    if (restaurants.isEmpty) {
                      return const Center(child: Text('Aucun restaurant pour le moment'));
                    }
                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: restaurants
                          .map((e) => CarteEtablissement(etablissement: e))
                          .toList(),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PasserCommande()),
                );
              },
              child: const Text('Passer une commande (test)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MesCommandes()),
                );
              },
              child: const Text('Mes commandes'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriePastille extends StatelessWidget {
  final IconData icone;
  final String label;
  const _CategoriePastille({required this.icone, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.carte,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bordure),
        ),
        child: Column(
          children: [
            Icon(icone, color: AppColors.terracotta, size: 22),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.brunTexte)),
          ],
        ),
      ),
    );
  }
}