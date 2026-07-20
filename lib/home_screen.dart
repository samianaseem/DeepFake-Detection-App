import 'package:final_year_project2025/home_content_screen.dart';
import 'package:final_year_project2025/notification_screen.dart';
import 'package:final_year_project2025/setting_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Default selected tab

  // List of widgets for each tab
  final List<Widget> _pages = [
    const HomeContentScreen(), // Home screen content
    const NotificationScreen(), // Notifications screen content
    const SettingsScreen(), // Settings screen content
  ];

  // Method to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Dynamically show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(
            255, 129, 209, 218), // Custom background color for the bar
        selectedItemColor: Colors.black, // Selected item color
        unselectedItemColor: Colors.black45, // Unselected item color
        currentIndex: _selectedIndex, // Current active tab
        onTap: _onItemTapped, // Tab selection callback
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
