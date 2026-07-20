import 'package:final_year_project2025/home_screen.dart';
import 'package:final_year_project2025/logout_screen.dart';
import 'package:final_year_project2025/personalinfo_screen.dart';
import 'package:final_year_project2025/privacypolicy_screen.dart';
import 'package:final_year_project2025/rateapp_screen.dart';
import 'package:final_year_project2025/shareapp_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settings = [
      {
        "icon": Icons.person,
        "label": "Personal Info",
        "screen": PersonalInfoScreen()
      },
      {
        "icon": Icons.lock,
        "label": "Privacy Policy",
        "screen": PrivacyPolicyScreen()
      },
      {
        "icon": Icons.star,
        "label": "Rate This App",
        "screen": RateThisAppScreen()
      },
      {
        "icon": Icons.share,
        "label": "Share This App",
        "screen": ShareThisAppScreen()
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 129, 209, 218),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              // Header Section
              Container(
                color: const Color.fromARGB(255, 129, 209, 218),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png', // Foreground logo
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "GENERAL SETTINGS",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        "Access settings to personalize your alerts and preferences.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Settings List
              Expanded(
                child: ListView.builder(
                  itemCount: settings.length,
                  itemBuilder: (context, index) {
                    final setting = settings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Icon(
                          setting['icon'],
                          color: const Color.fromARGB(255, 129, 209, 218),
                        ),
                        title: Text(setting['label']),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.black45, size: 16),
                        onTap: () {
                          // Navigate to the respective screen if provided
                          if (setting['screen'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => setting['screen'],
                              ),
                            );
                          } else {
                            // Handle cases where there's no specific screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("${setting['label']} coming soon!"),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Logout Button
              ElevatedButton(
                onPressed: () {
                  // Handle logout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LogoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  "LOGOUT",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ],
      ),
    );
  }
}
