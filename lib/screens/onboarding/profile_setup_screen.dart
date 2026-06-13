import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/main_button_onboarding.dart';
import '../../providers/auth_provider.dart';
import 'home_choice_screen.dart'; 

class ProfileSetupScreen extends StatefulWidget {
  final String email;
  final String password;

  const ProfileSetupScreen({super.key, required this.email, required this.password});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; 
    });

    try {
      String fullName = "${_prenomController.text.trim()} ${_nomController.text.trim()}";

      await context.read<AuthProvider>().register(
        fullName,
        widget.email,
        widget.password,
      );

      await context.read<AuthProvider>().login(
        widget.email,
        widget.password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeChoiceScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; 
        });
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
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Faisons connaissance", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text("Ces informations seront visibles par vos colocataires", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  
                  const SizedBox(height: 40),

                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          child: Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey.shade400),
                        ),
                        Container(
                          height: 35, width: 35,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E3192),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  _buildInputField("Prénom *", "Jean", _prenomController),
                  const SizedBox(height: 20),
                  _buildInputField("Nom *", "Dupont", _nomController),

                  const SizedBox(height: 50),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF918EF4)))
                      : MainButton(
                          text: "SUIVANT",
                          color: const Color(0xFF918EF4),
                          onPressed: _registerUser, 
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}