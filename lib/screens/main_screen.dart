import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/shopping_provider.dart';
import '../providers/chat_provider.dart';
import 'home/home_screen.dart';
import 'tasks/tasks_screen.dart';
import 'budget/budget_screen.dart';
import 'shopping/shopping_screen.dart';
import 'messages/messages_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
      context.read<ExpenseProvider>().fetchExpenses();
      context.read<ShoppingProvider>().fetchItems();
      context.read<ChatProvider>().fetchMessages();
    });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const TasksScreen(),
    const MessagesScreen(),
    const BudgetScreen(),
    const ShoppingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          onPressed: () => setState(() => _currentIndex = 2),
          backgroundColor: const Color(0xFF2E3192),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white,
            size: 28,
          ), 
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 85,
        color: Colors.white,
        padding: EdgeInsets.zero,
        notchMargin: 6,
        child: Row(
          children: <Widget>[
            _buildNavItem("home", "Accueil", 0),
            _buildNavItem("tasks", "Tâches", 1),

            Expanded(child: const SizedBox.shrink()), // Center spacer

            _buildNavItem("budget", "Budget", 3),
            _buildNavItem("courses", "Courses", 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String iconName, String label, int index) {
    bool isActive = _currentIndex == index;
    String assetPath = isActive 
        ? 'assets/icons/${iconName}_active.svg' 
        : 'assets/icons/${iconName}_inactive.svg';

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconName == "budget")
              Icon(
                Icons.account_balance_wallet,
                color: isActive ? const Color(0xFF2E3192) : Colors.grey.shade400,
                size: 24,
              )
            else
              SvgPicture.asset(
                assetPath,
                width: 22,
                colorFilter: ColorFilter.mode(
                  isActive ? const Color(0xFF2E3192) : Colors.grey.shade400,
                  BlendMode.srcIn,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF2E3192) : Colors.grey.shade600,
                fontSize: 10,
                fontFamily: 'Gilroy',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}