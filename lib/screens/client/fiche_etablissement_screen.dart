import 'package:flutter/material.dart';
import '../../models/etablissement.dart';

class FicheEtablissementScreen extends StatelessWidget {
  final Etablissement etablissement;

  const FicheEtablissementScreen({super.key, required this.etablissement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(etablissement.nom)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo (placeholder si pas encore d'image)
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: etablissement.photoUrl.isEmpty
                  ? const Icon(Icons.restaurant, size: 64, color: Colors.grey)
                  : Image.network(etablissement.photoUrl, fit: BoxFit.cover),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom + type
                  Text(
                    etablissement.nom,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${etablissement.type} • ${etablissement.categoriePrix}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  // Note
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${etablissement.noteMoyenne.toStringAsFixed(1)} (${etablissement.nombreAvis} avis)',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(etablissement.description,
                      style: const TextStyle(fontSize: 15)),

                  const SizedBox(height: 20),

                  // Adresse
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(etablissement.adresse)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bouton flottant pour la suite (commande/réservation - branche de Maoudo)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Maoudo branchera feature/commande ici
        },
        label: const Text('Commander'),
        icon: const Icon(Icons.shopping_cart),
      ),
    );
  }
}