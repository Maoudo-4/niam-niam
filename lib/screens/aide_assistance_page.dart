import 'package:flutter/material.dart';
import '../services/support_service.dart';
import '../theme.dart';

class AideAssistancePage extends StatelessWidget {
  const AideAssistancePage({super.key});

  Future<void> _contacter(BuildContext context) async {
    final ok = await SupportService.contacterSupport();
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aide et assistance')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // À propos : se déroule quand on appuie dessus
          Container(
            decoration: BoxDecoration(
              color: AppColors.carte,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.bordure),
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              // supprime les traits que l'ExpansionTile ajoute par défaut
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: const ExpansionTile(
                leading: Icon(Icons.info_outline, color: AppColors.terracotta),
                title: Text(
                  'À propos',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.brunTexte,
                  ),
                ),
                childrenPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Niam-Niam est une application qui met en relation les '
                    'clients, les gérants d\'établissements et les livreurs.\n\n'
                    'Les clients découvrent les restaurants, fast-foods et '
                    'maïgas autour d\'eux, commandent leurs plats et suivent '
                    'leur livraison. Les gérants présentent leur établissement '
                    'et traitent les commandes. Les livreurs prennent en charge '
                    'les commandes et les livrent jusqu\'au client.\n\n'
                    'Projet réalisé dans le cadre de la Licence 3 Informatique '
                    'de l\'Université Gaston Berger de Saint-Louis.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.brunClair,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Une question ou un problème ?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.brunTexte,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Contactez-nous directement sur WhatsApp, nous vous répondrons dès que possible.',
            style: TextStyle(fontSize: 13, color: AppColors.brunClair),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _contacter(context),
              icon: const Icon(Icons.chat),
              label: const Text('Nous contacter sur WhatsApp'),
            ),
          ),
        ],
      ),
    );
  }
}