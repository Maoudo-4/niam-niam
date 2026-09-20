import 'package:flutter/material.dart';
import '../models/etablissement.dart';
import '../services/etablissement_service.dart';
import '../theme.dart';
import 'carte_etablissement.dart';

class SectionTop extends StatelessWidget {
  final String titre;
  final String type; // 'restaurant', 'fast-food', ...
  final String messageVide;
  final VoidCallback onVoirTout;

  const SectionTop({
    super.key,
    required this.titre,
    required this.type,
    required this.messageVide,
    required this.onVoirTout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(titre,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brunTexte)),
            GestureDetector(
              onTap: onVoirTout,
              child: const Text('Voir tout',
                  style: TextStyle(fontSize: 13, color: AppColors.vert)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: StreamBuilder<List<Etablissement>>(
            stream: EtablissementService().getEtablissements(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final liste =
                  snapshot.data!.where((e) => e.type == type).toList();
              if (liste.isEmpty) {
                return Center(child: Text(messageVide));
              }
              return ListView(
                scrollDirection: Axis.horizontal,
                children: liste
                    .map((e) => CarteEtablissement(etablissement: e))
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}