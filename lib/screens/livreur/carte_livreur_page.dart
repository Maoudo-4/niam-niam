import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/commande.dart';
import '../../models/etablissement.dart';
import '../../services/livreur_service.dart';
import '../../services/etablissement_service.dart';
import '../../theme.dart';
import '../carte_etablissements_page.dart';

/// Un point affiché sur la carte du livreur : un resto ou un client.
class _PointCarte {
  final LatLng position;
  final String titre;
  final String details;
  final bool estClient;
  final IconData icone;
  _PointCarte({
    required this.position,
    required this.titre,
    required this.details,
    required this.estClient,
    required this.icone,
  });
}

class CarteLivreurPage extends StatefulWidget {
  /// Si renseigné, la carte n'affiche que cette commande.
  final String? commandeId;
  const CarteLivreurPage({super.key, this.commandeId});

  @override
  State<CarteLivreurPage> createState() => _CarteLivreurPageState();
}

class _CarteLivreurPageState extends State<CarteLivreurPage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  late final Stream<List<Commande>> _missions =
      LivreurService().mesMissions(_uid);
  late final Stream<List<Etablissement>> _etablissements =
      EtablissementService().getEtablissements();

  _PointCarte? _selectionne;

  bool _memePoint(_PointCarte? a, _PointCarte b) =>
      a != null && a.position == b.position && a.titre == b.titre;

  List<_PointCarte> _construirePoints(
      List<Commande> missions, List<Etablissement> etablissements) {
    final points = <_PointCarte>[];
    for (final c in missions) {
      if (c.statut == StatutCommande.enRoute) {
        // En route : on affiche le client
        if (c.latitudeLivraison == null || c.longitudeLivraison == null) {
          continue;
        }
        points.add(_PointCarte(
          position: LatLng(c.latitudeLivraison!, c.longitudeLivraison!),
          titre: 'Client à livrer',
          details: (c.repereLivraison?.isNotEmpty ?? false)
              ? 'Repère : ${c.repereLivraison}'
              : c.description,
          estClient: true,
          icone: Icons.home,
        ));
      } else {
        // Assignée ou récupérée : on affiche le resto
        final trouves =
            etablissements.where((e) => e.id == c.etablissementId);
        if (trouves.isEmpty) continue;
        final e = trouves.first;
        points.add(_PointCarte(
          position: LatLng(e.latitude, e.longitude),
          titre: e.nom,
          details: 'À récupérer : ${c.description}',
          estClient: false,
          icone: iconePourType(e.type),
        ));
      }
    }
    return points;
  }

  Widget _marqueur(_PointCarte p) {
    final selectionne = _memePoint(_selectionne, p);
    final couleur =
        p.estClient ? const Color(0xFF0072CE) : AppColors.terracotta;
    return Container(
      decoration: BoxDecoration(
        color: selectionne ? couleur : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: couleur, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
      child: Icon(p.icone,
          size: 16, color: selectionne ? Colors.white : couleur),
    );
  }

  Future<void> _ouvrirItineraire(LatLng p) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${p.latitude},${p.longitude}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir l\'itinéraire')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Commande>>(
      stream: _missions,
      builder: (context, snapMissions) {
        return StreamBuilder<List<Etablissement>>(
          stream: _etablissements,
          builder: (context, snapEtabs) {
            if (!snapMissions.hasData || !snapEtabs.hasData) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }

            final missions = widget.commandeId == null
                ? snapMissions.data!
                : snapMissions.data!
                    .where((c) => c.id == widget.commandeId)
                    .toList();
            final points = _construirePoints(missions, snapEtabs.data!);
            
            // Aucune mission : carte habituelle des restos à proximité
            if (points.isEmpty) return const CarteEtablissementsPage();

            final coords = points.map((p) => p.position).toList();

            return Scaffold(
              body: Stack(
                children: [
                  FlutterMap(
                    // Nouvelle clé = la carte se recadre quand les points changent
                    key: ValueKey(coords
                        .map((c) => '${c.latitude},${c.longitude}')
                        .join('|')),
                    options: MapOptions(
                      initialCameraFit: CameraFit.coordinates(
                        coordinates: coords,
                        padding: const EdgeInsets.all(80),
                        maxZoom: 16,
                      ),
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
                          for (final p in points)
                            Marker(
                              point: p.position,
                              width: 32,
                              height: 32,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectionne = p),
                                child: _marqueur(p),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Bouton retour
                  Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black87),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),

                  // Fiche du point sélectionné
                  if (_selectionne != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(24)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 12,
                                offset: Offset(0, -2)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectionne!.titre,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.brunTexte)),
                            const SizedBox(height: 4),
                            Text(_selectionne!.details,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.brunClair)),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _ouvrirItineraire(_selectionne!.position),
                                icon: const Icon(Icons.directions),
                                label: const Text('Ouvrir l\'itinéraire'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}