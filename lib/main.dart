import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; 

void main() {
  runApp(const KolokApp());
}

class KolokApp extends StatelessWidget {
  const KolokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kolok',
      theme: ThemeData(
        fontFamily: 'Gilroy', 
        primaryColor: const Color(0xFF2E3192),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.w800), 
          bodyLarge: TextStyle(fontWeight: FontWeight.w400),    
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}