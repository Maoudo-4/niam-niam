import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../services/client_service.dart';

/// Formulaire de modification du profil client (prérempli).
/// Se ferme avec `true` quand les modifications sont enregistrées.
class ModifierProfilClientScreen extends StatefulWidget {
  final Client client;
  const ModifierProfilClientScreen({super.key, required this.client});

  @override
  State<ModifierProfilClientScreen> createState() =>
      _ModifierProfilClientScreenState();
}

class _ModifierProfilClientScreenState
    extends State<ModifierProfilClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClientService _service = ClientService();

  late final TextEditingController _prenomController;
  late final TextEditingController _nomController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _adresseController;

  bool _enCours = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _prenomController = TextEditingController(text: widget.client.prenom);
    _nomController = TextEditingController(text: widget.client.nom);
    _telephoneController =
        TextEditingController(text: widget.client.telephone);
    _adresseController = TextEditingController(text: widget.client.adresse);
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
      final maj = Client(
        uid: widget.client.uid,
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        adresse: _adresseController.text.trim(),
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