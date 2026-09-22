import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Formulaire de changement de mot de passe.
/// Se ferme avec `true` quand le mot de passe est modifié.
class ChangerMotDePasseScreen extends StatefulWidget {
  const ChangerMotDePasseScreen({super.key});

  @override
  State<ChangerMotDePasseScreen> createState() =>
      _ChangerMotDePasseScreenState();
}

class _ChangerMotDePasseScreenState extends State<ChangerMotDePasseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actuelController = TextEditingController();
  final _nouveauController = TextEditingController();
  final _confirmationController = TextEditingController();

  bool _masquerActuel = true;
  bool _masquerNouveau = true;
  bool _masquerConfirmation = true;
  bool _enCours = false;
  String? _message;

  @override
  void dispose() {
    _actuelController.dispose();
    _nouveauController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  String _messageErreur(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mot de passe actuel incorrect';
      case 'weak-password':
        return 'Le nouveau mot de passe est trop faible';
      case 'too-many-requests':
        return 'Trop de tentatives, réessayez plus tard';
      case 'network-request-failed':
        return 'Pas de connexion internet';
      case 'requires-recent-login':
        return 'Reconnectez-vous puis réessayez';
      default:
        return 'Erreur : ${e.message ?? e.code}';
    }
  }

  Future<void> _changer() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      setState(() {
        _message = '❌ Ce compte n\'utilise pas de mot de passe';
      });
      return;
    }

    setState(() {
      _enCours = true;
      _message = null;
    });

    try {
      // Firebase exige une connexion récente : on revalide avec l'actuel
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _actuelController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(_nouveauController.text);

      if (!mounted) return;
      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _message = '❌ ${_messageErreur(e)}';
        _enCours = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = '❌ Erreur : $e';
        _enCours = false;
      });
    }
  }

  Widget _champ({
    required TextEditingController controller,
    required String label,
    required bool masque,
    required VoidCallback onBasculer,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: masque,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(masque ? Icons.visibility_off : Icons.visibility),
          onPressed: onBasculer,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer le mot de passe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _champ(
                controller: _actuelController,
                label: 'Mot de passe actuel',
                masque: _masquerActuel,
                onBasculer: () =>
                    setState(() => _masquerActuel = !_masquerActuel),
                validator: (v) => v == null || v.isEmpty
                    ? 'Mot de passe actuel requis'
                    : null,
              ),
              const SizedBox(height: 16),

              _champ(
                controller: _nouveauController,
                label: 'Nouveau mot de passe',
                masque: _masquerNouveau,
                onBasculer: () =>
                    setState(() => _masquerNouveau = !_masquerNouveau),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return 'Au moins 6 caractères';
                  }
                  if (v == _actuelController.text) {
                    return 'Doit être différent de l\'actuel';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _champ(
                controller: _confirmationController,
                label: 'Confirmer le nouveau mot de passe',
                masque: _masquerConfirmation,
                onBasculer: () => setState(
                    () => _masquerConfirmation = !_masquerConfirmation),
                validator: (v) => v != _nouveauController.text
                    ? 'Les mots de passe ne correspondent pas'
                    : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _enCours ? null : _changer,
                child: _enCours
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Changer le mot de passe'),
              ),

              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}