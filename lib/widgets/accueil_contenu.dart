import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
        Row(
          children: [
            _CategoriePastille(
              icone: Icons.restaurant,
              label: 'Restaurant',
              couleur: const Color(0xFF0072CE), // bleu
              onTap: () => onVoirTout('restaurant'),
            ),
            const SizedBox(width: 12),
            _CategoriePastille(
              icone: Icons.lunch_dining,
              label: 'Fast-food',
              couleur: const Color(0xFFE8742A), // orange
              onTap: () => onVoirTout('fast-food'),
            ),
            const SizedBox(width: 12),
            _CategoriePastille(
              icone: LucideIcons.cookingPot,
              label: 'Maïga',
              couleur: const Color(0xFFE4202E), // rouge
              onTap: () => onVoirTout('maïga'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        SectionTop(
          titre: 'Top Restaurants',
          type: 'restaurant',
          messageVide: 'Aucun restaurant pour le moment',
          onVoirTout: () => onVoirTout('restaurant'),
        ),
        const SizedBox(height: 16),
        SectionTop(
          titre: 'Top Fast Food',
          type: 'fast-food',
          messageVide: 'Aucun fast-food pour le moment',
          onVoirTout: () => onVoirTout('fast-food'),
        ),
        const SizedBox(height: 16),
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
  final Color couleur;
  final VoidCallback onTap;
  const _CategoriePastille({
    required this.icone,
    required this.label,
    required this.couleur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: couleur.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, color: couleur, size: 26),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0072CE),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}