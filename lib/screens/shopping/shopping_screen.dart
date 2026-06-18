import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shopping_provider.dart';
import '../../providers/expense_provider.dart';
import '../settings/settings_screen.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  final TextEditingController _itemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ShoppingProvider>().fetchItems();
      }
    });
  }

  @override
  void dispose() {
    _itemController.dispose();
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
    _itemController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "KOLOK",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            fontFamily: 'Gilroy',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary, size: 28),
            onPressed: () => _showAddItemsModal(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                child: Icon(Icons.person_outline, color: Colors.grey.shade700),
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ShoppingProvider>().fetchItems(),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Liste collaborative",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Consumer<ShoppingProvider>(
                    builder: (context, prov, child) => Text(
                      "${prov.items.length} articles",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<ShoppingProvider>(
                builder: (context, shoppingProv, child) {
                  if (shoppingProv.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (shoppingProv.items.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text("La liste est vide")),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
                    itemCount: shoppingProv.items.length,
                    itemBuilder: (context, index) {
                      final item = shoppingProv.items[index];
                      final authorInitial = item.createdBy?.name.isNotEmpty == true 
                          ? item.createdBy!.name[0].toUpperCase() 
                          : "?";
                      
                      return _buildShoppingItem(
                        item.name,
                        authorInitial,
                        item.createdBy?.avatarUrl,
                        item.isBought,
                        (value) {
                          if (value != null) {
                            shoppingProv.toggleItem(item.id, value);
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Consumer<ShoppingProvider>(
          builder: (context, shoppingProv, child) {
            final hasBoughtItems = shoppingProv.items.any((item) => item.isBought);
            return ElevatedButton.icon(
              onPressed: hasBoughtItems ? () => _showConvertModal(context) : null,
              icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
              label: const Text(
                "CONVERTIR EN DÉPENSE",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasBoughtItems ? const Color(0xFF2E3192) : Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            );
          }
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showAddItemsModal(BuildContext context) {
    List<String> pendingItems = [];
    final localController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void addPendingItem() {
              final text = localController.text.trim();
              if (text.isNotEmpty) {
                setModalState(() {
                  pendingItems.add(text);
                });
                localController.clear();
              }
            }

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
                    controller: localController,
                    onSubmitted: (_) => addPendingItem(),
                    decoration: InputDecoration(
                      labelText: "Nom de l'article",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: addPendingItem,
                      ),
                    ),
                  ),
                  if (pendingItems.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: pendingItems.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final val = entry.value;
                        return Chip(
                          label: Text(val),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setModalState(() {
                              pendingItems.removeAt(idx);
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
                            addPendingItem(); // Add any remaining text in the field
                            if (pendingItems.isNotEmpty) {
                              for (final item in pendingItems) {
                                _addItems(item); // Note: _addItems splits by comma internally too
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
        );
      },
    );
  }

  Widget _buildShoppingItem(String name, String initial, String? avatarUrl, bool isChecked, ValueChanged<bool?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 5,
            spreadRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: onChanged,
            activeColor: const Color(0xFF2E3192),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked ? Colors.grey.shade500 : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          CircleAvatar(
            backgroundColor: avatarUrl != null ? Colors.transparent : Theme.of(context).colorScheme.primary,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            radius: 14,
            child: avatarUrl == null ? Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)) : null,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _showConvertModal(BuildContext context) {
    final titleController = TextEditingController(text: "Courses");
    final amountController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                "Convertir en dépense",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Les articles cochés seront supprimés de la liste de courses.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Titre de la dépense",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Montant total (€)",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
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
                      onPressed: () async {
                        final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
                        if (titleController.text.isNotEmpty && amount != null && amount > 0) {
                          try {
                            await context.read<ExpenseProvider>().createExpense(
                              titleController.text, 
                              amount, 
                              DateTime.now(), 
                              "courses"
                            );
                            if (context.mounted) {
                              await context.read<ShoppingProvider>().clearBoughtItems();
                            }
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez entrer un montant valide.')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E3192),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("CONVERTIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
