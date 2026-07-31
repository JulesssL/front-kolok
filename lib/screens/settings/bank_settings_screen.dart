import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../constants/bank_constants.dart';
import '../../widgets/main_button_onboarding.dart';

class BankSettingsScreen extends StatefulWidget {
  const BankSettingsScreen({super.key});

  @override
  State<BankSettingsScreen> createState() => _BankSettingsScreenState();
}

class _BankSettingsScreenState extends State<BankSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ibanController = TextEditingController();
  String? _selectedBankId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _ibanController.text = user.iban ?? '';
      if (user.preferredBank != null && BankConstants.supportedBanks.containsKey(user.preferredBank)) {
        _selectedBankId = user.preferredBank;
      }
    }
  }

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().updateProfile(
        iban: _ibanController.text.trim(),
        preferredBank: _selectedBankId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informations sauvegardées avec succès')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Informations Bancaires'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Remboursements P2P",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Configurez ces informations pour que vos colocataires puissent vous rembourser en 1 clic via leur application bancaire.",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              const Text("Votre IBAN", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ibanController,
                decoration: InputDecoration(
                  hintText: "FR76 ...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 15) {
                    return 'L\'IBAN semble invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text("Votre Banque (optionnel)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBankId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                hint: const Text('Sélectionnez votre banque'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Autre / Non listée')),
                  ...BankConstants.supportedBanks.values.map((bank) {
                    return DropdownMenuItem(
                      value: bank.id,
                      child: Text(bank.displayName),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBankId = value;
                  });
                },
              ),
              const SizedBox(height: 48),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : MainButton(
                      text: "SAUVEGARDER",
                      onPressed: _saveSettings,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
