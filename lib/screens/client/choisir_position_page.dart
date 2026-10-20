import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../theme.dart';

/// Le client place le pin sur son lieu de livraison.
/// Renvoie un [LatLng] via Navigator.pop.
class ChoisirPositionPage extends StatefulWidget {
  final LatLng? positionInitiale;
  const ChoisirPositionPage({super.key, this.positionInitiale});

  @override
  State<ChoisirPositionPage> createState() => _ChoisirPositionPageState();
}

class _ChoisirPositionPageState extends State<ChoisirPositionPage> {
  // Centre de repli si le GPS n'est pas disponible
  static const _centreParDefaut = LatLng(16.0179, -16.4896);

  final _mapController = MapController();
  late LatLng _centre;
  bool _localisation = false;

  @override
  void initState() {
    super.initState();
    _centre = widget.positionInitiale ?? _centreParDefaut;
  }

  Future<void> _utiliserMaPosition() async {
    setState(() => _localisation = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Activez la localisation sur votre appareil';
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw 'Permission refusée : placez le pin à la main sur la carte';
      }
      final p = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final pos = LatLng(p.latitude, p.longitude);
      _centre = pos;
      _mapController.move(pos, 17);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _localisation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _centre,
              initialZoom: 16,
              // Le pin est au centre : la position = le centre de la carte
              onPositionChanged: (camera, _) => _centre = camera.center,
              // Si on n'a pas de position de départ, on tente le GPS
              onMapReady: () {
                if (widget.positionInitiale == null) _utiliserMaPosition();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.niamniam.app',
              ),
            ],
          ),

          // Pin fixe au centre (la pointe est sur le centre exact)
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 42),
                child: Icon(Icons.location_on,
                    color: AppColors.terracotta, size: 42),
              ),
            ),
          ),

          // Bouton retour
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

          // Panneau du bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, -2)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Déplacez la carte pour placer le pin sur votre lieu de livraison',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.brunClair),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _localisation ? null : _utiliserMaPosition,
                      icon: _localisation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location),
                      label: const Text('Utiliser ma position'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _centre),
                      child: const Text('Confirmer cette position'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}