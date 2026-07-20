import 'dart:convert';
import 'dart:io';
import 'package:final_year_project2025/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MultiFeatureSwapScreen extends StatefulWidget {
  const MultiFeatureSwapScreen({super.key});

  @override
  State<MultiFeatureSwapScreen> createState() => _MultiFeatureSwapScreenState();
}

class _MultiFeatureSwapScreenState extends State<MultiFeatureSwapScreen> {
  File? sourceImage;
  File? target1, target2, target3;
  String? feature1, feature2, feature3;
  String? resultImageBase64;
  bool isLoading = false;

  final features = ['eyes', 'nose', 'lips', 'full_face'];

  Future<void> pickImage(Function(File) onImagePicked) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onImagePicked(File(image.path));
    }
  }

  Future<void> submitData() async {
    if (sourceImage == null || target1 == null || feature1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Please select at least source, target1 and feature1")),
      );
      return;
    }

    setState(() {
      isLoading = true;
      resultImageBase64 = null;
    });

    var uri = Uri.parse(
        '${ApiService.baseUrl}/multi_feature_swap'); // 👈 your IP here
    var request = http.MultipartRequest('POST', uri);

    request.files
        .add(await http.MultipartFile.fromPath('source', sourceImage!.path));
    request.files
        .add(await http.MultipartFile.fromPath('target1', target1!.path));
    request.fields['feature1'] = feature1!;

    if (target2 != null && feature2 != null) {
      request.files
          .add(await http.MultipartFile.fromPath('target2', target2!.path));
      request.fields['feature2'] = feature2!;
    }

    if (target3 != null && feature3 != null) {
      request.files
          .add(await http.MultipartFile.fromPath('target3', target3!.path));
      request.fields['feature3'] = feature3!;
    }

    try {
      var response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body);

      if (response.statusCode == 200) {
        setState(() {
          resultImageBase64 = data['image'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${data['error']}')),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget imageTile(String title, File? image, VoidCallback onTap) {
    return Column(
      children: [
        Text(title),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: image == null
                ? const Icon(Icons.add_a_photo)
                : Image.file(image, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget featureDropdown(String? selectedFeature, Function(String?) onChanged) {
    return DropdownButton<String>(
      value: selectedFeature,
      hint: const Text("Select Feature"),
      items: features
          .map((f) => DropdownMenuItem(value: f, child: Text(f)))
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Multi Feature Swap"),
        backgroundColor: const Color.fromARGB(255, 129, 209, 218),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            imageTile("Source Image", sourceImage, () {
              pickImage((file) => setState(() => sourceImage = file));
            }),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                imageTile("Target 1", target1, () {
                  pickImage((file) => setState(() => target1 = file));
                }),
                featureDropdown(
                    feature1, (val) => setState(() => feature1 = val)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                imageTile("Target 2", target2, () {
                  pickImage((file) => setState(() => target2 = file));
                }),
                featureDropdown(
                    feature2, (val) => setState(() => feature2 = val)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                imageTile("Target 3", target3, () {
                  pickImage((file) => setState(() => target3 = file));
                }),
                featureDropdown(
                    feature3, (val) => setState(() => feature3 = val)),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isLoading ? null : submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text("Swap Features"),
            ),
            const SizedBox(height: 30),
            if (isLoading) const SpinKitCircle(color: Colors.teal, size: 40),
            if (resultImageBase64 != null)
              Column(
                children: [
                  const Text("Result Image",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Image.memory(base64Decode(resultImageBase64!)),
                ],
              )
          ],
        ),
      ),
    );
  }
}
