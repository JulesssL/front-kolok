import 'package:flutter/material.dart';
import '../../widgets/main_button_onboarding.dart';
import 'sign_up_screen.dart'; 
import 'log_in_screen.dart'; 

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3192),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
        child: Column(
          children: [
            const Spacer(),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                'assets/images/logo_kolok_white.png',
                width: 150,
                height: 150,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'La KoloK sans prise de tête',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const Spacer(),

            MainButton(
              text: "S'INSCRIRE",
              color: Colors.white,
              textColor: const Color(0xFF2E3192),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogInScreen()),
                );
              },
              child: const Text(
                "J'ai déjà un compte",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
