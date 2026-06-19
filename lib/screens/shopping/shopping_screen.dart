import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shopping_provider.dart';
import '../../providers/auth_provider.dart';
import '../settings/settings_screen.dart';
import 'widgets/add_shopping_item_modal.dart';
import 'widgets/shopping_list_item.dart';
import 'widgets/convert_to_expense_modal.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Image.asset(
          'assets/images/logo_text_blue.png',
          width: 90,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary, size: 28),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddShoppingItemModal(),
              );
            },
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
              child: Consumer<AuthProvider>(
                builder: (context, authProv, child) {
                  final avatarUrl = authProv.currentUser?.avatarUrl;
                  if (avatarUrl != null) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(avatarUrl),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    );
                  }
                  return CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(Icons.person_outline, color: Colors.grey.shade700),
                  );
                },
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
                      
                      return ShoppingListItem(
                        name: item.name,
                        initial: authorInitial,
                        avatarUrl: item.createdBy?.avatarUrl,
                        isChecked: item.isBought,
                        onChanged: (value) {
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
              onPressed: hasBoughtItems ? () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const ConvertToExpenseModal(),
                );
              } : null,
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
}
