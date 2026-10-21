import 'package:url_launcher/url_launcher.dart';

/// Contact du support Niam-Niam via WhatsApp.
class SupportService {
  static const _numeroWhatsapp = '221766147477';

  /// Ouvre WhatsApp avec un message pré-rempli. Renvoie false si ça échoue.
  static Future<bool> contacterSupport() async {
    final message = Uri.encodeComponent(
        'Bonjour l\'équipe Niam-Niam, j\'ai besoin d\'aide.');
    final uri = Uri.parse('https://wa.me/$_numeroWhatsapp?text=$message');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}