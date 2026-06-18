import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/main_button_onboarding.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';

class InviteScreen extends StatelessWidget {
  final String joinCode;
  final String? kolokName;

  const InviteScreen({super.key, required this.joinCode, this.kolokName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Invitez votre équipe !",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              "Partagez ce code avec vos colocataires pour qu'ils rejoignent le foyer",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "Code d'invitation",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    joinCode,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E3192),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 5),
                      Text(
                        "Copier le code",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            MainButton(
              text: "PARTAGER LE LIEN D'INVITATION",
              onPressed: () {
                /* Logique de partage */
              },
            ),

            const SizedBox(height: 40),

            const Text(
              "Déjà dans la Kolok :",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 15),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade100),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  final user = authProvider.currentUser;
                  final userName = user?.name ?? "Inconnu";
                  final initial = userName.isNotEmpty ? userName[0].toUpperCase() : "?";
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2E3192),
                      child: Text(initial, style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "Vous (Administrateur)",
                      style: TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),

            const Spacer(),

            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  "PASSER À L'ACCUEIL",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
