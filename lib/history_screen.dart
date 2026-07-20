// import 'package:final_year_project2025/multiface_history.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:final_year_project2025/api.dart';
// import 'package:final_year_project2025/historyitemmodelclass.dart';
// import 'result_detail_screen.dart';

// class HistoryScreen extends StatefulWidget {
//   const HistoryScreen({super.key});
//   @override
//   State<HistoryScreen> createState() => _HistoryScreenState();
// }

// class _HistoryScreenState extends State<HistoryScreen> {
//   final api = ApiService();
//   String? userId;
//   List<HistoryItem> historyList = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadUserId();
//   }

//   Future<void> _loadUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     userId = prefs.getString('userId');
//     print("🧾 Loaded userId: $userId");

//     if (userId != null) {
//       final fetchedList = await api.fetchHistory(userId!);
//       setState(() {
//         historyList = fetchedList;
//       });
//     }
//   }

//   Future<void> _deleteItem(int index) async {
//     final item = historyList[index];
//     print("🗑 Trying to delete content_id: ${item.contentId}");

//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Confirm Deletion"),
//         content:
//             const Text("Are you sure you want to delete this history item?"),
//         actions: [
//           TextButton(
//             child: const Text("Cancel"),
//             onPressed: () => Navigator.pop(context, false),
//           ),
//           ElevatedButton(
//             child: const Text("Delete"),
//             onPressed: () => Navigator.pop(context, true),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true && item.contentId != null) {
//       final success = await api.deleteHistoryItem(item.contentId!);
//       print("✅ API Delete Response: $success");

//       if (success) {
//         setState(() {
//           historyList.removeAt(index);
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Item deleted successfully")),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to delete item")),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final h = MediaQuery.of(context).size.height;

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
//             top: h * .4,
//             child: Opacity(
//               opacity: .08,
//               child: Image.asset('assets/logo.png', fit: BoxFit.cover),
//             ),
//           ),
//           userId == null
//               ? const Center(child: CircularProgressIndicator())
//               : Column(
//                   children: [
//                     Container(
//                       height: h * .4,
//                       width: double.infinity,
//                       color: const Color.fromARGB(255, 129, 209, 218),
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.asset('assets/logo.png',
//                               width: 140, height: 140),
//                           const SizedBox(height: 12),
//                           const Text(
//                             "HISTORY",
//                             style: TextStyle(
//                                 fontSize: 26,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black),
//                           ),
//                           const SizedBox(height: 6),
//                           const Text(
//                             "Your Previous Record Of Deepfake Content",
//                             style:
//                                 TextStyle(fontSize: 15, color: Colors.black87),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: historyList.isEmpty
//                           ? const Center(child: Text('No history found.'))
//                           : ListView.separated(
//                               padding: const EdgeInsets.all(16),
//                               itemCount: historyList.length,
//                               separatorBuilder: (_, __) =>
//                                   const SizedBox(height: 8),
//                               itemBuilder: (context, i) {
//                                 final item = historyList[i];
//                                 // final fileName = (item.fileName != null &&
//                                 //         item.fileName!.startsWith('result_'))
//                                 //     ? item.fileName!
//                                 //     : 'result_${item.fileName ?? 'missing.png'}';
//                                 // final imageUrl =
//                                 //     '${ApiService.baseUrl}/result/$fileName';
//                                 final rawName = item.fileName ?? 'missing.png';
//                                 String fileName = rawName;

//                                 if (!fileName.startsWith('result_')) {
//                                   fileName = 'result_$fileName';
//                                 }
//                                 if (!fileName.contains('.')) {
//                                   fileName += '.jpg';
//                                 }

// // FIXED HERE 👇
//                                 final imageUrl =
//                                     '${ApiService.baseUrl}/result/$fileName';

//                                 print("📷 Trying to load image: $imageUrl");

//                                 return GestureDetector(
//                                   onTap: () {
//                                     print(
//                                         "📂 Opening detail for item index $i");
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (_) =>
//                                             HistoryDetailScreen(item: item),
//                                       ),
//                                     );
//                                   },
//                                   child: Container(
//                                     padding: const EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(8),
//                                       boxShadow: const [
//                                         BoxShadow(
//                                           color: Colors.grey,
//                                           blurRadius: 4,
//                                           offset: Offset(2, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Row(
//                                       children: [
//                                         // Thumbnail
//                                         ClipRRect(
//                                           borderRadius:
//                                               BorderRadius.circular(6),
//                                           child: Image.network(
//                                             imageUrl,
//                                             width: 50,
//                                             height: 50,
//                                             fit: BoxFit.cover,
//                                             errorBuilder: (_, __, ___) {
//                                               return Container(
//                                                 width: 50,
//                                                 height: 50,
//                                                 color: Colors.grey[300],
//                                                 child: Image.asset(
//                                                   'assets/download.png',
//                                                   fit: BoxFit.cover,
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         // Content text
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment.start,
//                                             children: [
//                                               const Text(
//                                                 "Content: Image",
//                                                 style: TextStyle(
//                                                     fontSize: 16,
//                                                     fontWeight:
//                                                         FontWeight.w500),
//                                               ),
//                                               const SizedBox(height: 6),
//                                               Row(
//                                                 children: [
//                                                   const Text("Result: ",
//                                                       style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.w500)),
//                                                   Text(
//                                                     item.status ?? 'Unknown',
//                                                     style: TextStyle(
//                                                       color:
//                                                           item.status == 'Real'
//                                                               ? Colors.green
//                                                               : Colors.red,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         // Delete button
//                                         IconButton(
//                                           icon: const Icon(Icons.delete,
//                                               color: Colors.red),
//                                           onPressed: () {
//                                             print(
//                                                 "🧨 Delete button pressed at index $i");
//                                             _deleteItem(i);
//                                           },
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                     ),
//                     SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => HistoryScreen_2()),
//                         );
//                       },
//                       child: Text('multiface_detection_history'),
//                     ),
//                     // delete all history code idr hai
//                     if (historyList.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 16, vertical: 10),
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.delete_forever),
//                           label: const Text("Delete All History"),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.red,
//                             foregroundColor: Colors.white,
//                           ),
//                           onPressed: () async {
//                             final confirm = await showDialog<bool>(
//                               context: context,
//                               builder: (_) => AlertDialog(
//                                 title: const Text("Confirm Deletion"),
//                                 content: const Text(
//                                     "Are you sure you want to delete all history?"),
//                                 actions: [
//                                   TextButton(
//                                     child: const Text("Cancel"),
//                                     onPressed: () =>
//                                         Navigator.pop(context, false),
//                                   ),
//                                   ElevatedButton(
//                                     child: const Text("Delete All"),
//                                     onPressed: () =>
//                                         Navigator.pop(context, true),
//                                   ),
//                                 ],
//                               ),
//                             );

//                             if (confirm == true) {
//                               final success =
//                                   await api.deleteAllHistory(userId!);
//                               if (success) {
//                                 setState(() {
//                                   historyList.clear();
//                                 });
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content: Text("All history deleted.")),
//                                 );
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content: Text(
//                                           "Failed to delete all history.")),
//                                 );
//                               }
//                             }
//                           },
//                         ),
//                       ),
//                   ],
//                 ),
//         ],
//       ),
//     );
//   }
// }

import 'package:final_year_project2025/multiface_history.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:final_year_project2025/api.dart';
import 'package:final_year_project2025/historyitemmodelclass.dart';
import 'result_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final api = ApiService();
  String? userId;
  List<HistoryItem> historyList = [];
  String selectedFilter = 'All'; // All, Real, Fake

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    print("🧾 Loaded userId: $userId");

    if (userId != null) {
      final fetchedList = await api.fetchHistory(userId!);
      if (mounted) {
        setState(() {
          historyList = fetchedList;
        });
      }
    }
  }

  Future<void> _deleteItem(int index) async {
    final item = historyList[index];
    print("🗑 Trying to delete content_id: ${item.contentId}");

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content:
            const Text("Are you sure you want to delete this history item?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true && item.contentId != null) {
      final success = await api.deleteHistoryItem(item.contentId!);
      print("✅ API Delete Response: $success");

      if (success) {
        setState(() {
          historyList.remove(item);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item deleted successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete item")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    // Apply filter
    final filteredList = selectedFilter == 'All'
        ? historyList
        : historyList.where((item) => item.status == selectedFilter).toList();

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
            top: h * .4,
            child: Opacity(
              opacity: .08,
              child: Image.asset('assets/logo.png', fit: BoxFit.cover),
            ),
          ),
          userId == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      height: h * .4,
                      width: double.infinity,
                      color: const Color.fromARGB(255, 129, 209, 218),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/logo.png',
                              width: 140, height: 140),
                          const SizedBox(height: 12),
                          const Text(
                            "HISTORY",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Your Previous Record Of Deepfake Content",
                            style:
                                TextStyle(fontSize: 15, color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // FILTER BUTTONS
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: ['All', 'Real', 'Fake'].map((filter) {
                          final isSelected = selectedFilter == filter;
                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedFilter = filter;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isSelected ? Colors.blue : Colors.grey[300],
                              foregroundColor:
                                  isSelected ? Colors.white : Colors.black,
                            ),
                            child: Text(filter),
                          );
                        }).toList(),
                      ),
                    ),

                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text('No history found.'))
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final item = filteredList[i];
                                final rawName = item.fileName ?? 'missing.png';
                                String fileName = rawName;

                                if (!fileName.startsWith('result_')) {
                                  fileName = 'result_$fileName';
                                }
                                if (!fileName.contains('.')) {
                                  fileName += '.jpg';
                                }

                                final imageUrl =
                                    '${ApiService.baseUrl}/result/$fileName';

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            HistoryDetailScreen(item: item),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.grey,
                                            blurRadius: 4,
                                            offset: Offset(2, 2)),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: Image.network(
                                            imageUrl,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) {
                                              return Container(
                                                width: 50,
                                                height: 50,
                                                color: Colors.grey[300],
                                                child: Image.asset(
                                                    'assets/download.png',
                                                    fit: BoxFit.cover),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Content: Image",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Text("Result: ",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  Text(
                                                    item.status ?? 'Unknown',
                                                    style: TextStyle(
                                                      color:
                                                          item.status == 'Real'
                                                              ? Colors.green
                                                              : Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _deleteItem(i),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => HistoryScreen2()));
                      },
                      child: const Text('multiface_detection_history'),
                    ),

                    if (historyList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete_forever),
                          label: const Text("Delete All History"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Confirm Deletion"),
                                content: const Text(
                                    "Are you sure you want to delete all history?"),
                                actions: [
                                  TextButton(
                                    child: const Text("Cancel"),
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                  ),
                                  ElevatedButton(
                                    child: const Text("Delete All"),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              final success =
                                  await api.deleteAllHistory(userId!);
                              if (success) {
                                setState(() {
                                  historyList.clear();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("All history deleted.")),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          "Failed to delete all history.")),
                                );
                              }
                            }
                          },
                        ),
                      ),
                  ],
                ),
        ],
      ),
    );
  }
}
