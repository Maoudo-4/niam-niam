import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/notifications_page.dart';
import '../services/notification_service.dart';

/// Cloche de la barre du haut, avec le nombre de notifications non lues.
class ClocheNotifications extends StatefulWidget {
  const ClocheNotifications({super.key});

  @override
  State<ClocheNotifications> createState() => _ClocheNotificationsState();
}

class _ClocheNotificationsState extends State<ClocheNotifications> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  // Le flux est créé une seule fois, pour ne pas se relancer à chaque rebuild
  late final Stream<int>? _nonLues =
      _uid == null ? null : NotificationService().nombreNonLues(_uid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _nonLues,
      builder: (context, snapshot) {
        final nombre = snapshot.data ?? 0;
        return IconButton(
          tooltip: 'Notifications',
          icon: Badge.count(
            count: nombre,
            isLabelVisible: nombre > 0,
            child: const Icon(Icons.notifications_none),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          ),
        );
      },
    );
  }
}