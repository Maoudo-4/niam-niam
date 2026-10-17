import 'package:flutter/material.dart';
import '../theme.dart';
import 'accueil_page.dart';
import 'client/liste_etablissements_screen.dart';
import 'client/mes_commandes.dart';
import 'livreur/missions_page.dart';
import 'gerant/profil_gerant_page.dart';
import 'gerant/commandes_recues_page.dart';
import 'client/profil_client_page.dart';
import 'livreur/profil_livreur_page.dart';
import 'carte_etablissements_page.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/role_actuel.dart';

/// Les trois rôles de l'appli.
enum RoleUtilisateur { client, gerant, livreur }
/// Permet à n'importe quelle page de changer l'onglet de la coque.
final ValueNotifier<int> ongletActif = ValueNotifier<int>(0);

class CoquePrincipale extends StatefulWidget {
  final RoleUtilisateur role;
  const CoquePrincipale({super.key, required this.role});

  @override
  State<CoquePrincipale> createState() => _CoquePrincipaleState();
}

class _CoquePrincipaleState extends State<CoquePrincipale> {
  // 0 = Accueil, 1 = Restaurants, 2 = Commandes, 3 = Profil
  int _index = 0;

  @override
  void initState() {
    super.initState();
    estClientNotifier.value = widget.role == RoleUtilisateur.client;
    ongletActif.value = 0;
    ongletActif.addListener(_surChangementOnglet);
  }

  void _surChangementOnglet() {
    if (mounted) setState(() => _index = ongletActif.value);
  }

  @override
  void dispose() {
    ongletActif.removeListener(_surChangementOnglet);
    super.dispose();
  }

  // L'onglet Commandes est la seule page qui change selon le rôle.
  Widget _pageCommandes() => switch (widget.role) {
    RoleUtilisateur.client => const MesCommandes(),
    RoleUtilisateur.gerant => const CommandesRecuesPage(),
    RoleUtilisateur.livreur => const MissionsPage(),
  };

  // Onglet Profil : provisoire, seul le gérant a une vraie page pour l'instant
  Widget _pageProfil() => switch (widget.role) {
    RoleUtilisateur.client => const ProfilClientPage(),
    RoleUtilisateur.gerant => const ProfilGerantPage(),
    RoleUtilisateur.livreur => const ProfilLivreurPage(),
  };

  Widget _itemNav(IconData icone, String label, int index) {
    final actif = _index == index;
    final couleur = actif ? const Color(0xFF0072CE) : AppColors.brunClair;
    return Expanded(
      child: InkWell(
        onTap: () => ongletActif.value = index,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, color: couleur, size: 24),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: actif ? FontWeight.w600 : FontWeight.w400,
                  color: couleur,
                ),
              ),
            ),
          ],
        ),
      ),
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
        onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CarteEtablissementsPage()),
        ),
        backgroundColor: AppColors.terracotta,
        child: const Icon(LucideIcons.mapPin,
            color: Colors.white, size: 20),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 64,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        color: AppColors.carte,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _itemNav(Icons.home, 'Accueil', 0),
              _itemNav(Icons.storefront, 'Établissements', 1),
              const SizedBox(width: 56), // espace pour le bouton flottant
              _itemNav(Icons.receipt_long, 'Commandes', 2),
              _itemNav(Icons.person, 'Profil', 3),
            ],
        ),
      ),
    );
  }
}

