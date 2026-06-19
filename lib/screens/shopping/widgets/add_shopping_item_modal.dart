import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/shopping_provider.dart';

class AddShoppingItemModal extends StatefulWidget {
  const AddShoppingItemModal({super.key});

  @override
  State<AddShoppingItemModal> createState() => _AddShoppingItemModalState();
}

class _AddShoppingItemModalState extends State<AddShoppingItemModal> {
  final List<String> _pendingItems = [];
  final TextEditingController _localController = TextEditingController();

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  Future<void> _addItems(String input) async {
    if (input.trim().isEmpty) return;
    final items = input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    for (final item in items) {
      try {
        await context.read<ShoppingProvider>().createItem(item, null);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  void _addPendingItem() {
    final text = _localController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _pendingItems.add(text);
      });
      _localController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ajouter des articles",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _localController,
            onSubmitted: (_) => _addPendingItem(),
            decoration: InputDecoration(
              labelText: "Nom de l'article",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle),
                color: Theme.of(context).colorScheme.primary,
                onPressed: _addPendingItem,
              ),
            ),
          ),
          if (_pendingItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _pendingItems.asMap().entries.map((entry) {
                final idx = entry.key;
                final val = entry.value;
                return Chip(
                  label: Text(val),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _pendingItems.removeAt(idx);
                    });
                  },
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("ANNULER", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _addPendingItem(); // Add any remaining text in the field
                    if (_pendingItems.isNotEmpty) {
                      for (final item in _pendingItems) {
                        _addItems(item); // splits by comma internally
                      }
                    }
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3192),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("VALIDER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
