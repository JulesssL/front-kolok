import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text("Accueil")),
    const Center(child: Text("Tâches")),
    const Center(child: Text("Messages")),
    const Center(child: Text("Budget")),
    const Center(child: Text("Courses")),
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
          child: const SizedBox.shrink(), 
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

            _buildCenterItem("messages", "Messages", 2),

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

  Widget _buildCenterItem(String iconName, String label, int index) {
    bool isActive = _currentIndex == index;
    
    String assetPath = "assets/icons/${iconName}.svg";

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12.0), 
            child: SvgPicture.asset(
              assetPath,
              width: 26,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF2E3192) : Colors.grey.shade600,
                fontSize: 10,
                fontFamily: 'Gilroy',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}