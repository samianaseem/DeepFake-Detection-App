class HistoryItem_multipleface {
  final int contentId;
  final String path;
  final String type;
  final String status;
  final double confidence;
  final String resultImage;

  HistoryItem_multipleface({
    required this.contentId,
    required this.path,
    required this.type,
    required this.status,
    required this.confidence,
    required this.resultImage,
  });

  // factory HistoryItem_multipleface.fromJson(Map<String, dynamic> json) {
  //   return HistoryItem_multipleface(
  //     contentId: json['content_id'],
  //     path: json['path'] ?? '',
  //     type: json['type'],
  //     status: json['status'],
  //     confidence: (json['confidence'] as num).toDouble(),
  //     resultImage: json['result_image'],
  //   );
  factory HistoryItem_multipleface.fromJson(Map<String, dynamic> json) {
    return HistoryItem_multipleface(
      path: json['Path']?.toString() ?? '', // null-safe
      status: json['Status']?.toString() ?? 'Unknown',
      confidence: (json['Confidence'] != null)
          ? double.tryParse(json['Confidence'].toString()) ?? 0.0
          : 0.0,
      type: json['Type']?.toString() ?? 'N/A',
      contentId: int.tryParse(json['ContentID'].toString()) ?? 0,
      resultImage: '',
    );
  }
}
