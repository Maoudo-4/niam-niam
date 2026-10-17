import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/etablissement.dart';
import '../../services/etablissement_service.dart';
import '../../theme.dart';
import '../../widgets/confirmer_deconnexion.dart';
import '../client/changer_mot_de_passe_screen.dart';
import 'plats_etablissement_page.dart';
import 'modifier_etablissement_screen.dart';
import 'historique_commandes_gerant_page.dart';
import 'statistiques_gerant_page.dart';

const _bleu = Color(0xFF0072CE);
const _rouge = Color(0xFFE4202E);

/// Onglet Profil du gérant : en-tête (établissement) + carte « Mon compte ».
class ProfilGerantPage extends StatefulWidget {
  const ProfilGerantPage({super.key});

  @override
  State<ProfilGerantPage> createState() => _ProfilGerantPageState();
}

class _ProfilGerantPageState extends State<ProfilGerantPage> {
  final _service = EtablissementService();
  late Future<Etablissement?> _etablissementFuture;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _charger() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _etablissementFuture = uid == null
        ? Future<Etablissement?>.value(null)
        : _service.getEtablissementParProprietaire(uid);
  }

  Future<void> _modifierEtablissement(Etablissement e) async {
    final modifie = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ModifierEtablissementScreen(etablissement: e),
      ),
    );
    if (modifie == true && mounted) {
      setState(_charger);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Établissement mis à jour')),
      );
    }
  }

  String _initiales(Etablissement e) =>
      e.nom.isNotEmpty ? e.nom[0].toUpperCase() : '?';

  String _libelleType(Etablissement e) => switch (e.type) {
        'fast-food' => 'Fast-food',
        'maïga' || 'maiga' => 'Maïga',
        _ => 'Restaurant',
      };

  Future<void> _changerMotDePasse() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ChangerMotDePasseScreen()),
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Mot de passe modifié')),
      );
    }
  }

  // Provisoire : l'aide arrive plus tard
  void _ouvrirBientot(String titre) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _PageBientot(titre: titre)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil du gérant')),
      body: SafeArea(
        child: FutureBuilder<Etablissement?>(
          future: _etablissementFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('❌ Impossible de charger votre établissement'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => setState(_charger),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final e = snapshot.data;
            if (e == null) {
              return const Center(child: Text('Établissement introuvable'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // En-tête : initiales, nom, type, email, crayon
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: _bleu.withValues(alpha: 0.12),
                              child: Text(
                                _initiales(e),
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: _bleu),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(e.nom,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brunTexte)),
                            const SizedBox(height: 4),
                            Text(_libelleType(e),
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _bleu)),
                            if (email != null && email.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(email,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.brunClair)),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          tooltip: 'Changer la photo de profil',
                          // À brancher plus tard, quand le stockage des images sera choisi
                          onPressed: () {},
                          icon: const Icon(LucideIcons.pencil,
                              color: _bleu, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Carte « Mon compte »
                  Material(
                    color: AppColors.carte,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.bordure),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('Mon compte',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: _bleu)),
                        ),
                        _LigneMenu(
                          icone: LucideIcons.store,
                          titre: 'Modifier mon établissement',
                          onTap: () => _modifierEtablissement(e),
                        ),
                        const _Separateur(),
                        _LigneMenu(
                          icone: LucideIcons.lock,
                          titre: 'Changer mon mot de passe',
                          onTap: _changerMotDePasse,
                        ),
                        const _Separateur(),
                        _LigneMenu(
                          icone: LucideIcons.utensilsCrossed,
                          titre: 'Mes plats',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const PlatsEtablissementPage()),
                          ),
                        ),
                        const _Separateur(),
                        _LigneMenu(
                          icone: LucideIcons.history,
                          titre: 'Historique des commandes',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const HistoriqueCommandesGerantPage()),
                          ),
                        ),
                        const _Separateur(),
                        _LigneMenu(
                          icone: LucideIcons.chartNoAxesCombined,
                          titre: 'Statistiques',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const StatistiquesGerantPage()),
                          ),
                        ),
                        const _Separateur(),
                        _LigneMenu(
                          icone: LucideIcons.circleHelp,
                          titre: 'Aide et assistance',
                          onTap: () => _ouvrirBientot('Aide et assistance'),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton.icon(
                      onPressed: () => confirmerDeconnexion(context),
                      icon: const Icon(LucideIcons.logOut, size: 20),
                      label: const Text('Se déconnecter',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                      style:
                          TextButton.styleFrom(foregroundColor: _rouge),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Trait fin entre deux lignes du menu.
class _Separateur extends StatelessWidget {
  const _Separateur();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.bordure,
    );
  }
}

/// Une ligne du menu : icône bleue, titre, flèche.
class _LigneMenu extends StatelessWidget {
  final IconData icone;
  final String titre;
  final VoidCallback onTap;
  const _LigneMenu({
    required this.icone,
    required this.titre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icone, color: _bleu, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(titre,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brunTexte)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.brunClair),
          ],
        ),
      ),
    );
  }
}

/// Page provisoire pour les sous-pages pas encore construites.
class _PageBientot extends StatelessWidget {
  final String titre;
  const _PageBientot({required this.titre});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titre)),
      body: Center(child: Text('$titre : bientôt disponible')),
    );
  }
}