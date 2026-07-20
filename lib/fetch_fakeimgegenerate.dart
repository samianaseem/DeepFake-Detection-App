import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:final_year_project2025/api.dart';

class AllGeneratedImagesScreen extends StatefulWidget {
  const AllGeneratedImagesScreen({super.key});

  @override
  State<AllGeneratedImagesScreen> createState() =>
      _AllGeneratedImagesScreenState();
}

class _AllGeneratedImagesScreenState extends State<AllGeneratedImagesScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, dynamic>>> _imagesFuture;

  @override
  void initState() {
    super.initState();
    _imagesFuture = _apiService.fetchAllGeneratedImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Deepfake Results'),
        backgroundColor: const Color.fromARGB(255, 129, 209, 218),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("❌ Failed to load images"));
          }

          final images = snapshot.data!;
          if (images.isEmpty) {
            return const Center(child: Text("No images found."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageData = images[index];
              final Uint8List imageBytes = imageData['imageBytes'];

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.memory(imageBytes, fit: BoxFit.cover),
              );
            },
          );
        },
      ),
    );
  }
}
