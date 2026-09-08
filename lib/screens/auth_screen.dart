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
  String? _erreur;
  bool _chargement = false;

  Future<void> _soumettre() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    String? erreur;
    if (_modeInscription) {
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
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_erreur != null)
              Text(_erreur!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            _chargement
                ? const CircularProgressIndicator()
                : ElevatedButton(
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