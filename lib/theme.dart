import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppColors {
  static const brunFonce = Color(0xFF0072CE); // bleu Sonic (structure, AppBar)
  static const terracotta = Color(0xFFE4002B); // rouge vif (CTA, boutons)
  static const vert = Color(0xFF2E7D32); // succès / livrée
  static const or = Color(0xFFFFB300); // accent doré
  static const creme = Color(0xFFFDFBF7); // fond quasi blanc
  static const brunTexte = Color(0xFF1A1A1A); // texte principal, presque noir
  static const brunClair = Color(0xFF6B6B6B); // texte secondaire, gris
  static const carte = Color(0xFFFFFFFF);
  static const bordure = Color(0xFFE0E0E0);
}

// Couleur associée à chaque statut, pour les badges
Color couleurStatut(String statut) {
  switch (statut) {
    case 'confirmee':
      return AppColors.or;
    case 'en_preparation':
      return AppColors.terracotta;
    case 'prete':
      return AppColors.vert;
    case 'livreur_assigne':
    case 'recuperee':
    case 'en_route':
      return AppColors.brunFonce; // bleu, "en cours"
    case 'livree':
      return AppColors.vert;
    default:
      return AppColors.brunClair;
  }
}

// Icône associée au type d'établissement, pour illustrer les plats
// à défaut d'avoir des photos.
IconData iconePourType(String type) {
  switch (type) {
    case 'restaurant':
      return Icons.restaurant;
    case 'fast-food':
      return Icons.lunch_dining;
    case 'maïga':
      return LucideIcons.cookingPot;
    default:
      return Icons.fastfood;
  }
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.creme,
    primaryColor: AppColors.brunFonce,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.brunFonce,
      primary: AppColors.brunFonce,
      secondary: AppColors.terracotta,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.brunFonce,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.carte,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bordure),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.brunTexte),
      titleLarge: TextStyle(color: AppColors.brunTexte, fontWeight: FontWeight.w600),
    ),
  );
}