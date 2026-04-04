import 'package:flutter/material.dart';
import 'package:dreamventz/screens/cart/cart_page.dart';
import 'package:dreamventz/screens/home/home_page.dart';
import 'package:dreamventz/screens/bookings/bookings_page.dart';
import 'package:dreamventz/screens/history/history_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  int _cartRefreshSignal = 0;

  List<Widget> _buildPages() {
    return [
      HomePage(),
      CartPage(refreshSignal: _cartRefreshSignal),
      BookingsPage(),
      HistoryPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == 1) {
        _cartRefreshSignal++;
      }
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xff0c1c2c),
        selectedItemColor: Color.fromARGB(255, 212, 175, 55),
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
