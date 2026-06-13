import 'package:flutter/material.dart';
import '../../widgets/main_button_onboarding.dart';
import '../../services/kolok_service.dart';
import 'invite_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipController = TextEditingController();
  final _cityController = TextEditingController();

  final KolokService _kolokService = KolokService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _zipController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String fullAddress = "${_addressController.text.trim()}, ${_zipController.text.trim()} ${_cityController.text.trim()}";

      final kolokData = await _kolokService.createKolok(
        name: _nameController.text.trim(),
        address: fullAddress,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InviteScreen(
              joinCode: kolokData['joinCode'] ?? 'ERREUR', 
              kolokName: kolokData['name'],
            ),
          ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Où habitez-vous ?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text("Ces informations nous aideront à personnaliser votre expérience", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 30),

                  _buildLabelField("Nom de la Koloc *", "Ex: L'Appart des Potes", _nameController, isRequired: true),
                  const SizedBox(height: 20),
                  _buildLabelField("Adresse postale *", "12 rue des Lilas", _addressController, isRequired: true),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: _buildLabelField("Code postal *", "75001", _zipController, isRequired: true)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildLabelField("Ville *", "Paris", _cityController, isRequired: true)),
                    ],
                  ),

                  const SizedBox(height: 50),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF918EF4)))
                      : MainButton(
                          text: "CRÉER LE FOYER",
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

  Widget _buildLabelField(String label, String hint, TextEditingController controller, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Requis';
            }
            return null;
          },
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