import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/etablissement_service.dart';
import '../../models/etablissement.dart';
import 'creer_etablissement_screen.dart';
import '../../widgets/confirmer_deconnexion.dart';
import '../coque_principale.dart';


class AccueilGerant extends StatefulWidget {
  const AccueilGerant({super.key});

  @override
  State<AccueilGerant> createState() => _AccueilGerantState();
}

class _AccueilGerantState extends State<AccueilGerant> {
  final EtablissementService _service = EtablissementService();
  Etablissement? _monEtablissement;
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _verifierEtablissement();
  }

  Future<void> _verifierEtablissement() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final etab = await _service.getEtablissementParProprietaire(uid);
      if (!mounted) return;
      setState(() {
        _monEtablissement = etab;
        _chargement = false;
      });
    } else {
      if (!mounted) return;
      setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_chargement) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Pas encore d'établissement : formulaire de création (comme avant)
    if (_monEtablissement == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Accueil Gérant'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => confirmerDeconnexion(context),
            ),
          ],
        ),
        body: CreerEtablissementScreen(
          onEtablissementCree: _verifierEtablissement,
        ),
      );
    }

    // Établissement créé : même interface que le client, rôle gérant
    return const CoquePrincipale(role: RoleUtilisateur.gerant);
  }
}