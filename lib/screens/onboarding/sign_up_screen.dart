import 'package:flutter/material.dart';
import '../../widgets/main_button_onboarding.dart';
import 'profile_setup_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileSetupScreen(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Inscription", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const Text("Créez votre compte pour commencer", style: TextStyle(color: Colors.grey)),
                  
                  const SizedBox(height: 40),

                  const Text("Email", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: "votre@email.com"),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text("Mot de passe", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: "••••••••"),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Le mot de passe doit faire au moins 8 caractères';
                      }
                      if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                        return 'Le mot de passe doit contenir une majuscule';
                      }
                      if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
                        return 'Le mot de passe doit contenir un chiffre';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text("Confirmer le mot de passe", style: TextStyle(fontWeight: FontWeight.bold)),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(hintText: "••••••••"),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  MainButton(
                    text: "S'INSCRIRE", 
                    onPressed: _submitForm,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}