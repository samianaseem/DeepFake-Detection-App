// import 'dart:io';

// import 'package:final_year_project2025/api.dart';
// import 'package:final_year_project2025/multiple_face_detect.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DetectImageScreen extends StatefulWidget {
//   const DetectImageScreen({super.key});

//   @override
//   State<DetectImageScreen> createState() => _DetectImageScreenState();
// }

// class _DetectImageScreenState extends State<DetectImageScreen> {
//   File? _image;
//   bool _isLoading = false;
//   Map<String, dynamic>? _resultData;
//   String? _userName;
//   final ImagePicker _picker = ImagePicker();

//   Future<void> _pickImage() async {
//     try {
//       final XFile? pickedFile =
//           await _picker.pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() {
//           _image = File(pickedFile.path);
//           _resultData = null;
//         });
//       }
//     } catch (e) {
//       print("Image pick error: $e");
//     }
//   }

//   Future<void> _uploadImage() async {
//     if (_image == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image first.')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString('userId');
//       final userName = prefs.getString('userName');

//       if (userId == null || userName == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('User info missing. Please login again.')),
//         );
//         setState(() => _isLoading = false);
//         return;
//       }

//       final response =
//           await ApiService.uploadImage(image: _image!, userId: userId);
//       debugPrint('Upload response: $response');

//       if (response != null && response['details'] != null) {
//         setState(() {
//           _resultData = {
//             'userId': userId,
//             'details': response['details'],
//           };
//           _userName = userName;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text(
//                   'Image upload failed: ${response?['error'] ?? 'Unknown error'}')),
//         );
//       }
//     } catch (e) {
//       debugPrint('Unexpected error in _uploadImage: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Unexpected error occurred.')),
//       );
//     }

//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 129, 209, 218),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Opacity(
//               opacity: 0.1,
//               child: Image.asset('assets/logo.png', fit: BoxFit.cover),
//             ),
//           ),
//           if (_isLoading) const Center(child: CircularProgressIndicator()),
//           if (!_isLoading && _resultData == null) _buildPickerView(),
//           if (!_isLoading && _resultData != null) _buildResultView(),
//         ],
//       ),
//     );
//   }

//   Widget _buildPickerView() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           _buildHeader(),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Container(
//                   width: 200,
//                   height: 200,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: _image == null
//                       ? Icon(Icons.cloud_upload,
//                           size: 50, color: Colors.grey[600])
//                       : Image.file(_image!, fit: BoxFit.cover),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _pickImage,
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(200, 50),
//                     foregroundColor: Colors.black,
//                     backgroundColor: const Color.fromARGB(255, 129, 209, 218),
//                     shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.zero),
//                   ),
//                   child: const Text('UPLOAD IMAGE',
//                       style: TextStyle(fontSize: 16)),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: _image == null ? null : _uploadImage,
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(200, 50),
//                     foregroundColor: Colors.black,
//                     backgroundColor: const Color.fromARGB(255, 129, 209, 218),
//                     shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.zero),
//                   ),
//                   child: const Text('DETECT', style: TextStyle(fontSize: 16)),
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const FaceDetectionScreen()),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(200, 50),
//                     foregroundColor: Colors.black,
//                     backgroundColor: const Color.fromARGB(255, 129, 209, 218),
//                     shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.zero),
//                   ),
//                   child: const Text('DETECT MULTIPLE FACES',
//                       style: TextStyle(fontSize: 16)),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultView() {
//     final details = _resultData?['details'];
//     if (details == null) {
//       return const Center(
//         child: Text("No result details returned from server.",
//             style: TextStyle(fontSize: 16)),
//       );
//     }

//     final label = details['result'] ?? 'Unknown';
//     final confidence = (details['confidence_score'] * 100).toStringAsFixed(2);
//     final faceImageName = details['result_image'];
//     // final faceUrl =
//     //     '$baseUrl/result/$faceImageName'; // <-- Update this if your backend URL is different
//     final faceUrl = '${ApiService.baseUrl}/result/$faceImageName';
//     print('Face URL: $faceUrl');

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildHeader(),
//           const SizedBox(height: 20),
//           Center(
//             child: Chip(
//               label: Text(
//                 'Status: $label',
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               backgroundColor: label == 'Real' ? Colors.green : Colors.red,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Text('Confidence: $confidence %',
//               style: const TextStyle(fontSize: 16)),
//           const SizedBox(height: 12),
//           Text('User Name: $_userName', style: const TextStyle(fontSize: 16)),
//           Text('User ID: ${_resultData!['userId']}',
//               style: const TextStyle(fontSize: 16)),
//           const SizedBox(height: 20),
//           if (faceImageName != null)
//             Center(
//               child: Container(
//                 width: 150,
//                 height: 150,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.black, width: 2),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Image.network(
//                   faceUrl,
//                   fit: BoxFit.cover,
//                   errorBuilder: (_, __, ___) =>
//                       const Icon(Icons.broken_image, size: 50),
//                 ),
//               ),
//             ),
//           const SizedBox(height: 24),
//           Center(
//             child: ElevatedButton(
//               onPressed: () => setState(() => _resultData = null),
//               child: const Text('Test another image'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       color: const Color.fromARGB(255, 129, 209, 218),
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: const [
//           SizedBox(height: 8),
//           Text.rich(
//             TextSpan(
//               children: [
//                 TextSpan(
//                   text: 'Scan & Detect ',
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black),
//                 ),
//                 TextSpan(
//                   text: 'Deepfake ',
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red),
//                 ),
//                 TextSpan(
//                   text: 'Content',
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black),
//                 ),
//               ],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 8),
//           Text('Choose Your Image',
//               style: TextStyle(fontSize: 16, color: Colors.black54)),
//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:final_year_project2025/api.dart';
import 'package:final_year_project2025/multiple_face_detect.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetectImageScreen extends StatefulWidget {
  const DetectImageScreen({super.key});

  @override
  State<DetectImageScreen> createState() => _DetectImageScreenState();
}

class _DetectImageScreenState extends State<DetectImageScreen> {
  File? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _resultData;
  String? _userName;
  final ImagePicker _picker = ImagePicker();
  String _language = '';

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _resultData = null;
        });
      }
    } catch (e) {
      print("Image pick error: $e");
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final userName = prefs.getString('userName');

      if (userId == null || userName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User info missing. Please login again.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final response =
          await ApiService.uploadImage(image: _image!, userId: userId);
      debugPrint('Upload response: $response');

      if (response != null && response['details'] != null) {
        setState(() {
          _resultData = {
            'userId': userId,
            'details': response['details'],
          };
          _userName = userName;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Image upload failed: ${response?['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      debugPrint('Unexpected error in _uploadImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected error occurred.')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 129, 209, 218),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/logo.png', fit: BoxFit.cover),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (!_isLoading && _resultData == null) _buildPickerView(),
          if (!_isLoading && _resultData != null) _buildResultView(),
        ],
      ),
    );
  }

  Widget _buildPickerView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _image == null
                      ? Icon(Icons.cloud_upload,
                          size: 50, color: Colors.grey[600])
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('UPLOAD IMAGE',
                      style: TextStyle(fontSize: 16)),
                ),
                // const SizedBox(height: 16),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     ElevatedButton(onPressed: () {}, child: const Text("Nose")),
                //     ElevatedButton(onPressed: () {}, child: const Text("Lips")),
                //     ElevatedButton(onPressed: () {}, child: const Text("Eyes")),
                //   ],
                // ),
                // Radio buttons for language selection
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Nose'),
                        value: 'Nose',
                        groupValue: _language,
                        onChanged: (String? value) {
                          setState(() {
                            _language = value!;
                          });
                          // _saveLanguagePreference(value!); // Save preference
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Lips'),
                        value: 'Lips',
                        groupValue: _language,
                        onChanged: (String? value) {
                          setState(() {
                            _language = value!;
                          });
                          // _saveLanguagePreference(value!); // Save preference
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Eyes'),
                        value: 'Eyes',
                        groupValue: _language,
                        onChanged: (String? value) {
                          setState(() {
                            _language = value!;
                          });
                          // _saveLanguagePreference(value!); // Save preference
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _image == null ? null : _uploadImage,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('DETECT', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FaceDetectionScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                    foregroundColor: Colors.black,
                    backgroundColor: const Color.fromARGB(255, 129, 209, 218),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('DETECT MULTIPLE FACES',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final details = _resultData?['details'];
    if (details == null) {
      return const Center(
        child: Text("No result details returned from server.",
            style: TextStyle(fontSize: 16)),
      );
    }

    final label = details['result'] ?? 'Unknown';
    final confidence = (details['confidence_score'] * 100).toStringAsFixed(2);
    final faceImageName = details['result_image'];
    // final faceUrl =
    //     '$baseUrl/result/$faceImageName'; // <-- Update this if your backend URL is different
    final faceUrl = '${ApiService.baseUrl}/result/$faceImageName';
    print('Face URL: $faceUrl');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Center(
            child: Chip(
              label: Text(
                'Status: $label',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              backgroundColor: label == 'Real' ? Colors.green : Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 12),
          Text('Confidence: $confidence %',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text('User Name: $_userName', style: const TextStyle(fontSize: 16)),
          // Text('User ID: ${_resultData!['userId']}',
          Text('User ID: ${_resultData!['userId']}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),
          if (faceImageName != null)
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.network(
                  faceUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () => setState(() => _resultData = null),
              child: const Text('Test another image'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color.fromARGB(255, 129, 209, 218),
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Scan & Detect ',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                TextSpan(
                  text: 'Deepfake ',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
                TextSpan(
                  text: 'Content',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text('Choose Your Image',
              style: TextStyle(fontSize: 16, color: Colors.black54)),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}


// Widget _build_result_feature() {
//     return Container(
//       color: const Color.fromARGB(255, 129, 209, 218),
//       width: double.infinity,
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: const [
//           SizedBox(height: 8),
//           Text.rich(
//             TextSpan(
//               children: [
//                 TextSpan(
//                   text: 'Scan & Detect ',
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black),
//                 ),
//                 TextSpan(
//                   text: 'Deepfake ',
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red),
//                 ),
//                 TextSpan(
//                   text: 'Content',
//                   style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black),
//                 ),
//               ],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           SizedBox(height: 8),
//           Text('Choose Your Image',
//               style: TextStyle(fontSize: 16, color: Colors.black54)),
//           SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

