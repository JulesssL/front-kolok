import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/expense.dart';
import '../settings/settings_screen.dart';
import 'widgets/expense_list_item.dart';
import 'widgets/add_expense_modal.dart';
import 'widgets/expense_details_modal.dart';
import 'widgets/reimburse_modal.dart';
import 'widgets/balance_summary.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
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
                builder: (context) => const AddExpenseModal(),
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
                  
                  return BalanceSummary(jeDois: jeDois, onMeDoit: onMeDoit);
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
                    children: filteredExpenses.map((e) => ExpenseListItem(
                      initial: e.payer?.name.isNotEmpty == true ? e.payer!.name[0].toUpperCase() : '?',
                      name: e.title,
                      description: e.category,
                      amount: "${e.amount.toStringAsFixed(2)}€",
                      amountColor: const Color(0xFFD81B60),
                      avatarColor: Theme.of(context).colorScheme.primary,
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => ExpenseDetailsModal(expense: e),
                        );
                      },
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
              onPressed: jeDois > 0 ? () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => ReimburseModal(amount: jeDois, currentUserId: currentUser!.id),
                );
              } : null,
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
}
