// ----------------------  single image history show
class HistoryItem {
  final String? fileName;
  final int? contentId;
  final int? id;
  final int? resultId;
  final String? status;
  final String? type;
  final String datetime; // 👈 add this

  HistoryItem({
    this.contentId,
    this.fileName,
    this.id,
    this.resultId,
    this.status,
    this.type,
    required this.datetime,
  });

  // factory HistoryItem.fromJson(Map<String, dynamic> json) {
  //   print("🧩 Incoming JSON: $json"); // ✅ Debugging line
  //   return HistoryItem(
  //     contentId: json['id'],
  //     fileName: json['file_name'],
  //     id: json['id'],
  //     resultId: json['result_id'] ?? '',
  //     status: json['status'],
  //     type: json['type'],
  //     datetime: json['datetime'] ?? '', // 👈 fetch it
  //     // add karo agar backend bhejta hai
  //   );
  // }
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    print("🧩 Incoming JSON: $json");

    return HistoryItem(
      contentId:
          json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      fileName: json['file_name'],
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      resultId: json['result_id'] == null
          ? null
          : (json['result_id'] is int
              ? json['result_id']
              : int.tryParse(json['result_id'].toString())),
      status: json['status'],
      type: json['type'],
      datetime: json['datetime'] ?? 'Unknown',
    );
  }
}
