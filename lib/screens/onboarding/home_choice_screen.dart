import 'package:flutter/material.dart';
import 'package:kolok/screens/onboarding/address_screen.dart';
import 'join_kolok_screen.dart';

class HomeChoiceScreen extends StatelessWidget {
  const HomeChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choix du foyer", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text("Créez une nouvelle colocation ou rejoignez-en une existante", 
                       style: TextStyle(color: Colors.grey, fontSize: 14)),
            
            const SizedBox(height: 40),

            _choiceCard(
              icon: Icons.home_outlined,
              title: "Créer une nouvelle colocation",
              subtitle: "Commencez une nouvelle aventure",
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            _choiceCard(
              icon: Icons.group_outlined,
              title: "Rejoindre une colocation existante",
              subtitle: "Entrez le code d'invitation",
              onTap: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const JoinKolokScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _choiceCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF2E3192), size: 30),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}