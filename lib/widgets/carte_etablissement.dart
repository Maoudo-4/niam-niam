import 'package:flutter/material.dart';
import '../models/etablissement.dart';
import '../theme.dart';
import '../screens/client/fiche_etablissement_screen.dart';

class CarteEtablissement extends StatelessWidget {
  final Etablissement etablissement;
  const CarteEtablissement({super.key, required this.etablissement});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FicheEtablissementScreen(etablissement: etablissement),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.carte,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.bordure),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: const BoxDecoration(
                color: AppColors.creme,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: etablissement.photoUrl.isEmpty
                  ? const Icon(Icons.restaurant, color: AppColors.terracotta, size: 32)
                  : ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(etablissement.photoUrl,
                          fit: BoxFit.cover, width: double.infinity),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(etablissement.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.brunTexte)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.or, size: 14),
                      const SizedBox(width: 3),
                      Text(etablissement.noteMoyenne.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, color: AppColors.brunClair)),
                    ],
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