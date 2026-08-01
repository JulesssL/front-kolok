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
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _pages[_currentIndex],

      floatingActionButton: isKeyboardVisible ? null : AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        offset: _currentIndex == 2 ? const Offset(0, 0.6) : Offset.zero,
        child: SizedBox(
          height: 65,
          width: 65,
          child: FloatingActionButton(
            onPressed: () => setState(() => _currentIndex = 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
            elevation: 4,
            shape: const CircleBorder(),
            child: SvgPicture.asset(
              'assets/icons/messages.svg',
              colorFilter: ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              width: 22,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: isKeyboardVisible ? null : FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: isKeyboardVisible ? null : BottomAppBar(
        height: 85,
        color: Theme.of(context).colorScheme.surface,
        padding: EdgeInsets.zero,
        notchMargin: 6,
        child: Row(
          children: <Widget>[
            _buildNavItem("home", "Accueil", 0),
            _buildNavItem("tasks", "Tâches", 1),

            const Expanded(child: SizedBox.shrink()), // Center spacer

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

    final primaryColor = Theme.of(context).colorScheme.primary;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [            
            SvgPicture.asset(
              assetPath,
              width: 22,
              colorFilter: ColorFilter.mode(
                isActive ? primaryColor : Colors.grey.shade400,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? primaryColor : Colors.grey.shade600,
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