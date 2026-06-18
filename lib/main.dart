import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/onboarding/welcome_screen.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/main_screen.dart';
import 'screens/kolok/kolok_setup_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/auth_provider.dart';
import 'providers/kolok_provider.dart';

import 'providers/task_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/shopping_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const KolokApp(),
    ),
  );
}

class KolokApp extends StatelessWidget {
  const KolokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kolok',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF8F9FA),
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF2E3192)),
              titleTextStyle: TextStyle(
                color: Color(0xFF2E3192),
                fontWeight: FontWeight.w800,
                fontSize: 24,
                fontFamily: 'Gilroy',
              ),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              const TextTheme(
                displayLarge: TextStyle(fontWeight: FontWeight.w800, color: Colors.black), 
                bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: Colors.black87),    
              ),
            ),
            primaryColor: const Color(0xFF2E3192),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E3192),
              secondary: Color(0xFFD81B60),
              surface: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                fontFamily: 'Gilroy',
              ),
            ),
            textTheme: GoogleFonts.poppinsTextTheme(
              const TextTheme(
                displayLarge: TextStyle(fontWeight: FontWeight.w800, color: Colors.white), 
                bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: Colors.white70),    
              ),
            ).apply(bodyColor: Colors.white, displayColor: Colors.white),
            primaryColor: const Color(0xFF4C51F7),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4C51F7),
              secondary: Color(0xFFE8437D),
              surface: Color(0xFF1E1E1E),
            ),
          ),
          home: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAuthenticated) {
                if (authProvider.currentUser?.kolok == null) {
                  return const KolokSetupScreen();
                }
                return const MainScreen();
              } else {
                return const WelcomeScreen();
              }
            },
          ),
        );
      },
    );
  }
}