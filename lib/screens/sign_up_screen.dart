import 'package:flutter/material.dart';
import '../widgets/main_button_onboarding.dart';
import 'profile_setup_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Inscription",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Créez votre compte pour commencer",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            _socialButton("Continuer avec Apple", Icons.apple, Colors.black),
            const SizedBox(height: 15),
            _socialButton(
              "Continuer avec Google",
              Icons.g_mobiledata,
              Colors.white,
              textColor: Colors.black,
              border: true,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text("ou", style: TextStyle(color: Colors.grey)),
              ),
            ),

            const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
            const TextField(
              decoration: InputDecoration(hintText: "votre@email.com"),
            ),

            const SizedBox(height: 20),

            const Text(
              "Mot de passe",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: "••••••"),
            ),

            const SizedBox(height: 40),

            MainButton(
              text: "S'INSCRIRE",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSetupScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(
    String text,
    IconData icon,
    Color bg, {
    Color textColor = Colors.white,
    bool border = false,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(25),
        border: border ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
