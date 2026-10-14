import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
import '../theme.dart';
import 'client/suivi_commande.dart';

/// Liste des notifications de l'utilisateur connecté.
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _service = NotificationService();
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  late final Stream<List<AppNotification>>? _notifications =
      _uid == null ? null : _service.mesNotifications(_uid);

  bool _estClient = false;

  @override
  void initState() {
    super.initState();
    _chargerRole();
  }

  // Seul le client peut ouvrir le suivi d'une commande depuis une notification
  Future<void> _chargerRole() async {
    if (_uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();
      if (!mounted) return;
      setState(() => _estClient = doc.data()?['role'] == 'client');
    } catch (_) {
      // Erreur réseau : les notifications restent consultables
    }
  }

  Future<void> _ouvrir(AppNotification n) async {
    if (!n.lue) {
      try {
        await _service.marquerCommeLue(n.id);
      } catch (_) {}
    }
    if (!mounted) return;
    if (_estClient && n.commandeId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SuiviCommande(commandeId: n.commandeId!),
        ),
      );
    }
  }

  String _date(DateTime d) {
    String deux(int v) => v.toString().padLeft(2, '0');
    return '${deux(d.day)}/${deux(d.month)} • ${deux(d.hour)}:${deux(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Tout marquer comme lu',
            icon: const Icon(Icons.done_all),
            onPressed: _uid == null
                ? null
                : () => _service.toutMarquerCommeLu(_uid),
          ),
        ],
      ),
      body: _notifications == null
          ? const Center(child: Text('Vous devez être connecté'))
          : StreamBuilder<List<AppNotification>>(
              stream: _notifications,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final liste = snapshot.data!;
                if (liste.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aucune notification pour le moment.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: liste.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _CarteNotification(
                    notification: liste[i],
                    date: _date(liste[i].createdAt),
                    onTap: () => _ouvrir(liste[i]),
                  ),
                );
              },
            ),
    );
  }
}

/// Une notification : icône, titre, message, date, point si non lue.
class _CarteNotification extends StatelessWidget {
  final AppNotification notification;
  final String date;
  final VoidCallback onTap;
  const _CarteNotification({
    required this.notification,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final forme = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppColors.bordure),
    );

    return Material(
      color: AppColors.carte,
      shape: forme,
      child: InkWell(
        customBorder: forme,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notification.lue
                      ? Icons.notifications_none
                      : Icons.notifications_active,
                  color: AppColors.terracotta,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.titre,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.lue
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: AppColors.brunTexte,
                            ),
                          ),
                        ),
                        if (!notification.lue)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppColors.terracotta,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notification.message,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.brunTexte)),
                    const SizedBox(height: 6),
                    Text(date,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.brunClair)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}