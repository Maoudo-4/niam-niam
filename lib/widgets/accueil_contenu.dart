import 'package:flutter/material.dart';
import '../theme.dart';
import 'section_top.dart';

class AccueilContenu extends StatelessWidget {
  // Reçoit le type de la section dont on a cliqué « Voir tout » ('restaurant' ou 'fast-food')
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
        const Row(
          children: [
            _CategoriePastille(icone: Icons.restaurant, label: 'Restaurant'),
            SizedBox(width: 12),
            _CategoriePastille(icone: Icons.lunch_dining, label: 'Fast-food'),
            SizedBox(width: 12),
            _CategoriePastille(icone: Icons.storefront, label: 'Maïga'),
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
      ],
    );
  }
}

class _CategoriePastille extends StatelessWidget {
  final IconData icone;
  final String label;
  const _CategoriePastille({required this.icone, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.carte,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.bordure),
        ),
        child: Column(
          children: [
            Icon(icone, color: AppColors.terracotta, size: 22),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.brunTexte)),
          ],
        ),
      ),
    );
  }
}