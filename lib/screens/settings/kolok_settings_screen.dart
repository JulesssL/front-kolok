import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class KolokSettingsScreen extends StatefulWidget {
  const KolokSettingsScreen({super.key});

  @override
  State<KolokSettingsScreen> createState() => _KolokSettingsScreenState();
}

class _KolokSettingsScreenState extends State<KolokSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user?.kolok != null) {
        _nameController.text = user!.kolok!.name;
        _addressController.text = user.kolok!.address;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveKolok() async {
    final authProv = context.read<AuthProvider>();
    final kolokId = authProv.currentUser?.kolok?.id;
    if (kolokId == null) return;

    try {
      await authProv.updateKolokInfo(kolokId, _nameController.text, _addressController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informations mises à jour')),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Ma Kolok",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            fontFamily: 'Gilroy',
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: _saveKolok,
            )
          else
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProv, child) {
          final kolok = authProv.currentUser?.kolok;
          if (kolok == null) {
            return const Center(child: Text("Vous n'êtes dans aucune colocation"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle("Informations Générales"),
                const SizedBox(height: 16),
                _buildTextField("Nom de la Kolok", _nameController, _isEditing),
                const SizedBox(height: 16),
                _buildTextField("Adresse", _addressController, _isEditing, maxLines: 2),
                const SizedBox(height: 32),
                
                _buildSectionTitle("Code d'invitation"),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        kolok.joinCode,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: kolok.joinCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Code copié dans le presse-papier')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildSectionTitle("Membres"),
                const SizedBox(height: 16),
                if (kolok.users != null && kolok.users!.isNotEmpty)
                  ...kolok.users!.map((u) {
                    final initial = u.name.isNotEmpty ? u.name[0].toUpperCase() : '?';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: u.avatarUrl != null && u.avatarUrl!.isNotEmpty
                            ? CachedNetworkImageProvider(u.avatarUrl!)
                            : null,
                        child: u.avatarUrl == null || u.avatarUrl!.isEmpty
                            ? Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(u.email),
                    );
                  }).toList()
                else
                  const Text("Impossible de charger les membres."),
                  
                const SizedBox(height: 48),
                if (authProv.isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isEnabled, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      enabled: isEnabled,
      maxLines: maxLines,
      style: TextStyle(
        color: isEnabled ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isEnabled ? Theme.of(context).colorScheme.surface : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
