import 'package:flutter/material.dart';
import '../../widgets/main_button_onboarding.dart';
import '../../services/kolok_service.dart';
import '../main_screen.dart';

class JoinKolokScreen extends StatefulWidget {
  const JoinKolokScreen({super.key});

  @override
  State<JoinKolokScreen> createState() => _JoinKolokScreenState();
}

class _JoinKolokScreenState extends State<JoinKolokScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final KolokService _kolokService = KolokService();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _kolokService.joinKolok(_codeController.text.trim());

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
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Rejoindre une Kolok", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text("Entrez le code d'invitation partagé par vos colocataires", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 40),

                  const Text("Code d'invitation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _codeController,
                    validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
                    decoration: InputDecoration(
                      hintText: "Ex: AB12CD",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),

                  const Spacer(),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF918EF4)))
                      : MainButton(
                          text: "REJOINDRE",
                          color: const Color(0xFF918EF4),
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
