import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shopping_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text(
          "KOLOK",
          style: TextStyle(
            color: Color(0xFF2E3192),
            fontWeight: FontWeight.w800,
            fontSize: 24,
            fontFamily: 'Gilroy',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, color: Colors.grey.shade700),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildInputAdd(),
          ),
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
                  return const Center(child: Text("La liste est vide"));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: shoppingProv.items.length,
                  itemBuilder: (context, index) {
                    final item = shoppingProv.items[index];
                    return _buildShoppingItem(
                      item.name,
                      "?", // We'd need addedBy user info to show initial
                      item.isBought,
                      (value) {
                        if (value != null) {
                          shoppingProv.toggleItemStatus(item.id, value);
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
          label: const Text(
            "CONVERTIR EN DÉPENSE (3)",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E3192),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInputAdd() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: TextField(
        controller: _itemController,
        decoration: InputDecoration(
          hintText: "Ajouter un article...",
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          border: InputBorder.none,
          suffixIcon: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF2E3192),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 20),
                onPressed: () {
                  if (_itemController.text.isNotEmpty) {
                    context.read<ShoppingProvider>().createItem(_itemController.text, null);
                    _itemController.clear();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShoppingItem(String name, String initial, bool isChecked, ValueChanged<bool?> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
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
                color: isChecked ? Colors.grey.shade500 : Colors.black,
              ),
            ),
          ),
          CircleAvatar(
            backgroundColor: const Color(0xFF2E3192),
            radius: 14,
            child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
