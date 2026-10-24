import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/client.dart';
import '../../services/client_service.dart';
import '../../theme.dart';
import '../../widgets/confirmer_deconnexion.dart';
import 'modifier_profil_client_screen.dart';
import 'changer_mot_de_passe_screen.dart';
import 'favoris_client_page.dart';
import 'historique_commandes_page.dart';
import '../aide_assistance_page.dart';

const _bleu = Color(0xFF0072CE);
const _rouge = Color(0xFFE4202E);

/// Onglet Profil du client : en-tête + carte « Mon compte ».
class ProfilClientPage extends StatefulWidget {
  const ProfilClientPage({super.key});

  @override
  State<ProfilClientPage> createState() => _ProfilClientPageState();
}

class _ProfilClientPageState extends State<ProfilClientPage> {
  final _service = ClientService();
  late Future<Client?> _profilFuture;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  void _charger() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _profilFuture =
        uid == null ? Future<Client?>.value(null) : _service.getProfil(uid);
  }

  String _initiales(Client c) {
    final p = c.prenom.isNotEmpty ? c.prenom[0] : '';
    final n = c.nom.isNotEmpty ? c.nom[0] : '';
    return '$p$n'.toUpperCase();
  }

  // Ouvre le formulaire de modification ; au retour, recharge le profil
  Future<void> _modifierInfos(Client client) async {
    final modifie = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ModifierProfilClientScreen(client: client),
      ),
    );
    if (modifie == true && mounted) {
      setState(_charger);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Informations mises à jour')),
      );
    }
  }

  // Ouvre le formulaire de mot de passe ; confirme au retour si c'est fait
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
      body: FutureBuilder<Client?>(
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

          final client = snapshot.data;
          if (client == null) {
            return const Center(child: Text('Profil introuvable'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête : initiales, nom, email, téléphone, crayon
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
                              _initiales(client),
                              style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: _bleu),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(client.nomComplet,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brunTexte)),
                          if (email != null && email.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(email,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.brunClair)),
                          ],
                          if (client.telephone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(client.telephone,
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
                        icone: LucideIcons.user,
                        titre: 'Modifier mes informations',
                        onTap: () => _modifierInfos(client),
                      ),
                      const _Separateur(),
                      _LigneMenu(
                        icone: LucideIcons.lock,
                        titre: 'Changer mon mot de passe',
                        onTap: _changerMotDePasse,
                      ),
                      const _Separateur(),
                      _LigneMenu(
                        icone: LucideIcons.heart,
                        titre: 'Mes favoris',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FavorisClientPage()),
                        ),
                      ),
                      const _Separateur(),
                      _LigneMenu(
                        icone: LucideIcons.history,
                        titre: 'Historique des commandes',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HistoriqueCommandesPage()),
                        ),
                      ),
                      const _Separateur(),
                      _LigneMenu(
                        icone: LucideIcons.circleHelp,
                        titre: 'Aide et assistance',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AideAssistancePage(),
                          ),
                        ),
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
                    style: TextButton.styleFrom(foregroundColor: _rouge),
                  ),
                ),
              ],
            ),
          );
        },
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