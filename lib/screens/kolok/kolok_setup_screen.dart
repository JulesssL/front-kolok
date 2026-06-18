import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/kolok_provider.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';

class KolokSetupScreen extends StatefulWidget {
  const KolokSetupScreen({super.key});

  @override
  State<KolokSetupScreen> createState() => _KolokSetupScreenState();
}

class _KolokSetupScreenState extends State<KolokSetupScreen> {
  final _createNameController = TextEditingController();
  final _createAddressController = TextEditingController();
  final _joinCodeController = TextEditingController();

  bool _isCreating = true; // true: create mode, false: join mode

  void _submit() async {
    final kolokProv = context.read<KolokProvider>();
    final authProv = context.read<AuthProvider>();

    try {
      if (_isCreating) {
        if (_createNameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le nom est requis.')));
          return;
        }
        await kolokProv.createKolok(
          _createNameController.text.trim(),
          address: _createAddressController.text.trim().isEmpty ? null : _createAddressController.text.trim(),
        );
      } else {
        if (_joinCodeController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le code est requis.')));
          return;
        }
        await kolokProv.joinKolok(_joinCodeController.text.trim());
      }
      
      // Reload user profile to get the new Kolok relation
      await authProv.checkAuthStatus();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Bienvenue dans Kolok"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Tu y es presque !",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Pour commencer, tu dois créer une colocation ou en rejoindre une existante.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isCreating = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCreating ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                      foregroundColor: _isCreating ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Créer"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isCreating = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isCreating ? Theme.of(context).colorScheme.primary : Colors.grey.shade200,
                      foregroundColor: !_isCreating ? Colors.white : Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Rejoindre"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (_isCreating) ...[
              TextField(
                controller: _createNameController,
                decoration: InputDecoration(
                  labelText: "Nom de la colocation",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _createAddressController,
                decoration: InputDecoration(
                  labelText: "Adresse (optionnelle)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.location_on),
                ),
              ),
            ] else ...[
              TextField(
                controller: _joinCodeController,
                decoration: InputDecoration(
                  labelText: "Code d'invitation",
                  hintText: "Ex: K-ABCD",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.vpn_key),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Demande le code à un membre de la colocation pour pouvoir la rejoindre.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 48),
            Consumer<KolokProvider>(
              builder: (context, kolokProv, child) {
                return ElevatedButton(
                  onPressed: kolokProv.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: kolokProv.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _isCreating ? "CRÉER LA COLOCATION" : "REJOINDRE",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _createNameController.dispose();
    _createAddressController.dispose();
    _joinCodeController.dispose();
    super.dispose();
  }
}
