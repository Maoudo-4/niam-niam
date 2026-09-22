import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';
import '../../theme.dart';
import '../../widgets/confirmer_deconnexion.dart';
import '../client/changer_mot_de_passe_screen.dart';
import 'historique_livraisons_page.dart';
import 'modifier_profil_livreur_screen.dart';

/// Onglet Profil du livreur : en-tête + menu « Mon compte ».
class ProfilLivreurPage extends StatefulWidget {
  const ProfilLivreurPage({super.key});

  @override
  State<ProfilLivreurPage> createState() => _ProfilLivreurPageState();
}

class _ProfilLivreurPageState extends State<ProfilLivreurPage> {
  final _service = LivreurService();
  late Future<Livreur?> _profilFuture;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _charger() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _profilFuture =
        uid == null ? Future<Livreur?>.value(null) : _service.getProfil(uid);
  }

  String _initiales(Livreur l) {
    final p = l.prenom.isNotEmpty ? l.prenom[0] : '';
    final n = l.nom.isNotEmpty ? l.nom[0] : '';
    return '$p$n'.toUpperCase();
  }

  String _libelleMoyen(String v) => switch (v) {
        'moto' => 'Moto',
        'velo' => 'Vélo',
        'voiture' => 'Voiture',
        'a_pied' => 'À pied',
        _ => v,
      };

  // Ouvre le formulaire de modification ; au retour, recharge le profil
  Future<void> _modifierInfos(Livreur livreur) async {
    final modifie = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ModifierProfilLivreurScreen(livreur: livreur),
      ),
    );
    if (modifie == true && mounted) {
      setState(_charger);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Informations mises à jour')),
      );
    }
  }

  // Ouvre le formulaire de mot de passe (partagé avec le client)
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

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Livreur?>(
        future: _profilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('❌ Impossible de charger votre profil'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(_charger),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final livreur = snapshot.data;
          if (livreur == null) {
            return const Center(child: Text('Profil introuvable'));
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
                        // En-tête : avatar, nom, email, téléphone, moyen, crayon
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.terracotta,
                              child: Text(
                                _initiales(livreur),
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
                                    livreur.nomComplet,
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
                                  if (livreur.telephone.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(livreur.telephone,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.brunClair)),
                                  ],
                                  const SizedBox(height: 2),
                                  Text(
                                    _libelleMoyen(livreur.moyenDeplacement),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.brunClair),
                                  ),
                                ],
                              ),
                            ),
                            IconButton.filledTonal(
                              onPressed: () => _modifierInfos(livreur),
                              icon: const Icon(Icons.edit, size: 20),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(height: 1),
                        const SizedBox(height: 20),

                        const Text('Mon compte',
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
                        const SizedBox(height: 12),
                        Expanded(
                          child: _LigneMenu(
                            icone: Icons.receipt_long,
                            titre: 'Historique des livraisons',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const HistoriqueLivraisonsPage()),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Expanded(
                          child: _LigneMenu(
                            icone: Icons.help_outline,
                            titre: 'Aide et assistance',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const _PageBientot(titre: 'Aide et assistance'),
                              ),
                            ),
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