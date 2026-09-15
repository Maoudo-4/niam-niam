import 'package:flutter/material.dart';
import '../../theme.dart';
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Détails de la commande',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brunTexte)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.carte,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.bordure),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description de la commande'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _montantController,
                      decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.carte,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.bordure),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total',
                          style: TextStyle(fontSize: 12, color: AppColors.brunClair)),
                      Text(
                        '${double.tryParse(_montantController.text)?.toStringAsFixed(0) ?? '0'} FCFA',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brunTexte),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 180,
                    child: _envoi
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _commander,
                            child: const Text('Payer (simulé)'),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}