import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ExpenseProvider>().fetchExpenses();
      }
    });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Balances",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildBalanceBar("Je dois", 45, 100, const Color(0xFFD81B60)),
            const SizedBox(height: 24),
            _buildBalanceBar("On me doit", 20, 100, const Color(0xFF4CE0B3)),
            const SizedBox(height: 40),
            Center(
              child: Consumer<ExpenseProvider>(
                builder: (context, expenseProv, child) {
                  final totalExpenses = expenseProv.expenses.fold(0.0, (sum, e) => sum + e.amount);
                  return Column(
                    children: [
                      Text("TOTAL DES DÉPENSES", style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("${totalExpenses.toStringAsFixed(0)}€", style: const TextStyle(color: Color(0xFF2E3192), fontSize: 32, fontWeight: FontWeight.w800)),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              "Détails",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer<ExpenseProvider>(
              builder: (context, expenseProv, child) {
                if (expenseProv.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (expenseProv.expenses.isEmpty) {
                  return const Text("Aucune dépense enregistrée.");
                }
                return Column(
                  children: expenseProv.expenses.map((e) => _buildDetailItem(
                    e.title[0].toUpperCase(), 
                    e.title, 
                    e.category ?? 'Dépense', 
                    "${e.amount.toStringAsFixed(0)}€", 
                    const Color(0xFFD81B60), 
                    const Color(0xFF2E3192)
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: ElevatedButton.icon(
          onPressed: () => _showReimburseModal(context),
          icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white),
          label: const Text(
            "SOLDER MES DETTES (45€)",
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

  Widget _buildBalanceBar(String label, double value, double max, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text("${value.toInt()}€", style: TextStyle(color: color, fontWeight: FontWeight.bold)),
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

  void _showReimburseModal(BuildContext context) {
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
              "Rembourser",
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
                  Text("Montant à payer", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Text("45€", style: TextStyle(color: Color(0xFF2E3192), fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Text("à Samy", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text("Méthode de paiement", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("Sélectionner une méthode"),
                  items: const [],
                  onChanged: (val) {},
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
                    onPressed: () => Navigator.pop(context),
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
