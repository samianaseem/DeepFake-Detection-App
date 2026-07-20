import 'package:final_year_project2025/login_screen.dart';
import 'package:flutter/material.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  void _logout(BuildContext context) {
    // Add logout logic here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("You have been logged out.")),
    );

    // Navigate to the login screen
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 129, 209, 218),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Top Section with Background Color and Logo
          Container(
            color: const Color.fromARGB(255, 129, 209, 218),
            width: double.infinity,
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
                  "Logout",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Main Section with Logout Content
          Expanded(
            child: Stack(
              children: [
                // Background Logo
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logout Icon
                      const Icon(
                        Icons.exit_to_app,
                        size: 100,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 20),

                      // Confirmation Text
                      const Text(
                        "Are you sure you want to log out?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Logout and Cancel Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Cancel Logout
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 200, 200, 200),
                              minimumSize: const Size(120, 50),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _logout(context); // Confirm Logout
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 129, 209, 218),
                              minimumSize: const Size(120, 50),
                            ),
                            child: const Text(
                              "Logout",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
