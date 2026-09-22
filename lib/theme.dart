import 'package:flutter/material.dart';

class AppColors {
  static const terracotta = Color(0xFFD8672D);
  static const vert = Color(0xFF1D9E75);
  static const or = Color(0xFFEF9F27);
  static const creme = Color(0xFFFBF3E7);
  static const brunTexte = Color(0xFF3C2415);
  static const brunClair = Color(0xFF7A5B45);
  static const carte = Color(0xFFFFFFFF);
  static const bordure = Color(0xFFE8DCC8);
}

// Couleur associée à chaque statut, pour les badges
Color couleurStatut(String statut) {
  switch (statut) {
    case 'confirmee':
      return AppColors.or;
    case 'en_preparation':
      return AppColors.terracotta;
    case 'livreur_assigne':
    case 'recuperee':
    case 'en_route':
      return const Color(0xFF3B82F6); // bleu, "en cours"
    case 'livree':
      return AppColors.vert;
    default:
      return AppColors.brunClair;
  }
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.creme,
    primaryColor: AppColors.terracotta,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.terracotta,
      primary: AppColors.terracotta,
      secondary: AppColors.vert,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.terracotta,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.vert,
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