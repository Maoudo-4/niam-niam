import 'package:flutter/material.dart';
import '../theme.dart';

/// Ce que renvoie la fenêtre quand le client envoie son avis.
class ResultatNotation {
  final int note; // de 1 à 5
  final String commentaire; // peut être vide
  ResultatNotation(this.note, this.commentaire);
}

/// Ouvre la fenêtre de notation. Renvoie null si le client annule.
Future<ResultatNotation?> afficherDialogNotation(
  BuildContext context, {
  required String nomEtablissement,
}) {
  return showDialog<ResultatNotation>(
    context: context,
    builder: (_) => _DialogNotation(nomEtablissement: nomEtablissement),
  );
}

class _DialogNotation extends StatefulWidget {
  final String nomEtablissement;
  const _DialogNotation({required this.nomEtablissement});

  @override
  State<_DialogNotation> createState() => _DialogNotationState();
}

class _DialogNotationState extends State<_DialogNotation> {
  static const _libelles = [
    '',
    'Mauvais',
    'Passable',
    'Bien',
    'Très bien',
    'Excellent',
  ];

  final _commentaireController = TextEditingController();
  int _note = 0;

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Votre avis'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.nomEtablissement,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brunTexte),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return IconButton(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    i < _note ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 34,
                  ),
                  onPressed: () => setState(() => _note = i + 1),
                );
              }),
            ),
            const SizedBox(height: 4),
            Text(
              _libelles[_note],
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.brunClair),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentaireController,
              maxLines: 3,
              maxLength: 200,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Commentaire (facultatif)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _note == 0
              ? null
              : () => Navigator.pop(
                    context,
                    ResultatNotation(
                        _note, _commentaireController.text.trim()),
                  ),
          child: const Text('Envoyer'),
        ),
      ],
    );
  }
}