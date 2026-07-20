// import 'dart:convert';
// import 'package:final_year_project2025/api.dart';
// import 'package:final_year_project2025/highlightdeepfake_history.dart';
// import 'package:final_year_project2025/multiimage_dtect_modelclass.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class HistoryScreen_2 extends StatefulWidget {
//   const HistoryScreen_2({super.key});

//   @override
//   _HistoryScreenState createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen_2> {
//   late Future<List<HistoryItem_multipleface>> futureHistory;

//   @override
//   void initState() {
//     super.initState();
//     futureHistory = fetchHistory(21); // Replace with dynamic user ID
//   }

//   Future<List<HistoryItem_multipleface>> fetchHistory(int userId) async {
//     final response = await http.get(
//         Uri.parse('${ApiService.baseUrl}/get_history_multipleface/$userId'));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final List items = data['history'];
//       return items.map((e) => HistoryItem_multipleface.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to load history');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Detection History')),
//       body: FutureBuilder<List<HistoryItem_multipleface>>(
//         future: futureHistory,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No history found'));
//           } else {
//             final history = snapshot.data!;
//             return ListView.builder(
//               itemCount: history.length,
//               itemBuilder: (context, index) {
//                 final item = history[index];
//                 return Card(
//                   margin: EdgeInsets.all(8),
//                   elevation: 3,
//                   child: ListTile(
//                     leading: Image.network(
//                         '${ApiService.baseUrl}/uploads/${item.path}',
//                         width: 60,
//                         height: 60,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                       return Image.asset(
//                         'assets/download.png', // 👈 apne assets folder me koi default image
//                         width: 60,
//                         height: 60,
//                         fit: BoxFit.cover,
//                       );
//                     }),
//                     title: Text('Status: ${item.status}'),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                             'Confidence: ${item.confidence.toStringAsFixed(2)}'),
//                         Text('Type: ${item.type}'),
//                       ],
//                     ),
//                     trailing: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) =>
//                                 HighlightScreen(contentId: item.contentId),
//                           ),
//                         );
//                       },
//                       child: Text('Highlight'),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
// 📁 File: history_screen.dart
import 'dart:convert';
import 'package:final_year_project2025/highlightdeepfake_history.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_year_project2025/api.dart';

class HistoryItemMultipleFace {
  final int contentId;
  final String path;
  final String status;
  final double confidence;
  final String type;

  HistoryItemMultipleFace({
    required this.contentId,
    required this.path,
    required this.status,
    required this.confidence,
    required this.type,
  });

  factory HistoryItemMultipleFace.fromJson(Map<String, dynamic> json) {
    return HistoryItemMultipleFace(
      contentId: json['content_id'],
      path: json['path'],
      status: json['status'],
      confidence: (json['confidence'] ?? 0).toDouble(),
      type: json['type'] ?? 'Unknown',
    );
  }
}

class HistoryScreen2 extends StatefulWidget {
  const HistoryScreen2({super.key});

  @override
  State<HistoryScreen2> createState() => _HistoryScreen2State();
}

class _HistoryScreen2State extends State<HistoryScreen2> {
  late Future<List<HistoryItemMultipleFace>> futureHistory;

  @override
  void initState() {
    super.initState();
    loadUserHistory();
  }

  void loadUserHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      setState(() {
        futureHistory = fetchHistory(int.parse(userId));
      });
    }
  }

  Future<List<HistoryItemMultipleFace>> fetchHistory(int userId) async {
    final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/get_history_multipleface/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List items = data['history'];
      return items.map((e) => HistoryItemMultipleFace.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detection History')),
      body: FutureBuilder<List<HistoryItemMultipleFace>>(
        future: futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No history found'));
          } else {
            final history = snapshot.data!;
            return ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 3,
                  child: ListTile(
                    leading: Image.network(
                      '${ApiService.baseUrl}/uploads/results/\${item.path}',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/download.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    title: Text('Status: \${item.status}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confidence: \${item.confidence.toStringAsFixed(2)}',
                        ),
                        Text(
                          'Type: \${item.type}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HighlightScreen(
                              contentId: item.contentId,
                            ),
                          ),
                        );
                      },
                      child: const Text('Highlight'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
