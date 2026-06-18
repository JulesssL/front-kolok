import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/main_button_onboarding.dart';
import '../main_screen.dart';
import '../../providers/auth_provider.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isFormValid = false;

  void _validateForm() {
    setState(() {
      _isFormValid = _emailController.text.trim().isNotEmpty && 
                     _passwordController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().login(
          _emailController.text.trim(),
          _passwordController.text,
        );
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
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
                  const Text("Connexion", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const Text("Ravis de vous revoir", style: TextStyle(color: Colors.grey)),
                  
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
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text("Mot de passe oublié ?", style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  MainButton(
                    text: "SE CONNECTER", 
                    onPressed: _isFormValid ? _submitForm : null,
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
