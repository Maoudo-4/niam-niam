import 'package:flutter/material.dart';
import '../coque_principale.dart';

class AccueilClient extends StatelessWidget {
  const AccueilClient({super.key});

  @override
  Widget build(BuildContext context) {
    return const CoquePrincipale(role: RoleUtilisateur.client);
  }
}