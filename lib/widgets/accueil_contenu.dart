import 'package:flutter/material.dart';
import '../theme.dart';
import 'section_top.dart';

class AccueilContenu extends StatelessWidget {
  // Reçoit le type choisi ('restaurant', 'fast-food' ou 'maïga'),
  // depuis un « Voir tout » ou depuis une pastille de catégorie
  final ValueChanged<String> onVoirTout;
  const AccueilContenu({super.key, required this.onVoirTout});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Qu\'est-ce qu\'on mange aujourd\'hui ?',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.brunTexte)),
        const SizedBox(height: 20),

        const Text('Catégories',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.brunTexte)),
        const SizedBox(height: 12),
        Row(
          children: [
            _CategoriePastille(
              icone: Icons.restaurant,
              label: 'Restaurant',
              onTap: () => onVoirTout('restaurant'),
            ),
            const SizedBox(width: 12),
            _CategoriePastille(
              icone: Icons.lunch_dining,
              label: 'Fast-food',
              onTap: () => onVoirTout('fast-food'),
            ),
            const SizedBox(width: 12),
            _CategoriePastille(
              icone: Icons.storefront,
              label: 'Maïga',
              onTap: () => onVoirTout('maïga'),
            ),
          ],
        ),
        const SizedBox(height: 24),

        SectionTop(
          titre: 'Top Restaurants',
          type: 'restaurant',
          messageVide: 'Aucun restaurant pour le moment',
          onVoirTout: () => onVoirTout('restaurant'),
        ),
        const SizedBox(height: 28),
        SectionTop(
          titre: 'Top Fast Food',
          type: 'fast-food',
          messageVide: 'Aucun fast-food pour le moment',
          onVoirTout: () => onVoirTout('fast-food'),
        ),
        const SizedBox(height: 28),
        SectionTop(
          titre: 'Top Maïga',
          type: 'maïga',
          messageVide: 'Aucun maïga pour le moment',
          onVoirTout: () => onVoirTout('maïga'),
        ),    
      ],
    );
  }
}

class _CategoriePastille extends StatelessWidget {
  final IconData icone;
  final String label;
  final VoidCallback onTap;
  const _CategoriePastille({
    required this.icone,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final forme = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.bordure),
    );

    return Expanded(
      child: Material(
        color: AppColors.carte,
        shape: forme,
        child: InkWell(
          customBorder: forme,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(icone, color: AppColors.terracotta, size: 22),
                const SizedBox(height: 6),
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.brunTexte)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}