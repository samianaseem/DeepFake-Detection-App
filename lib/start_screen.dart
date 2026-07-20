import 'package:final_year_project2025/login_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center, // Align everything to center
          children: [
            // Top Image or Icon
            Image.asset(
              'assets/logo.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),

            // App Title with "Fake" in red
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Fake",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.red, // Red color for "Fake"
                    ),
                  ),
                  TextSpan(
                    text: "Detect",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Black color for "Detect"
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Beware of fakes with ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  TextSpan(
                    text: "FakeDetect",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red, // Red color for "FakeDetect"
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Welcome Message with line below
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 129, 209, 218),
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 100, // Half-width line
                height: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 129, 209, 218),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Welcome Description
            const Text(
              "Hello, thank you for downloading our app! Follow our guide for using this application.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "If this is not the first time, you can skip this guide. If you want to follow the guide again, then it's no problem!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Get Started Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ScanDetectScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                foregroundColor: Colors.black,
                backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "GET STARTED",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 32, 32, 32),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward, // Arrow icon
                    size: 20,
                    color: Color.fromARGB(255, 32, 32, 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanDetectScreen extends StatelessWidget {
  const ScanDetectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Image or Icon
              Image.asset(
                'assets/Black and White Illustrative Apparel Logo (3).png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 20),

              // App Title with "Fake" in red
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Scan & Detect",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Deepfake ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Content",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 20, 20, 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Half-width line below "Deepfake Content"
              const SizedBox(height: 8),
              const Divider(
                thickness: 2,
                color: Color.fromARGB(255, 129, 209, 218),
                indent: 100, // Adjust for half width
                endIndent: 100, // Adjust for half width
              ),
              const SizedBox(height: 20),

              // Description
              const Text(
                "This App detects deep fake images and videos with high accuracy and speed, ensuring security and reliability for users.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              // Options
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.check_circle_outline,
                    color: Color.fromARGB(255, 129, 209, 218),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Detect Image",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.check_circle_outline,
                    color: Color.fromARGB(255, 129, 209, 218),
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Detect Video",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Next Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  foregroundColor: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  "NEXT",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 16, 16, 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
