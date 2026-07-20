import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class UploadScreenvideo extends StatefulWidget {
  const UploadScreenvideo({super.key});

  @override
  State<UploadScreenvideo> createState() => _UploadScreenvideoState();
}

class _UploadScreenvideoState extends State<UploadScreenvideo> {
  File? _videoFile;
  VideoPlayerController? _videoController;
  bool isLoading = false;
  List<dynamic> frameResults = [];
  String? overallResult;
  final String baseUrl = 'http://192.168.100.6:5000'; // ← your IP

  Future<void> pickVideoFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
        _videoController?.dispose();
        _videoController = VideoPlayerController.file(_videoFile!)
          ..initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
      });
    } else {
      print('⚠️ No video selected.');
    }
  }

  Future<void> uploadVideoAndDetect() async {
    if (_videoFile == null) return;
    setState(() {
      isLoading = true;
      overallResult = null;
      frameResults.clear();
    });

    try {
      var uri = Uri.parse('$baseUrl/api/detect_video');
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = '1';
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        _videoFile!.path,
        filename: basename(_videoFile!.path),
      ));

      var response = await request.send();
      var responseData = await http.Response.fromStream(response);
      var jsonData = jsonDecode(responseData.body);

      if (response.statusCode == 200) {
        final details = jsonData['details'];
        setState(() {
          overallResult = details['result'];
          frameResults = details['frame_results'];
        });
      } else {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text("Server Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text("Exception: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 129, 209, 218),
        elevation: 0,
        title: const Text("Video Deepfake Detector",
            style: TextStyle(color: Colors.black)),
      ),
      body: Stack(
        children: [
          if (isLoading) const Center(child: CircularProgressIndicator()),
          if (!isLoading)
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: pickVideoFromGallery,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text("Select Video from Gallery"),
                  ),
                  if (_videoController != null &&
                      _videoController!.value.isInitialized)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: uploadVideoAndDetect,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    child: const Text("Detect Deepfake"),
                  ),
                  if (overallResult != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Overall Result: $overallResult",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: overallResult == 'Fake'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text("Frame-wise Detection Results:",
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: frameResults.length,
                            itemBuilder: (context, index) {
                              var frame = frameResults[index];
                              return Card(
                                elevation: 2,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 16),
                                child: ListTile(
                                  leading: Image.network(
                                    '$baseUrl/uploads/results/${frame['frame']}',
                                    width: 60,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image),
                                  ),
                                  title: Text("Frame ${index + 1}"),
                                  subtitle: Text(
                                    "Result: ${frame['status']}, Confidence: ${(frame['confidence_score'] as num).toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: frame['status'] == 'Fake'
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
