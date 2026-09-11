import 'package:flutter/material.dart';
import '../services/auth_service.dart';

Future<void> confirmerDeconnexion(BuildContext context) async {
  final confirme = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Se déconnecter ?'),
      content: const Text('Tu devras te reconnecter pour accéder à ton compte.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Se déconnecter', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirme == true) {
    await AuthService().deconnecter();
  }
}