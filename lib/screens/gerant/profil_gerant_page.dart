import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/etablissement.dart';
import '../../services/etablissement_service.dart';
import '../../theme.dart';
import '../../widgets/confirmer_deconnexion.dart';
import '../client/changer_mot_de_passe_screen.dart';
import 'plats_etablissement_page.dart';
import 'modifier_etablissement_screen.dart';
import 'historique_commandes_gerant_page.dart';
import 'statistiques_gerant_page.dart';

/// Onglet Profil du gérant : en-tête (établissement) + menu « Mon établissement ».
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

  // Provisoire : historique et statistiques arrivent aux prochaines étapes
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
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Etablissement?>(
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

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // En-tête : avatar, nom, email, adresse
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.terracotta,
                              child: Text(
                                _initiales(e),
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.nom,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.brunTexte),
                                  ),
                                  if (email != null && email.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(email,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.brunClair)),
                                  ],
                                  if (e.adresse.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(e.adresse,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.brunClair)),
                                  ],
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () => _modifierEtablissement(e),
                              icon: const Icon(Icons.edit, size: 20),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 20),

                        const Text('Mon établissement',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brunTexte)),
                        const SizedBox(height: 14),

                        Expanded(
                          child: _LigneMenu(
                            icone: Icons.lock_outline,
                            titre: 'Changer le mot de passe',
                            onTap: _changerMotDePasse,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _LigneMenu(
                            icone: Icons.restaurant_menu,
                            titre: 'Gérer les plats',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const PlatsEtablissementPage()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _LigneMenu(
                            icone: Icons.receipt_long,
                            titre: 'Historique des commandes reçues',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const HistoriqueCommandesGerantPage()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _LigneMenu(
                            icone: Icons.bar_chart,
                            titre: 'Statistiques',
                            onTap: () =>Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const StatistiquesGerantPage()),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _LigneMenu(
                            icone: Icons.help_outline,
                            titre: 'Aide et assistance',
                            onTap: () =>
                                _ouvrirBientot('Aide et assistance'),
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          onPressed: () => confirmerDeconnexion(context),
                          icon: const Icon(Icons.logout),
                          label: const Text('Se déconnecter'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Une ligne du menu, sous forme de carte : pastille d'icône + titre + flèche.
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: AppColors.terracotta, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(titre,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.brunTexte)),
              ),
              const Icon(Icons.chevron_right, color: AppColors.brunClair),
            ],
          ),
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