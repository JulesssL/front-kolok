import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ExpenseService _expenseService = ExpenseService();
  
  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _expenses = await _expenseService.getExpenses();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createExpense(String title, double amount, DateTime date, String category) async {
    try {
      final newExpense = await _expenseService.createExpense(title, amount, date, category);
      _expenses.add(newExpense);
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> settleMyDebts(String currentUserId) async {
    try {
      for (final expense in _expenses) {
        if (expense.payer?.id != currentUserId) {
          if (expense.splits != null) {
            for (final split in expense.splits!) {
              if (split.user?.id == currentUserId && !split.isSettled) {
                await _expenseService.settleSplit(split.id);
              }
            }
          }
        }
      }
      // Re-fetch to get updated splits
      await fetchExpenses();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
