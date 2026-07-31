import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../constants/bank_constants.dart';

class PaymentService {
  static Future<void> processPayment(BuildContext context, String bankId, String receiverIban) async {
    // 1. Copier l'IBAN dans le presse-papier
    await Clipboard.setData(ClipboardData(text: receiverIban));

    // 2. Afficher le SnackBar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("IBAN copié ! Ouverture de votre banque..."),
          backgroundColor: const Color(0xFF2E3192), // Couleur primaire
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // 3. Récupérer les infos de la banque
    final bankInfo = BankConstants.supportedBanks[bankId];
    if (bankInfo == null) {
      return; // "Autre" banque, on a juste copié l'IBAN.
    }

    // 4. Construire l'URI selon l'OS
    Uri? uriToLaunch;
    if (Platform.isAndroid) {
      uriToLaunch = Uri.parse('intent://${bankInfo.androidPackage}#Intent;scheme=android-app;package=${bankInfo.androidPackage};end');
    } else if (Platform.isIOS) {
      uriToLaunch = Uri.parse(bankInfo.iosUrlScheme);
    }

    if (uriToLaunch != null) {
      try {
        // Pour Android, intent:// n'est pas supporté par canLaunchUrl de la même façon que les schemes classiques
        // Donc on tente de lancer directement. Si on utilisait juste un custom scheme (ex: boursorama://) sur Android, on pourrait utiliser canLaunchUrl.
        if (Platform.isIOS) {
          final bool canLaunch = await canLaunchUrl(uriToLaunch);
          if (canLaunch) {
            await launchUrl(uriToLaunch, mode: LaunchMode.externalApplication);
          } else {
            // Si l'app n'est pas installée, on ouvre le fallback (site web)
            await launchUrl(Uri.parse(bankInfo.fallbackUrl), mode: LaunchMode.externalApplication);
          }
        } else if (Platform.isAndroid) {
          // Sur Android, on essaie d'abord avec un scheme plus classique si possible, ou on laisse le système gérer l'intent
          // L'approche intent:// fonctionne si on passe par le PackageManager. url_launcher peut parfois galérer.
          // Pour faire simple, on va utiliser la fallback URL si canLaunchUrl échoue sur le custom scheme natif
          
          // Approche simple: on tente de lancer le fallback si l'intent échoue.
          try {
             await launchUrl(uriToLaunch, mode: LaunchMode.externalApplication);
          } catch (e) {
             await launchUrl(Uri.parse(bankInfo.fallbackUrl), mode: LaunchMode.externalApplication);
          }
        }
      } catch (e) {
        debugPrint("Erreur lors de l'ouverture de la banque : $e");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: const Text("Impossible d'ouvrir l'application bancaire."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
