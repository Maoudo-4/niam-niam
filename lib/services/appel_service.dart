import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouvre l'application Téléphone avec le numéro prêt à être composé.
Future<void> appeler(BuildContext context, String numero) async {
  final propre = numero.replaceAll(RegExp(r'[^0-9+]'), '');

  void erreur(String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  if (propre.isEmpty) {
    erreur('Numéro du livreur indisponible');
    return;
  }

  try {
    final ouvert = await launchUrl(Uri(scheme: 'tel', path: propre));
    if (!ouvert) erreur("Impossible d'ouvrir l'application Téléphone");
  } catch (_) {
    erreur("Impossible d'ouvrir l'application Téléphone");
  }
}