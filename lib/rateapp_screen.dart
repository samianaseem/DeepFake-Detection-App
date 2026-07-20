import 'package:flutter/material.dart';

class RateThisAppScreen extends StatefulWidget {
  const RateThisAppScreen({super.key});

  @override
  State<RateThisAppScreen> createState() => _RateThisAppScreenState();
}

class _RateThisAppScreenState extends State<RateThisAppScreen> {
  int _selectedStars = 0; // Variable to store the number of stars selected

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
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.5, // Covers only the lower half (50%)
              widthFactor: 1.0, // Full width
              child: Opacity(
                opacity: 0.1, // Adjust transparency (lighter effect)
                child: Image.asset(
                  'assets/logo.png', // Replace with your background image
                  fit: BoxFit.cover,
                ),
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
                      'assets/logo.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "We'd love your feedback!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Rate your experience with our app.",
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

              // Stars Section
              const Text(
                "How many stars would you like to give us?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      size: 40,
                      color: _selectedStars > index
                          ? Colors.yellow
                          : Colors.grey[800],
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedStars = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _selectedStars == 0
                    ? null
                    : () {
                        // Add logic to handle the rating submission
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Thank you for rating us $_selectedStars stars!",
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
