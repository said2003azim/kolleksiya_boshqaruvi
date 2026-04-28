import 'package:flutter/material.dart';
import 'stats_screen.dart';
import 'items_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<int> _history = [0];

  final List<Widget> _screens = const [
    DashboardScreen(),
    ItemsScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
      _history.add(index);
    });
  }

  bool _handlePop() {
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        _currentIndex = _history.last;
      });
      return false; // We handled the pop by switching tabs
    }
    return true; // Exit app
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<TabBackNotification>(
      onNotification: (_) {
        _handlePop();
        return true;
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_handlePop()) {
            // If history is empty, we could allow exit, 
            // but in Flutter 3.16+ with PopScope we need to handle it carefully.
            // For now, staying on Dashboard if no history.
          }
        },
        child: Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Asosiy',
              ),
              NavigationDestination(
                icon: Icon(Icons.collections_bookmark_outlined),
                selectedIcon: Icon(Icons.collections_bookmark),
                label: 'Kolleksiya',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Statistika',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TabBackNotification extends Notification {}
