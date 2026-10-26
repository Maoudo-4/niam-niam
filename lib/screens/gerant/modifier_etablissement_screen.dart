import 'package:flutter/material.dart';
import '../../models/etablissement.dart';
import '../../services/etablissement_service.dart';
import 'package:geolocator/geolocator.dart';

/// Formulaire de modification de l'établissement (prérempli).
/// Se ferme avec `true` quand les modifications sont enregistrées.
class ModifierEtablissementScreen extends StatefulWidget {
  final Etablissement etablissement;
  const ModifierEtablissementScreen({super.key, required this.etablissement});

  @override
  State<ModifierEtablissementScreen> createState() =>
      _ModifierEtablissementScreenState();
}

class _ModifierEtablissementScreenState
    extends State<ModifierEtablissementScreen> {
  final _formKey = GlobalKey<FormState>();
  final EtablissementService _service = EtablissementService();

  late final TextEditingController _nomController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _adresseController;
  late String _type;
  late String _categoriePrix;
  late double _latitude;
  late double _longitude;
  bool _localisationEnCours = false;

  bool _enCours = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final e = widget.etablissement;
    _nomController = TextEditingController(text: e.nom);
    _descriptionController = TextEditingController(text: e.description);
    _adresseController = TextEditingController(text: e.adresse);
    _type = e.type;
    _categoriePrix = e.categoriePrix;
    _latitude = e.latitude;
    _longitude = e.longitude;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _utiliserMaPosition() async {
    setState(() => _localisationEnCours = true);

    try {
      final serviceActif = await Geolocator.isLocationServiceEnabled();
      if (!serviceActif) {
        throw Exception('Activez la localisation sur votre appareil');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Permission de localisation refusée');
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '✅ Position récupérée : ${position.latitude.toStringAsFixed(5)}, '
              '${position.longitude.toStringAsFixed(5)}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $e')),
      );
    } finally {
      if (mounted) setState(() => _localisationEnCours = false);
    }
  }

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _enCours = true;
      _message = null;
    });

    try {
      final e = widget.etablissement;
      final maj = Etablissement(
        id: e.id,
        nom: _nomController.text.trim(),
        type: _type,
        description: _descriptionController.text.trim(),
        adresse: _adresseController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        categoriePrix: _categoriePrix,
        photoUrl: e.photoUrl,
        noteMoyenne: e.noteMoyenne,
        nombreAvis: e.nombreAvis,
        proprietaireId: e.proprietaireId,
      );

      await _service.mettreAJourEtablissement(maj);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _message = '❌ Erreur : $err';
        _enCours = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier mon établissement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomController,
                decoration:
                    const InputDecoration(labelText: 'Nom de l\'établissement'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nom requis' : null,
              ),
              //const SizedBox(height: 16),

              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _localisationEnCours ? null : _utiliserMaPosition,
                icon: _localisationEnCours
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_localisationEnCours
                    ? 'Localisation en cours...'
                    : 'Position mise à jour ✓ (touchez pour actualiser)'),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'restaurant', child: Text('Restaurant')),
                  DropdownMenuItem(value: 'fast-food', child: Text('Fast-food')),
                  DropdownMenuItem(value: 'maïga', child: Text('maïga (street food)')),
                ],
                onChanged: (v) => setState(() => _type = v!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
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
                initialValue: _categoriePrix,
                decoration: const InputDecoration(labelText: 'Catégorie de prix'),
                items: const [
                  DropdownMenuItem(value: 'FF', child: Text('FF — Économique')),
                  DropdownMenuItem(value: 'FFFF', child: Text('FFFF — Moyen')),
                  DropdownMenuItem(value: 'FFFFF', child: Text('FFFFF — Premium')),
                ],
                onChanged: (v) => setState(() => _categoriePrix = v!),
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