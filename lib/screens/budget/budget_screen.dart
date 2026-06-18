import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/expense.dart';
import '../settings/settings_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final List<String> _categories = ["courses", "loyer", "factures", "loisirs", "autres"];
  String _selectedAssigneeFilter = 'all'; 

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ExpenseProvider>().fetchExpenses();
      }
    });
  }

  Future<void> _refreshExpenses() async {
    await context.read<ExpenseProvider>().fetchExpenses();
  }

  double _calculateJeDois(List<Expense> expenses, String currentUserId) {
    double jeDois = 0.0;
    for (final expense in expenses) {
      if (expense.payer?.id != currentUserId) {
        if (expense.splits != null) {
          for (final split in expense.splits!) {
            if (split.user?.id == currentUserId && !split.isSettled) {
              jeDois += split.amount;
            }
          }
        }
      }
    }
    return jeDois;
  }

  double _calculateOnMeDoit(List<Expense> expenses, String currentUserId) {
    double onMeDoit = 0.0;
    for (final expense in expenses) {
      if (expense.payer?.id == currentUserId) {
        if (expense.splits != null) {
          for (final split in expense.splits!) {
            if (split.user?.id != currentUserId && !split.isSettled) {
              onMeDoit += split.amount;
            }
          }
        }
      }
    }
    return onMeDoit;
  }

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    var filtered = expenses.where((e) {
      if (_selectedAssigneeFilter != 'all') {
        if (e.payer?.id != _selectedAssigneeFilter) return false;
      }
      return true;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date)); // Sort by date desc
    return filtered;
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
            onPressed: () => _showAddExpenseModal(context),
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
        onRefresh: _refreshExpenses,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Balances",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Consumer2<ExpenseProvider, AuthProvider>(
                builder: (context, expenseProv, authProv, child) {
                  final currentUser = authProv.currentUser;
                  if (currentUser == null) return const SizedBox.shrink();

                  final jeDois = _calculateJeDois(expenseProv.expenses, currentUser.id);
                  final onMeDoit = _calculateOnMeDoit(expenseProv.expenses, currentUser.id);
                  
                  final maxBalance = (jeDois > onMeDoit ? jeDois : onMeDoit);
                  final maxScale = maxBalance > 0 ? maxBalance * 1.2 : 100.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBalanceBar("Je dois", jeDois, maxScale, const Color(0xFFD81B60)),
                      const SizedBox(height: 24),
                      _buildBalanceBar("On me doit", onMeDoit, maxScale, const Color(0xFF4CE0B3)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),
              Center(
                child: Consumer<ExpenseProvider>(
                  builder: (context, expenseProv, child) {
                    final totalExpenses = expenseProv.expenses.fold(0.0, (sum, e) => sum + e.amount);
                    return Column(
                      children: [
                        Text("TOTAL DES DÉPENSES", style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text("${totalExpenses.toStringAsFixed(0)}€", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 32, fontWeight: FontWeight.w800)),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Détails",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  _buildFilters(),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<ExpenseProvider>(
                builder: (context, expenseProv, child) {
                  if (expenseProv.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final filteredExpenses = _getFilteredExpenses(expenseProv.expenses);

                  if (filteredExpenses.isEmpty) {
                    return const Center(child: Text("Aucune dépense enregistrée."));
                  }
                  return Column(
                    children: filteredExpenses.map((e) => GestureDetector(
                      onTap: () => _showExpenseDetailsModal(context, e),
                      child: _buildDetailItem(
                        e.payer?.name.isNotEmpty == true ? e.payer!.name[0].toUpperCase() : '?', 
                        e.title, 
                        e.category, 
                        "${e.amount.toStringAsFixed(2)}€", 
                        const Color(0xFFD81B60), 
                        Theme.of(context).colorScheme.primary
                      ),
                    )).toList(),
                  );
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: Consumer2<ExpenseProvider, AuthProvider>(
          builder: (context, expenseProv, authProv, child) {
             final currentUser = authProv.currentUser;
             final jeDois = currentUser != null ? _calculateJeDois(expenseProv.expenses, currentUser.id) : 0.0;
             return ElevatedButton.icon(
              onPressed: jeDois > 0 ? () => _showReimburseModal(context, jeDois, currentUser!.id) : null,
              icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
              label: const Text(
                "SOLDER MES DETTES",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: jeDois > 0 ? const Color(0xFF2E3192) : Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            );
          }
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFilters() {
    final members = context.watch<AuthProvider>().currentUser?.kolok?.users ?? [];
    return DropdownButton<String>(
      value: _selectedAssigneeFilter,
      underline: const SizedBox(),
      icon: const Icon(Icons.filter_list, size: 20),
      items: [
        const DropdownMenuItem(value: 'all', child: Text("Tous")),
        ...members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))),
      ],
      onChanged: (val) {
        if (val != null) {
          setState(() => _selectedAssigneeFilter = val);
        }
      },
    );
  }

  Widget _buildBalanceBar(String label, double value, double max, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text("${value.toStringAsFixed(2)}€", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            widthFactor: value / max,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String initial, String name, String description, String amount, Color amountColor, Color avatarColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
          CircleAvatar(
            backgroundColor: avatarColor,
            radius: 18,
            child: Text(initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(description, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: amountColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chevron_right, color: amountColor, size: 16),
          )
        ],
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedCategory = _categories.first;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    "Ajouter une dépense",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      labelText: "Montant (€)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategory,
                        items: _categories.map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text(c[0].toUpperCase() + c.substring(1)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() => selectedCategory = val);
                        },
                      ),
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
                                  selectedCategory ?? 'autres'
                                );
                                if (context.mounted) Navigator.pop(context);
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez entrer un titre et un montant valide.')));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E3192),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text("AJOUTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showExpenseDetailsModal(BuildContext context, Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Détail de la dépense",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(expense.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                "${DateFormat('dd/MM/yyyy HH:mm').format(expense.date)} - ${expense.category}",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      expense.payer?.name.isNotEmpty == true ? expense.payer!.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${expense.payer?.name ?? 'Inconnu'} a payé ${expense.amount.toStringAsFixed(2)}€",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Répartition :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if (expense.splits != null)
                ...expense.splits!.map((split) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(split.user?.name ?? 'Inconnu'),
                        Row(
                          children: [
                            Text(
                              "${split.amount.toStringAsFixed(2)}€",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (split.isSettled)
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                              )
                            else if (split.user?.id != expense.payer?.id)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.pending, color: Colors.orange.shade400, size: 16),
                              ),
                          ],
                        )
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E3192),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("FERMER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showReimburseModal(BuildContext context, double amount, String currentUserId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rembourser mes dettes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Montant total à payer", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("${amount.toStringAsFixed(2)}€", style: const TextStyle(color: Color(0xFF2E3192), fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Êtes-vous sûr de vouloir marquer toutes vos dettes comme réglées ?",
              style: TextStyle(fontSize: 16),
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
                      try {
                        await context.read<ExpenseProvider>().settleMyDebts(currentUserId);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vos dettes ont été soldées avec succès !")),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E3192),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("CONFIRMER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
