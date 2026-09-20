import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/etablissement.dart';
import 'passer_commande.dart';

class FicheEtablissementScreen extends StatefulWidget {
  final Etablissement etablissement;

  const FicheEtablissementScreen({super.key, required this.etablissement});

  @override
  State<FicheEtablissementScreen> createState() =>
      _FicheEtablissementScreenState();
}

class _FicheEtablissementScreenState extends State<FicheEtablissementScreen> {
  bool _estClient = false;

  @override
  void initState() {
    super.initState();
    _chargerRole();
  }

  // Le bouton Commander n'est visible que pour les clients
  Future<void> _chargerRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!mounted) return;
      setState(() => _estClient = doc.data()?['role'] == 'client');
    } catch (_) {
      // Erreur réseau : on n'affiche simplement pas le bouton
    }
  }

  @override
  Widget build(BuildContext context) {
    final etablissement = widget.etablissement;

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

                  // Espace pour que le bouton flottant ne cache pas l'adresse
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _estClient
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PasserCommande(etablissement: etablissement),
                ),
              ),
              label: const Text('Commander'),
              icon: const Icon(Icons.shopping_cart),
            )
          : null,
    );
  }
}