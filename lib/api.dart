import 'dart:convert';
import 'dart:io';
import 'package:final_year_project2025/historyitemmodelclass.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:path/path.dart';

class ApiService {
  static const String baseUrl =
      "http://192.168.100.47:4321"; // Change according to your server

//-----------------------------------------------------------------------------------------
// ---------------------------------------------------------------------------------------

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "identifier": identifier,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"error": "Invalid credentials or server error"};
      }
    } catch (e) {
      return {"error": "Connection error: $e"};
    }
  }

  static Future<Map<String, dynamic>> signupUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/add_users");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Name": name,
          "Email": email,
          "Password": password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData.containsKey('user')) {
        return {
          'success': true,
          'name': responseData['user']['name'] ?? 'Guest',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      print("API error: $e");
      return {
        'success': false,
        'message': 'Server se connect nahi ho raha!',
      };
    }
  }

//---------------------  UPLOAD IMAGE SCREEN-----------------------------------

  static Future<Map<String, dynamic>?> uploadImage({
    required File image,
    required String userId,
  }) async {
    try {
      final uri = Uri.parse("$baseUrl/api/detect_image"); // ✅ Correct URI

      var request = http.MultipartRequest('POST', uri);

      // 🟢 Add image file
      request.files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );

      // 🟢 Add user_id field (Flask expects: `user_id`)
      request.fields['user_id'] = userId;

      // 🔃 Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Failed with status ${response.statusCode}"};
      }
    } catch (e) {
      print("Error uploading image: $e");
      return {"error": e.toString()};
    }
  }

// -------------------- history api ----------------------------------------

  Future<List<HistoryItem>> fetchHistory(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/view_history?user_id=$userId'),
    );
    print("🔁 API Status: ${response.statusCode}");
    print("📦 API Response: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => HistoryItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load history');
    }
  }
//--------------------- delete history one item ----------------------------------------

  Future<bool> deleteHistoryItem(int contentId) async {
    final url = Uri.parse('$baseUrl/delete_history_item');
    print("📡 Sending DELETE request for content_id: $contentId");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content_id': contentId}),
      );

      print("🧾 Response: ${response.statusCode}");
      print("🔙 Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("⚠️ Error in deleteHistoryItem: $e");
      return false;
    }
  }

//------------------------------- delete all history -----------------------------------------------

  Future<bool> deleteAllHistory(String userId) async {
    final uri = Uri.parse('$baseUrl/delete_all_history');
    final response = await http.post(uri, body: {
      'user_id': userId, // ✅ important
    });

    print("📡 delete_all_history response: ${response.statusCode}");
    print("📨 response body: ${response.body}");

    return response.statusCode == 200;
  }

//-------------------------------  sawap image api----------------------------------

  //  yeh deepfake wali api method hai
  Future<Uint8List?> generateDeepfake(
      File sourceImage, File targetImage, String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/add_face');

      var request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId
        ..files
            .add(await http.MultipartFile.fromPath('source', sourceImage.path))
        ..files
            .add(await http.MultipartFile.fromPath('target', targetImage.path));

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody.body);
        final base64Image = jsonData['image'];

        // ✅ Base64 ko decode kar rahe
        return base64Decode(base64Image);
      } else {
        print("❌ Deepfake API failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Exception in generateDeepfake: $e");
      return null;
    }
  }

//---------------------------- get fake image ----------------------------

  Future<List<Map<String, dynamic>>> fetchAllGeneratedImages() async {
    try {
      final uri = Uri.parse('$baseUrl/get_generated_images');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => {
                  "fileName": item["file_name"],
                  "imageBytes": base64Decode(item["base64_image"]),
                })
            .toList();
      } else {
        print("❌ Failed to fetch images: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("❌ Exception in fetchAllGeneratedImages: $e");
      return [];
    }
  }

//----------------------------  multiple face detection function ---------------------------------------

  static Future<Map<String, dynamic>?> detectFacesFromImage({
    required File image,
    required String userId,
  }) async {
    try {
      final uri =
          Uri.parse('$baseUrl/api/detect_multiple_image'); // ✅ updated endpoint
      final request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId
        ..fields['type'] = 'Image'
        ..files.add(await http.MultipartFile.fromPath('image', image.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Failed with status ${response.statusCode}'};
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      return {'error': 'Upload failed: $e'};
    }
  }

  // ----------------------gemerate multi_deepfake images---------------------------

  Future<Map<int, Uint8List>> generateMultiDeepfakeWithMapping(
    File sourceImage,
    List<File> targetImages,
    String userId,
  ) async {
    Map<int, Uint8List> resultMap = {};

    try {
      final uri = Uri.parse('$baseUrl/add_multiple_faces');

      var request = http.MultipartRequest('POST', uri)
        ..fields['user_id'] = userId
        ..files.add(await http.MultipartFile.fromPath(
          'source',
          sourceImage.path,
          filename: basename(sourceImage.path),
        ));

      for (File target in targetImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'targets',
          target.path,
          filename: basename(target.path),
        ));
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody.body);

        if (jsonData['results'] != null && jsonData['results'] is List) {
          for (var item in jsonData['results']) {
            final base64Image = item['image'];
            final index = item['target_index'];
            resultMap[index] = base64Decode(base64Image);
          }
        }
      } else {
        print("❌ Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }

    return resultMap;
  }
}
