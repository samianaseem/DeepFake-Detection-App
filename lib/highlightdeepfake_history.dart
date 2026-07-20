// import 'package:final_year_project2025/api.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class HighlightScreen extends StatefulWidget {
//   final int contentId;

//   const HighlightScreen({super.key, required this.contentId});

//   @override
//   _HighlightScreenState createState() => _HighlightScreenState();
// }

// class _HighlightScreenState extends State<HighlightScreen> {
//   List<dynamic> faces = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchFaceResults();
//   }

//   Future<void> fetchFaceResults() async {
//     final url =
//         Uri.parse('${ApiService.baseUrl}/get_face_results/${widget.contentId}');
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           faces = data['results'];
//           isLoading = false;
//         });
//       } else {
//         print("API Error: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching face results: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Highlighted Deepfakes')),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : faces.isEmpty
//               ? const Center(child: Text('No faces detected.'))
//               : ListView.builder(
//                   itemCount: faces.length,
//                   itemBuilder: (context, index) {
//                     final face = faces[index];
//                     return Card(
//                       margin: const EdgeInsets.all(8),
//                       child: ListTile(
//                         leading: Image.network(
//                           '${ApiService.baseUrl}/result/${face['result_image']}',
//                           width: 60,
//                           height: 60,
//                           fit: BoxFit.cover,
//                         ),
//                         title: Text('Status: ${face['status']}'),
//                         subtitle: Text(
//                             'Confidence: ${face['confidence'].toStringAsFixed(3)}'),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:final_year_project2025/api.dart';

class FaceResult {
  final String faceImage;
  final bool isReal;
  final double confidence;
  final int faceIndex;

  FaceResult({
    required this.faceImage,
    required this.isReal,
    required this.confidence,
    required this.faceIndex,
  });

  factory FaceResult.fromJson(Map<String, dynamic> json) {
    return FaceResult(
      faceImage: json['result_image'],
      isReal: json['status'].toLowerCase() == 'real',
      confidence: (json['confidence'] ?? 0).toDouble(),
      faceIndex: json['face_index'],
    );
  }
}

class HighlightScreen extends StatefulWidget {
  final int contentId;

  const HighlightScreen({super.key, required this.contentId});

  @override
  State<HighlightScreen> createState() => _HighlightScreenState();
}

class _HighlightScreenState extends State<HighlightScreen> {
  bool _isLoading = true;
  List<FaceResult> _faceResults = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFaces();
  }

  Future<void> _fetchFaces() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/get_face_results/${widget.contentId}'),
      );

      final data = jsonDecode(response.body);
      final List results = data['results'] ?? [];

      setState(() {
        _faceResults = results.map((e) => FaceResult.fromJson(e)).toList();
        _isLoading = false;

        if (_faceResults.isEmpty) {
          _errorMessage = "No face detected.";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading faces';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Highlight Faces')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _faceResults.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemBuilder: (context, index) {
                    final face = _faceResults[index];
                    return Card(
                      elevation: 4,
                      child: Column(
                        children: [
                          Expanded(
                            child: Image.network(
                              '${ApiService.baseUrl}/result/${face.faceImage}',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('Face ${face.faceIndex}'),
                                Text(
                                  face.isReal ? 'Real' : 'Fake',
                                  style: TextStyle(
                                      color: face.isReal
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    'Confidence: ${(face.confidence * 100).toStringAsFixed(2)}%'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
