import 'package:flutter/material.dart';
import '../widgets/main_button_onboarding.dart';
import 'home_choice_screen.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

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
            const Text("Où habitez-vous ?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text("Ces informations nous aideront à personnaliser votre expérience", 
                       style: TextStyle(color: Colors.grey, fontSize: 14)),
            
            const SizedBox(height: 30),

            _buildLabelField("Nom de la Koloc *", "Ex: L'Appart des Potes"),
            const SizedBox(height: 20),
            _buildLabelField("Adresse postale *", "12 rue des Lilas"),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _buildLabelField("Code postal *", "75001")),
                const SizedBox(width: 15), // Espace entre les deux
                Expanded(child: _buildLabelField("Ville *", "Paris")),
              ],
            ),

            const Spacer(),

            MainButton(
              text: "CRÉER LE FOYER",
              color: const Color(0xFF918EF4),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeChoiceScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }
}