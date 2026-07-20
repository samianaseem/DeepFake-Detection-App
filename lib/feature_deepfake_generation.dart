import 'dart:convert';
import 'dart:io';
import 'package:final_year_project2025/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddFaceGenerationScreen extends StatefulWidget {
  const AddFaceGenerationScreen({super.key});

  @override
  State<AddFaceGenerationScreen> createState() =>
      _AddFaceGenerationScreenState();
}

class _AddFaceGenerationScreenState extends State<AddFaceGenerationScreen> {
  File? _image1;
  File? _image2;
  String _selectedFeature = '4'; // Default: full face
  String? _base64Result;
  bool _loading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    loadUserId();
  }

  Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  Future<void> _pickImage(bool isFirst) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isFirst) {
          _image1 = File(picked.path);
        } else {
          _image2 = File(picked.path);
        }
      });
    }
  }

  Future<void> _submitFaceSwap() async {
    if (_image1 == null || _image2 == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please pick both images and login first')),
      );
      return;
    }

    setState(() => _loading = true);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
          '${ApiService.baseUrl}/feature_deepkake_generation'), // Replace with your IP if testing on physical device
    );
    request.files
        .add(await http.MultipartFile.fromPath('image1', _image1!.path));
    request.files
        .add(await http.MultipartFile.fromPath('image2', _image2!.path));
    request.fields['feature_type'] = _selectedFeature;
    request.fields['user_id'] = userId!;

    try {
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _base64Result = jsonResponse['image'];
        });
      } else {
        print("Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Face generation failed")),
        );
      }
    } catch (e) {
      print("Request failed: $e");
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F8FB),
      appBar: AppBar(
        title: const Text("Add Face Generator"),
        backgroundColor: const Color(0xFF81D1DA),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Choose Feature to Swap:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedFeature,
              onChanged: (val) => setState(() => _selectedFeature = val!),
              items: const [
                DropdownMenuItem(value: '1', child: Text("Nose")),
                DropdownMenuItem(value: '2', child: Text("Lips")),
                DropdownMenuItem(value: '3', child: Text("Eyes")),
                DropdownMenuItem(value: '4', child: Text("Full Face")),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildImagePicker(
                    _image1, "Pick Image 1", () => _pickImage(true)),
                _buildImagePicker(
                    _image2, "Pick Image 2", () => _pickImage(false)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _submitFaceSwap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF81D1DA),
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Generate Deepfake"),
            ),
            const SizedBox(height: 20),
            _base64Result != null
                ? Column(
                    children: [
                      const Text("Generated Result:"),
                      const SizedBox(height: 10),
                      Image.memory(base64Decode(_base64Result!)),
                    ],
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(File? image, String label, VoidCallback onPick) {
    return GestureDetector(
      onTap: onPick,
      child: Column(
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.white,
            ),
            child: image == null
                ? const Icon(Icons.add_photo_alternate_outlined,
                    size: 50, color: Colors.grey)
                : Image.file(image, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
