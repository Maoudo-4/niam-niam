import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RoleScreen extends StatefulWidget {
  final String uid;
  const RoleScreen({super.key, required this.uid});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  final _authService = AuthService();
  bool _chargement = false;

  Future<void> _choisirRole(String role) async {
    setState(() => _chargement = true);
    await _authService.setRole(widget.uid, role);
    // Pas besoin de naviguer manuellement : main.dart va détecter
    // le changement de rôle et rediriger automatiquement.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choisis ton profil')),
      body: _chargement
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Comment veux-tu utiliser NIAM-NIAM ?',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _choisirRole('client'),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Je suis un client'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => _choisirRole('gerant'),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text("Je gère un établissement"),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => _choisirRole('livreur'),
                    child: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('Je suis livreur'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}