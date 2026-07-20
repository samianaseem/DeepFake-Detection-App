import 'package:final_year_project2025/feature_deepfake_generation.dart';
import 'package:final_year_project2025/generate_deepfake.dart';
import 'package:final_year_project2025/history_screen.dart';
import 'package:final_year_project2025/image_screen.dart';
import 'package:final_year_project2025/multi_deepfake_generation.dart';
import 'package:final_year_project2025/multi_feature_generation.dart';
import 'package:final_year_project2025/multiple_image_detect.dart';
import 'package:final_year_project2025/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomeContentScreen> {
  String? userName;

// screen load ho sth e wo cheiz disply ho tb yeh krty
  @override
  void initState() {
    super.initState();
    _getUserName();
  }

//  yeh wo function hai jab screen load hoti hai user ka name fetch kr k phly display kr deta hai
  Future<void> _getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Guest';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 129, 209, 218),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        // ✅ Scroll enable kar raha hai
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section with light blue background
            Container(
              color: const Color.fromARGB(255, 129, 209, 218),
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Welcome, ${userName ?? 'Guest'}", // ✅ Default value handle ki gayi
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "From Below Options Choose",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const Text(
                    "What Type of File You Have?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // Lower Section with buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Image screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DetectImageScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 129, 209, 218),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(200, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text("IMAGE"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to View History screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MultiImageDetectionScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 129, 209, 218),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(200, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text("BULK IMAGE DETECTION"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to Video screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UploadScreenvideo(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 129, 209, 218),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(200, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text("VIDEO"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to View History screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 129, 209, 218),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(200, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: const Text("VIEW HISTORY"),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GenerateDeepfake()),
                        );
                      },
                      child: const Text(
                        "Want to generate deepfake?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GenerateMultiDeepfake()),
                        );
                      },
                      child: const Text(
                        "Want to generate deepfake with multi target images?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddFaceGenerationScreen()),
                        );
                      },
                      child: const Text(
                        "Want to generate deepfake with feature?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiFeatureSwapScreen()),
                        );
                      },
                      child: const Text(
                        "Want to generate deepfake with multi feature swap generation?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
