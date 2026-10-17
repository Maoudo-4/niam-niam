import 'package:flutter/foundation.dart';

/// Vrai si l'utilisateur connecté est un client (seul rôle qui a des favoris).
/// Renseigné par la coque principale au démarrage.
final ValueNotifier<bool> estClientNotifier = ValueNotifier<bool>(false);