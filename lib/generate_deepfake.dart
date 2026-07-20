// import 'package:final_year_project2025/api.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:image_picker/image_picker.dart';

// class GenerateDeepfake extends StatefulWidget {
//   const GenerateDeepfake({super.key});

//   @override
//   State<GenerateDeepfake> createState() => _GenerateDeepfakeState();
// }

// class _GenerateDeepfakeState extends State<GenerateDeepfake> {
//   File? _sourceImage;
//   File? _targetImage;
//   Uint8List? _resultBytes;
//   final ImagePicker _picker = ImagePicker();
//   final ApiService _apiService = ApiService();
//   bool _loading = false;

//   Future<void> _pickImage(bool isSource) async {
//     try {
//       final XFile? pickedFile =
//           await _picker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() {
//           if (isSource) {
//             _sourceImage = File(pickedFile.path);
//           } else {
//             _targetImage = File(pickedFile.path);
//           }
//         });
//       }
//     } catch (e) {
//       print("Image pick error: $e");
//     }
//   }

//   Future<void> _handleDeepfake() async {
//     if (_sourceImage == null || _targetImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select both images!')),
//       );
//       return;
//     }

//     setState(() => _loading = true);
//     final result =
//         await _apiService.generateDeepfake(_sourceImage!, _targetImage!);

//     if (result != null) {
//       setState(() => _resultBytes = result);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Deepfake generation failed!')),
//       );
//     }

//     setState(() => _loading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: const Color.fromARGB(255, 129, 209, 218),
//           elevation: 0,
//         ),
//         body: SingleChildScrollView(
//             child: Column(children: [
//           Container(
//               color: const Color.fromARGB(255, 129, 209, 218),
//               width: double.infinity,
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       'assets/logo.png',
//                       width: 120,
//                       height: 120,
//                     ),
//                     const SizedBox(height: 16),
//                     RichText(
//                       textAlign: TextAlign.center,
//                       text: const TextSpan(
//                         children: [
//                           TextSpan(
//                             text: "Generate ",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                           TextSpan(
//                             text: "Deepfake ",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                           TextSpan(
//                             text: "Content",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       "Choose Two Images",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ])),
//           const SizedBox(height: 40),

//           // Row with Source and Target buttons
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _imageContainer(
//                     _sourceImage, "Source Image", () => _pickImage(true)),
//                 _imageContainer(
//                     _targetImage, "Target Image", () => _pickImage(false)),
//               ],
//             ),
//           ),

//           const SizedBox(height: 50),

//           // Generate Deepfake Button
//           ElevatedButton(
//             onPressed: _loading ? null : _handleDeepfake,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color.fromARGB(255, 129, 209, 218),
//               foregroundColor: Colors.black,
//               minimumSize: const Size(200, 60),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//             ),
//             child: _loading
//                 ? const CircularProgressIndicator()
//                 : const Text("Generate Deepfake"),
//           ),

//           const SizedBox(height: 30),

//           if (_resultBytes != null) ...[
//             const Text("Result Image:"),
//             const SizedBox(height: 10),
//             Image.memory(_resultBytes!, width: 250),
//             const SizedBox(height: 30),
//           ],
//         ])));
//   }

//   Widget _imageContainer(
//       File? imageFile, String label, VoidCallback onPressed) {
//     return Column(
//       children: [
//         GestureDetector(
//           onTap: onPressed,
//           child: Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//             ),
//             child: imageFile == null
//                 ? const Icon(Icons.cloud_upload, size: 50, color: Colors.grey)
//                 : Image.file(imageFile, fit: BoxFit.cover),
//           ),
//         ),
//         const SizedBox(height: 5),
//         ElevatedButton(
//           onPressed: onPressed,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color.fromARGB(255, 129, 209, 218),
//             foregroundColor: Colors.black,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//           ),
//           child: Text(label),
//         ),
//       ],
//     );
//   }
// }
// // ---------------------------------
//

import 'package:final_year_project2025/fetch_fakeimgegenerate.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_year_project2025/api.dart';

class GenerateDeepfake extends StatefulWidget {
  const GenerateDeepfake({super.key});

  @override
  State<GenerateDeepfake> createState() => _GenerateDeepfakeState();
}

class _GenerateDeepfakeState extends State<GenerateDeepfake> {
  File? _sourceImage;
  File? _targetImage;
  Uint8List? _resultBytes;
  String? userId;

  final ImagePicker _picker = ImagePicker();
  final ApiService _apiService = ApiService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Load user ID from shared prefs
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    print("🧾 Loaded userId: $userId");
    setState(() {});
  }

  Future<void> _pickImage(bool isSource) async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          if (isSource) {
            _sourceImage = File(pickedFile.path);
          } else {
            _targetImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      print("Image pick error: $e");
    }
  }

  Future<void> _handleDeepfake() async {
    if (_sourceImage == null || _targetImage == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select both images and ensure login!')),
      );
      return;
    }

    setState(() => _loading = true);

    final result = await _apiService.generateDeepfake(
      _sourceImage!,
      _targetImage!,
      userId!, // ✅ Pass userId to API
    );

    if (result != null) {
      setState(() => _resultBytes = result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
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
                  Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                  ),
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
                    "Choose Two Images",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _imageContainer(
                      _sourceImage, "Source Image", () => _pickImage(true)),
                  _imageContainer(
                      _targetImage, "Target Image", () => _pickImage(false)),
                ],
              ),
            ),
            const SizedBox(height: 50),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AllGeneratedImagesScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text("View All Deepfakes"),
            ),
            const SizedBox(height: 30),
            if (_resultBytes != null) ...[
              const Text("Result Image:"),
              const SizedBox(height: 10),
              Image.memory(_resultBytes!, width: 250),
              const SizedBox(height: 30),
            ],
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
