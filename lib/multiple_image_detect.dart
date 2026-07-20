// import 'dart:io';
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:final_year_project2025/api.dart';
// import 'package:final_year_project2025/faceresult_modelclass.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// // class MultiImagePickerScreen extends StatefulWidget {
// //   const MultiImagePickerScreen({super.key});

// //   @override
// //   State<MultiImagePickerScreen> createState() => _MultiImagePickerScreenState();
// // }

// // class _MultiImagePickerScreenState extends State<MultiImagePickerScreen> {
// //   List<File> _selectedImages = [];

// //   Future<void> _pickImages() async {
// //     FilePickerResult? result = await FilePicker.platform.pickFiles(
// //       allowMultiple: true,
// //       type: FileType.image,
// //     );

// //     if (result != null && result.files.isNotEmpty) {
// //       setState(() {
// //         _selectedImages = result.paths.map((path) => File(path!)).toList();
// //       });
// //     } else {
// //       print("No images selected");
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Multiple Image Picker"),
// //       ),
// //       body: Column(
// //         children: [
// //           ElevatedButton(
// //             onPressed: _pickImages,
// //             child: const Text("Select Images"),
// //           ),
// //           Expanded(
// //             child: GridView.builder(
// //               itemCount: _selectedImages.length,
// //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                 crossAxisCount: 2,
// //               ),
// //               itemBuilder: (BuildContext context, int index) {
// //                 return Padding(
// //                   padding: const EdgeInsets.all(4.0),
// //                   child: Image.file(
// //                     _selectedImages[index],
// //                     fit: BoxFit.cover,
// //                   ),
// //                 );
// //               },
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }

// class MultiImagePickerScreen extends StatefulWidget {
//   const MultiImagePickerScreen({super.key});

//   @override
//   State<MultiImagePickerScreen> createState() => _MultiImagePickerScreenState();
// }

// class _MultiImagePickerScreenState extends State<MultiImagePickerScreen> {
//   List<File> _selectedImages = [];
//   List<FaceResultinmultiple_image> _results = [];
//   bool _isLoading = false;

//   Future<void> _pickImages() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//       type: FileType.image,
//     );

//     if (result != null && result.files.isNotEmpty) {
//       setState(() {
//         _selectedImages = result.paths.map((path) => File(path!)).toList();
//       });
//     }
//   }

//   Future<void> _uploadImages() async {
//     if (_selectedImages.isEmpty) return;

//     setState(() => _isLoading = true);

//     var uri = Uri.parse("${ApiService.baseUrl}/detect_multiple_images");
//     var request = http.MultipartRequest('POST', uri);
//     request.fields['user_id'] = '21'; // Set your user_id

//     for (var image in _selectedImages) {
//       var multipartFile =
//           await http.MultipartFile.fromPath("images", image.path);
//       request.files.add(multipartFile);
//     }

//     var response = await request.send();
//     if (response.statusCode == 200) {
//       var body = await response.stream.bytesToString();
//       var data = json.decode(body);
//       List results = data['results'];

//       setState(() {
//         _results =
//             results.map((e) => FaceResultinmultiple_image.fromJson(e)).toList();
//         _isLoading = false;
//       });
//     } else {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to upload images")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Multi-Image Detection")),
//       body: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: _pickImages,
//                 child: const Text("Select Images"),
//               ),
//               ElevatedButton(
//                 onPressed: _uploadImages,
//                 child: const Text("Upload & Detect"),
//               ),
//             ],
//           ),
//           if (_selectedImages.isNotEmpty)
//             SizedBox(
//               height: 100,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: _selectedImages.length,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: const EdgeInsets.all(4.0),
//                     child: Image.file(_selectedImages[index]),
//                   );
//                 },
//               ),
//             ),
//           const Divider(),
//           if (_isLoading) const CircularProgressIndicator(),
//           if (_results.isNotEmpty)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _results.length,
//                 itemBuilder: (context, index) {
//                   final result = _results[index];
//                   return Card(
//                     margin: const EdgeInsets.all(10),
//                     child: ListTile(
//                       leading: Image.network(
//                         "${ApiService.baseUrl}/uploads/results/${result.resultImage}",
//                         errorBuilder: (context, error, stackTrace) {
//                           return const Icon(Icons.broken_image);
//                         },
//                       ),
//                       title: Text("Result: ${result.result}"),
//                       subtitle: Text(
//                           "Confidence: ${(result.confidence * 100).toStringAsFixed(2)}%"),
//                     ),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:final_year_project2025/api.dart';
import 'package:final_year_project2025/faceresult_modelclass.dart';

class MultiImageDetectionScreen extends StatefulWidget {
  const MultiImageDetectionScreen({super.key});

  @override
  State<MultiImageDetectionScreen> createState() =>
      _MultiImageDetectionScreenState();
}

class _MultiImageDetectionScreenState extends State<MultiImageDetectionScreen> {
  // Yeh ek List<File> variable hota hai jisme tum saari selected images store karte ho:
  List<File> _selectedImages = [];
  List<FaceResultinmultiple_image> _results = [];
  bool _isLoading = false;

// Jee haan! ✅ Tumhara diya gaya code bilkul images pick karta hai aur unko File objects me store karta hai,
  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImages = result.paths.map((path) => File(path!)).toList();
      });
    }
  }

  Future<void> _uploadImages() async {
// ✅ Agar koi image select hi nahi ki gayi to function wahin ruk jaata hai, kuch nahi karta
    if (_selectedImages.isEmpty) return;

// ✅ App me loading spinner ya progress indicator dikha diya jata hai taake user ko lage ke upload ho raha hai.
    setState(() => _isLoading = true);

    var uri = Uri.parse("${ApiService.baseUrl}/detect_multiple_images");
    var request = http.MultipartRequest('POST', uri);
    request.fields['user_id'] = '21';

    for (var image in _selectedImages) {
      var multipartFile =
          await http.MultipartFile.fromPath("images", image.path);
      request.files.add(multipartFile);
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var body = await response.stream.bytesToString();
        var data = json.decode(body);
        List results = data['results'];

        setState(() {
          _results = results
              .map((e) => FaceResultinmultiple_image.fromJson(e))
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload images.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Multiple Image Detection")),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: _pickImages, child: const Text("Select Images")),
              ElevatedButton(
                  onPressed: _uploadImages,
                  child: const Text("Upload & Detect")),
            ],
          ),
          if (_selectedImages.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(_selectedImages[index]),
                ),
              ),
            ),
          const Divider(),
          if (_isLoading)
            const CircularProgressIndicator()
          else if (_results.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  final label = result.result;
                  final confidence =
                      (result.confidence * 100).toStringAsFixed(2);
                  // final imageUrl =
                  //     '${ApiService.baseUrl}/uploads/results/${result.resultImage}';
                  final imageUrl =
                      '${ApiService.baseUrl}/result/${result.resultImage}';

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListTile(
                      leading: Image.network(
                        imageUrl,
                        width: 60,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                      title: Text("Status: $label"),
                      subtitle: Text("Confidence: $confidence%"),
                      trailing: Chip(
                        label: Text(label),
                        backgroundColor:
                            label == 'Real' ? Colors.green : Colors.red,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
