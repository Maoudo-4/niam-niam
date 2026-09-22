import 'package:flutter/material.dart';
import '../coque_principale.dart';

class AccueilLivreur extends StatelessWidget {
  const AccueilLivreur({super.key});

  @override
  Widget build(BuildContext context) {
    return const CoquePrincipale(role: RoleUtilisateur.livreur);
  }
}