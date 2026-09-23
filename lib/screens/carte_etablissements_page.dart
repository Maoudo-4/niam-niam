import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/etablissement.dart';
import '../services/etablissement_service.dart';
import '../theme.dart';
import 'client/fiche_etablissement_screen.dart';

/// Carte des établissements autour du client, avec sa position et la distance.
class CarteEtablissementsPage extends StatefulWidget {
  const CarteEtablissementsPage({super.key});

  @override
  State<CarteEtablissementsPage> createState() =>
      _CarteEtablissementsPageState();
}

class _CarteEtablissementsPageState extends State<CarteEtablissementsPage> {
  final _mapController = MapController();
  Position? _position;
  String? _erreur;
  Etablissement? _selectionne;
  StreamSubscription<List<Etablissement>>? _etablissementsSub;
  List<Etablissement> _etablissements = [];

  @override
  void initState() {
    super.initState();
    _localiser();
    _etablissementsSub =
        EtablissementService().getEtablissements().listen((liste) {
      if (!mounted) return;
      setState(() {
        // Seulement ceux qui ont une vraie position
        _etablissements = liste
            .where((e) => e.latitude != 0.0 || e.longitude != 0.0)
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _etablissementsSub?.cancel();
    super.dispose();
  }

  Future<void> _localiser() async {
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
      setState(() => _position = position);
    } catch (e) {
      if (!mounted) return;
      setState(() => _erreur = '$e');
    }
  }

  String _distance(Etablissement e) {
    if (_position == null) return '';
    final metres = Geolocator.distanceBetween(
      _position!.latitude,
      _position!.longitude,
      e.latitude,
      e.longitude,
    );
    return metres < 1000
        ? '${metres.round()} m'
        : '${(metres / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    if (_erreur != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Autour de moi')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('❌ $_erreur', textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _erreur = null);
                    _localiser();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_position == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Autour de moi')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final moi = LatLng(_position!.latitude, _position!.longitude);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: moi,
              initialZoom: 14,
              onTap: (_, __) => setState(() => _selectionne = null),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.niamniam.app',
              ),
              MarkerLayer(
                markers: [
                  // Position du client
                  Marker(
                    point: moi,
                    width: 22,
                    height: 22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                  // Un marqueur par établissement
                  for (final e in _etablissements)
                    Marker(
                      point: LatLng(e.latitude, e.longitude),
                      width: 42,
                      height: 42,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectionne = e),
                        child: Icon(
                          Icons.location_on,
                          color: _selectionne?.id == e.id
                              ? AppColors.terracotta
                              : AppColors.brunTexte,
                          size: 42,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Bouton retour, flottant en haut à gauche
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // Fiche flottante de l'établissement sélectionné
          if (_selectionne != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _FicheFlottante(
                etablissement: _selectionne!,
                distance: _distance(_selectionne!),
                onVoir: () {
                  final e = _selectionne!;
                  setState(() => _selectionne = null);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FicheEtablissementScreen(etablissement: e),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Carte blanche à coins arrondis qui remonte du bas, comme un suivi de commande.
class _FicheFlottante extends StatelessWidget {
  final Etablissement etablissement;
  final String distance;
  final VoidCallback onVoir;
  const _FicheFlottante({
    required this.etablissement,
    required this.distance,
    required this.onVoir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant,
                    color: AppColors.terracotta, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(etablissement.nom,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brunTexte)),
                    const SizedBox(height: 2),
                    Text('${etablissement.type} • $distance',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.brunClair)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onVoir,
              child: const Text('Voir la fiche'),
            ),
          ),
        ],
      ),
    );
  }
}