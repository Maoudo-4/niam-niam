import 'package:flutter/material.dart';
import '../../models/livreur.dart';
import '../../services/livreur_service.dart';

/// Formulaire de modification du profil livreur (prérempli).
/// Se ferme avec `true` quand les modifications sont enregistrées.
class ModifierProfilLivreurScreen extends StatefulWidget {
  final Livreur livreur;
  const ModifierProfilLivreurScreen({super.key, required this.livreur});

  @override
  State<ModifierProfilLivreurScreen> createState() =>
      _ModifierProfilLivreurScreenState();
}

class _ModifierProfilLivreurScreenState
    extends State<ModifierProfilLivreurScreen> {
  final _formKey = GlobalKey<FormState>();
  final LivreurService _service = LivreurService();

  late final TextEditingController _prenomController;
  late final TextEditingController _nomController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _adresseController;
  late String _moyenDeplacement;

  bool _enCours = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _prenomController = TextEditingController(text: widget.livreur.prenom);
    _nomController = TextEditingController(text: widget.livreur.nom);
    _telephoneController =
        TextEditingController(text: widget.livreur.telephone);
    _adresseController = TextEditingController(text: widget.livreur.adresse);
    _moyenDeplacement = widget.livreur.moyenDeplacement;
  }

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

    setState(() {
      _enCours = true;
      _message = null;
    });

    try {
      final maj = Livreur(
        uid: widget.livreur.uid,
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        adresse: _adresseController.text.trim(),
        moyenDeplacement: _moyenDeplacement,
      );

      await _service.mettreAJourProfil(maj);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = '❌ Erreur : $e';
        _enCours = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier mes informations')),
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
              const SizedBox(height: 16),

              TextFormField(
                controller: _nomController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 16),

              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Adresse requise' : null,
              ),
              const SizedBox(height: 16),

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
                    : const Text('Enregistrer les modifications'),
              ),

              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}