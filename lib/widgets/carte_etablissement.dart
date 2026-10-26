import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/etablissement.dart';
import '../services/favoris_service.dart';
import '../theme.dart';
import '../screens/client/fiche_etablissement_screen.dart';
import '../services/role_actuel.dart';

class CarteEtablissement extends StatelessWidget {
  final Etablissement etablissement;
  const CarteEtablissement({super.key, required this.etablissement});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final couleur = couleurPourType(etablissement.type);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                FicheEtablissementScreen(etablissement: etablissement),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.carte,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bordure),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: etablissement.photoUrl.isEmpty
                        ? Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: couleur.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(iconePourType(etablissement.type),
                                color: couleur, size: 22),
                          )
                        : ClipOval(
                            child: Image.network(etablissement.photoUrl,
                                fit: BoxFit.cover, width: 40, height: 40),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(etablissement.nom,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brunTexte)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.or, size: 14),
                      const SizedBox(width: 3),
                      Text(etablissement.noteMoyenne.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.brunClair)),
                      const Spacer(),
                      Text(etablissement.categoriePrix,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.brunTexte)),
                    ],
                  ),
                ],
              ),
            ),
            if (uid != null && estClientNotifier.value)
              Positioned(
                top: 2,
                right: 2,
                child: StreamBuilder<Set<String>>(
                  stream: FavorisService().favorisDuClient(uid),
                  builder: (context, snap) {
                    final favoris = snap.data ?? {};
                    final estFavori = favoris.contains(etablissement.id);
                    return GestureDetector(
                      onTap: () => FavorisService().basculer(
                        uid,
                        etablissement.id,
                        dejaFavori: estFavori,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          estFavori ? Icons.favorite : Icons.favorite_border,
                          color: estFavori
                              ? AppColors.terracotta
                              : AppColors.brunClair,
                          size: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Couleur associée à chaque type d'établissement.
Color couleurPourType(String type) {
  switch (type) {
    case 'fast-food':
      return const Color(0xFFE8742A); // orange
    case 'maïga':
      return const Color(0xFFE4202E); // rouge
    default:
      return const Color(0xFF0072CE); // bleu (restaurant)
  }
}