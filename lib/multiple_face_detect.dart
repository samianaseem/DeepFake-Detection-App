//  deepseek code

import 'dart:io';
import 'dart:convert';
import 'package:final_year_project2025/api.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({super.key});

  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  List<FaceResult> _faceResults = [];
  String? _errorMessage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _faceResults = [];
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  Future<void> _detectFaces() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _faceResults = [];
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      setState(() {
        _errorMessage = 'User ID not found. Please login again.';
        _isLoading = false;
      });
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/api/detect_multiple_image'),
      );

      request.fields['user_id'] = userId;

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200) {
        List<dynamic> rawResults = jsonResponse['results'] ?? [];

        // ✅ Filter out only valid face detections (skip error entries)
        List<dynamic> validFaces = rawResults
            .where((face) =>
                face.containsKey('result_image') &&
                face['result_image'] != null &&
                face.containsKey('confidence_score') &&
                face.containsKey('result'))
            .toList();

        setState(() {
          _faceResults =
              validFaces.map((face) => FaceResult.fromJson(face)).toList();
        });

        if (_faceResults.isEmpty) {
          _errorMessage = 'No valid faces detected.';
        }
      } else {
        setState(() {
          _errorMessage = jsonResponse['error'] ?? 'Failed to detect faces';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Face Detection'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  child: const Text(
                    'Select Image',
                    // style: TextStyle(
                    //   fontSize: 18,
                    //   fontWeight: FontWeight.bold,
                    //   color: const Color.fromARGB(255, 129, 209, 218),),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedImage == null ? null : _detectFaces,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  child: const Text(
                    'Detect Faces',
                    // style: TextStyle(
                    //   fontSize: 18,
                    //   fontWeight: FontWeight.bold,
                    //   color: const Color.fromARGB(255, 129, 209, 218),
                    // ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_selectedImage != null && !_isLoading) ...[
              const Text(
                'Original Image:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 129, 209, 218),
                ),
              ),
              const SizedBox(height: 10),
              Image.file(_selectedImage!),
              const SizedBox(height: 20),
            ],
            if (_faceResults.isNotEmpty) ...[
              const Text(
                'Detected Faces:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 129, 209, 218),
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.8,
                ),
                itemCount: _faceResults.length,
                itemBuilder: (context, index) {
                  return FaceCard(faceResult: _faceResults[index]);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FaceResult {
  final String faceImage;
  final bool isReal;
  final double confidenceScore;
  final int faceNumber;

  FaceResult({
    required this.faceImage,
    required this.isReal,
    required this.confidenceScore,
    required this.faceNumber,
  });

  factory FaceResult.fromJson(Map<String, dynamic> json) {
    return FaceResult(
      faceImage: json['result_image'] ?? '',
      isReal: (json['result']?.toString().toLowerCase() == 'real'),
      confidenceScore: (json['confidence_score'] ?? 0).toDouble(),
      faceNumber: json['face_index'] ?? 0,
    );
  }
}

class FaceCard extends StatelessWidget {
  final FaceResult faceResult;

  const FaceCard({super.key, required this.faceResult});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              "${ApiService.baseUrl}/result/${faceResult.faceImage}",
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Face ${faceResult.faceNumber}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Status: ${faceResult.isReal ? 'Real' : 'Fake'}',
                  style: TextStyle(
                    color: faceResult.isReal ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${(faceResult.confidenceScore * 100).toStringAsFixed(2)}%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
