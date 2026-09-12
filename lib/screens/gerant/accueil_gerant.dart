import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/etablissement_service.dart';
import '../../models/etablissement.dart';
import 'creer_etablissement_screen.dart'; // ton formulaire de création
import '../../widgets/confirmer_deconnexion.dart';

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
      setState(() {
        _monEtablissement = etab;
        _chargement = false;
      });
    } else {
      setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : _monEtablissement == null
              ? CreerEtablissementScreen(
                  onEtablissementCree: _verifierEtablissement,
                )
              : Center(
                  child: Text(
                    'Bienvenue, ${_monEtablissement!.nom} 👋',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
    );
  }
}