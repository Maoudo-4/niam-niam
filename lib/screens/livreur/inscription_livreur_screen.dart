import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';

class InscriptionLivreurScreen extends StatefulWidget {
  final VoidCallback? onProfilCree;
  const InscriptionLivreurScreen({super.key, this.onProfilCree});

  @override
  State<InscriptionLivreurScreen> createState() =>
      _InscriptionLivreurScreenState();
}

class _InscriptionLivreurScreenState extends State<InscriptionLivreurScreen> {
  final _formKey = GlobalKey<FormState>();
  final LivreurService _service = LivreurService();

  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();

  String _moyenDeplacement = 'moto';
  bool _enCours = false;
  String? _message;

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _message = '❌ Vous devez être connecté pour continuer';
      });
      return;
    }

    setState(() {
      _enCours = true;
      _message = null;
    });

    try {
      final livreur = Livreur(
        uid: uid,
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        adresse: _adresseController.text.trim(),
        moyenDeplacement: _moyenDeplacement,
      );

      await _service.creerProfil(livreur);

      if (!mounted) return;
      setState(() {
        _message = '✅ Profil enregistré avec succès !';
      });
      widget.onProfilCree?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = '❌ Erreur : $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _enCours = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compléter mon profil livreur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _prenomController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Prénom requis' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nomController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(labelText: 'Numéro de téléphone'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Numéro requis';
                  }
                  final numero = v.replaceAll(' ', '');
                  if (!RegExp(r'^\+?[0-9]{9,15}$').hasMatch(numero)) {
                    return 'Numéro invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Adresse requise' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _moyenDeplacement,
                decoration:
                    const InputDecoration(labelText: 'Moyen de déplacement'),
                items: const [
                  DropdownMenuItem(value: 'moto', child: Text('Moto')),
                  DropdownMenuItem(value: 'velo', child: Text('Vélo')),
                  DropdownMenuItem(value: 'voiture', child: Text('Voiture')),
                  DropdownMenuItem(value: 'a_pied', child: Text('À pied')),
                ],
                onChanged: (v) => setState(() => _moyenDeplacement = v!),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _enCours ? null : _enregistrer,
                child: _enCours
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),

              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message!.startsWith('✅') ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
