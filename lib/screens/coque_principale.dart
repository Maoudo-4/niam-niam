import 'package:flutter/material.dart';
import '../theme.dart';
import 'accueil_page.dart';
import 'client/liste_etablissements_screen.dart';
import 'client/mes_commandes.dart';
import 'livreur/missions_page.dart';
import 'gerant/profil_gerant_page.dart';
import 'client/profil_client_page.dart';
import 'livreur/profil_livreur_page.dart';

/// Les trois rôles de l'appli.
enum RoleUtilisateur { client, gerant, livreur }

class CoquePrincipale extends StatefulWidget {
  final RoleUtilisateur role;
  const CoquePrincipale({super.key, required this.role});

  @override
  State<CoquePrincipale> createState() => _CoquePrincipaleState();
}

class _CoquePrincipaleState extends State<CoquePrincipale> {
  // 0 = Accueil, 1 = Restaurants, 2 = Commandes, 3 = Profil
  int _index = 0;

  // L'onglet Commandes est la seule page qui change selon le rôle.
  Widget _pageCommandes() => switch (widget.role) {
    RoleUtilisateur.client => const MesCommandes(),
    RoleUtilisateur.gerant =>
      const _PagePlaceholder(titre: 'Commandes reçues'),
    RoleUtilisateur.livreur => const MissionsPage(),
  };
  
  // Onglet Profil : provisoire, seul le gérant a une vraie page pour l'instant
  Widget _pageProfil() => switch (widget.role) {
    RoleUtilisateur.client => const ProfilClientPage(),
    RoleUtilisateur.gerant => const ProfilGerantPage(),
    RoleUtilisateur.livreur => const ProfilLivreurPage(),
  };

  Widget _itemNav(IconData icone, int index) {
    final actif = _index == index;
    return IconButton(
      icon: Icon(icone,
          color: actif ? AppColors.terracotta : AppColors.brunClair),
      onPressed: () => setState(() => _index = index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          AccueilPage(
            onVoirTout: (type) => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ListeEtablissementsScreen(type: type)),
            ),
          ),
          const ListeEtablissementsScreen(),
          _pageCommandes(),
          _pageProfil(),
        ],
      ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            // TODO: carte des établissements à proximité (à construire)
          },
          backgroundColor: AppColors.terracotta,
          child: const Icon(Icons.location_searching,
              color: Colors.white, size: 20),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 50,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        color: AppColors.carte,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _itemNav(Icons.home, 0),
            _itemNav(Icons.storefront, 1),
            const SizedBox(width: 40), // espace pour le bouton flottant
            _itemNav(Icons.receipt_long, 2),
            _itemNav(Icons.person, 3),
          ],
        ),
      ),
    );
  }
}

/// Page provisoire pour les onglets pas encore construits.
class _PagePlaceholder extends StatelessWidget {
  final String titre;
  const _PagePlaceholder({required this.titre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: Center(child: Text('$titre : bientôt disponible')),
    );
  }
}