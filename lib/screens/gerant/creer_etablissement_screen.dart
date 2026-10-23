import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/etablissement.dart';
import '../../services/etablissement_service.dart';
import 'package:geolocator/geolocator.dart';

class CreerEtablissementScreen extends StatefulWidget {
  final VoidCallback? onEtablissementCree;
  const CreerEtablissementScreen({super.key, this.onEtablissementCree});

  @override
  State<CreerEtablissementScreen> createState() =>
      _CreerEtablissementScreenState();
}

class _CreerEtablissementScreenState
  extends State<CreerEtablissementScreen> {
  final _formKey = GlobalKey<FormState>();
  final EtablissementService _service = EtablissementService();

  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _adresseController = TextEditingController();

  String _type = 'restaurant';
  String _categoriePrix = 'FF';
  double? _latitude;
  double? _longitude;
  bool _localisationEnCours = false;
  bool _enCours = false;
  String? _message;

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
      // Vérifie que la localisation est activée sur l'appareil
      final serviceActif = await Geolocator.isLocationServiceEnabled();
      if (!serviceActif) {
        throw Exception('Activez la localisation sur votre appareil');
      }

      // Vérifie/demande la permission
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _message = '❌ $e');
    } finally {
      if (mounted) setState(() => _localisationEnCours = false);
    }
  }

  Future<void> _creerEtablissement() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _message = '❌ Vous devez être connecté pour créer un établissement';
      });
      return;
    }

    setState(() {
      _enCours = true;
      _message = null;
    });

    try {
      final etablissement = Etablissement(
        id: '',
        nom: _nomController.text.trim(),
        type: _type,
        description: _descriptionController.text.trim(),
        adresse: _adresseController.text.trim(),
        latitude: _latitude ?? 0.0,
        longitude: _longitude ?? 0.0,
        categoriePrix: _categoriePrix,
        photoUrl: '',
        proprietaireId: uid,
      );

      await _service.ajouterEtablissement(etablissement);

      setState(() {
        _message = '✅ Établissement créé avec succès !';
      });
      widget.onEtablissementCree?.call();
    } catch (e) {
      setState(() {
        _message = '❌ Erreur : $e';
      });
    } finally {
      setState(() {
        _enCours = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer mon établissement')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom de l\'établissement'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: 12),

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
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _adresseController,
                decoration: const InputDecoration(labelText: 'Adresse'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Adresse requise' : null,
              ),
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
                label: Text(_latitude == null
                    ? 'Utiliser ma position actuelle'
                    : 'Position enregistrée ✓'),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _categoriePrix,
                decoration: const InputDecoration(labelText: 'Catégorie de prix'),
                items: const [
                  DropdownMenuItem(value: 'F', child: Text('F — Économique')),
                  DropdownMenuItem(value: 'FF', child: Text('FF — Moyen')),
                  DropdownMenuItem(value: 'FFF', child: Text('FFF — Premium')),
                ],
                onChanged: (v) => setState(() => _categoriePrix = v!),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _enCours ? null : _creerEtablissement,
                child: _enCours
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Créer l\'établissement'),
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