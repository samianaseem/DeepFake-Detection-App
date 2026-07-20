import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:final_year_project2025/api.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenerateMultiDeepfake extends StatefulWidget {
  const GenerateMultiDeepfake({super.key});

  @override
  State<GenerateMultiDeepfake> createState() => _GenerateMultiDeepfakeState();
}

class _GenerateMultiDeepfakeState extends State<GenerateMultiDeepfake> {
  File? _sourceImage;
  List<File> _targetImages = [];
  Map<int, Uint8List> _resultImages = {}; // multiple results
  bool _loading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    print("🧾 Loaded userId: $userId");
    setState(() {});
  }

  Future<void> _pickSourceImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _sourceImage = File(result.files.single.path!);
        });
      }
    } catch (e) {
      print("Source image pick error: $e");
    }
  }

  Future<void> _pickMultipleTargetImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _targetImages = result.paths
              .where((path) => path != null)
              .map((path) => File(path!))
              .toList();
        });
      }
    } catch (e) {
      print("Multiple target images pick error: $e");
    }
  }

  Future<void> _handleDeepfake() async {
    if (_sourceImage == null || _targetImages.isEmpty || userId == null) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text('Please select both images and ensure login!'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final ApiService apiService = ApiService();

    final results = await apiService.generateMultiDeepfakeWithMapping(
      _sourceImage!,
      _targetImages,
      userId!,
    );

    if (results.isNotEmpty) {
      setState(() {
        _resultImages = results;
      });
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Deepfake generation failed!')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 129, 209, 218),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color.fromARGB(255, 129, 209, 218),
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', width: 120, height: 120),
                  const SizedBox(height: 16),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: "Generate ",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: "Deepfake ",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        TextSpan(
                          text: "Content",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Choose Source and Target Images",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _imageContainer(
                _sourceImage, "Pick Source Image", _pickSourceImage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickMultipleTargetImages,
              child: const Text("Pick Target Images"),
            ),
            const SizedBox(height: 10),
            _targetImages.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    children: _targetImages
                        .map((img) => Image.file(img,
                            width: 100, height: 100, fit: BoxFit.cover))
                        .toList(),
                  )
                : const Text("No Target Images Selected"),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _loading ? null : _handleDeepfake,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Generate Deepfake"),
            ),
            const SizedBox(height: 30),
            _resultImages.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _resultImages.entries.map((entry) {
                      int index = entry.key;
                      Uint8List imageBytes = entry.value;
                      return Column(
                        children: [
                          Text("🎯 Target Image #$index"),
                          Image.file(_targetImages[index],
                              width: 100, height: 100, fit: BoxFit.cover),
                          const SizedBox(height: 5),
                          Text("🧠 Deepfake Result"),
                          Image.memory(imageBytes,
                              width: 100, height: 100, fit: BoxFit.cover),
                          const Divider(),
                        ],
                      );
                    }).toList(),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _imageContainer(
      File? imageFile, String label, VoidCallback onPressed) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: imageFile == null
                ? const Icon(Icons.cloud_upload, size: 50, color: Colors.grey)
                : Image.file(imageFile, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 5),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 129, 209, 218),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          child: Text(label),
        ),
      ],
    );
  }
}
