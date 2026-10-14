import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();

  bool _modeInscription = false;
  bool _motDePasseCache = true;
  String? _erreur;
  bool _chargement = false;

  Future<void> _soumettre() async {
    if (!mounted) return;
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    String? erreur;
    if (_modeInscription)  {
      erreur = await _authService.inscrire(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nomController.text.trim(),
      );
    } else {
      erreur = await _authService.connecter(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() {
      _chargement = false;
      _erreur = erreur;
    });
    // Si pas d'erreur, le StreamBuilder dans main.dart redirige automatiquement
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_modeInscription ? 'Inscription' : 'Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_modeInscription)
              TextField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16), // marge entre email et mot de passe
            TextField(
              controller: _passwordController,
              obscureText: _motDePasseCache,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                suffixIcon: IconButton(
                  icon: Icon(
                    _motDePasseCache ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _motDePasseCache = !_motDePasseCache),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_erreur != null)
              Text(_erreur!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            _chargement
                ? const CircularProgressIndicator()
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0072CE), // bleu de la barre du haut
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _soumettre,
                    child: Text(_modeInscription ? "S'inscrire" : 'Se connecter'),
                  ),
            TextButton(
              onPressed: () => setState(() => _modeInscription = !_modeInscription),
              child: Text(_modeInscription
                  ? 'Déjà un compte ? Se connecter'
                  : "Pas de compte ? S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}