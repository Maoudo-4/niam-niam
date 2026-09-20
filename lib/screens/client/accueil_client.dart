import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';
import 'passer_commande.dart';
import 'mes_commandes.dart';
import '../../widgets/confirmer_deconnexion.dart';
import '../../widgets/accueil_contenu.dart';
import 'liste_etablissements_screen.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: recherche des établissements à proximité (à construire)
        },
        backgroundColor: AppColors.terracotta,
        child: const Icon(Icons.location_searching, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.carte,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: AppColors.terracotta),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.storefront, color: AppColors.brunClair),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ListeEtablissementsScreen())),
            ),
            const SizedBox(width: 40), // espace pour le bouton flottant
            IconButton(
              icon: const Icon(Icons.receipt_long, color: AppColors.brunClair),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MesCommandes())),
            ),
            IconButton(
              icon: const Icon(Icons.person, color: AppColors.brunClair),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccueilContenu(
              onVoirTout: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ListeEtablissementsScreen()),
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
