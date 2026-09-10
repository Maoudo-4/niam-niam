import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/commande_service.dart';
import 'suivi_commande.dart';

class PasserCommande extends StatefulWidget {
  const PasserCommande({super.key});

  @override
  State<PasserCommande> createState() => _PasserCommandeState();
}

class _PasserCommandeState extends State<PasserCommande> {
  final _service = CommandeService();
  final _descriptionController = TextEditingController(text: 'Thiéboudienne x1');
  final _montantController = TextEditingController(text: '2500');
  bool _envoi = false;

  Future<void> _commander() async {
    setState(() => _envoi = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final commandeId = await _service.creerCommande(
      clientId: uid,
      etablissementId: 'etablissement_test', // en dur pour l'instant
      description: _descriptionController.text.trim(),
      montant: double.tryParse(_montantController.text) ?? 0,
    );

    setState(() => _envoi = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SuiviCommande(commandeId: commandeId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passer une commande')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description de la commande'),
            ),
            TextField(
              controller: _montantController,
              decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            _envoi
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _commander,
                    child: const Text('Confirmer et payer (simulé)'),
                  ),
          ],
        ),
      ),
    );
  }
}