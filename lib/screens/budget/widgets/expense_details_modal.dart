import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/expense.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/payment_service.dart';
import '../../../../constants/bank_constants.dart';

class ExpenseDetailsModal extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailsModal({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
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
          const Text(
            "Détail de la dépense",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          // Logique de remboursement
          Consumer<AuthProvider>(
            builder: (context, authProv, child) {
              final currentUser = authProv.currentUser;
              if (currentUser == null || expense.payer == null || expense.splits == null) {
                return const SizedBox.shrink();
              }

              // Chercher si l'utilisateur courant doit rembourser
              final mySplit = expense.splits!.where((s) => 
                s.user?.id == currentUser.id && 
                !s.isSettled && 
                s.user?.id != expense.payer?.id
              ).toList();

              if (mySplit.isNotEmpty) {
                final receiver = expense.payer!;
                final bankId = receiver.preferredBank;
                final iban = receiver.iban;
                final bankName = bankId != null ? BankConstants.supportedBanks[bankId]?.displayName : null;

                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (iban != null && iban.isNotEmpty) {
                            await PaymentService.processPayment(context, bankId ?? '', iban);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Le receveur n\'a pas renseigné son IBAN.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD81B60),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: Text(
                          bankName != null ? "Rembourser via $bankName" : "Rembourser manuellement",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
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
  }
}

