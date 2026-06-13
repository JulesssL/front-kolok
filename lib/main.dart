import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding/welcome_screen.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/main_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/kolok_provider.dart';

import 'providers/task_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/shopping_provider.dart';
import 'providers/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => KolokProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const KolokApp(),
    ),
  );
}

class KolokApp extends StatelessWidget {
  const KolokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kolok',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          const TextTheme(
            displayLarge: TextStyle(fontWeight: FontWeight.w800), 
            bodyLarge: TextStyle(fontWeight: FontWeight.w400),    
          ),
        ),
        primaryColor: const Color(0xFF2E3192),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Si l'utilisateur est authentifié, on l'envoie sur MainScreen
          // Sinon sur WelcomeScreen
          if (authProvider.isAuthenticated) {
            return const MainScreen();
          } else {
            return const WelcomeScreen();
          }
        },
      ),
    );
  }
}