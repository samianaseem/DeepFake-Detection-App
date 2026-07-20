import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareThisAppScreen extends StatelessWidget {
  const ShareThisAppScreen({super.key});

  void _shareApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("App sharing functionality is not implemented yet!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 129, 209, 218),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Section
              Container(
                color: const Color.fromARGB(255, 129, 209, 218),
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png', // App Logo
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Let your friends know about us!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Share this app with your friends and family using the options below.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Share Buttons
              const Text(
                "Share Via:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    context,
                    icon: FontAwesomeIcons.whatsapp, // WhatsApp Icon
                    color: Colors.green,
                    label: "WhatsApp",
                  ),
                  _buildShareOption(
                    context,
                    icon: Icons.email,
                    color: Colors.red,
                    label: "Email",
                  ),
                  _buildShareOption(
                    context,
                    icon: Icons.share,
                    color: Colors.blue,
                    label: "Other",
                  ),
                ],
              ),
              const Spacer(),

              // Bottom Section
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _shareApp(context); // Handle share logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    "Share Now",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(BuildContext context,
      {required IconData icon, required Color color, required String label}) {
    return Column(
      children: [
        IconButton(
          icon: FaIcon(icon, color: color, size: 40),
          onPressed: () {
            _shareApp(context); // Call the share logic
          },
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
