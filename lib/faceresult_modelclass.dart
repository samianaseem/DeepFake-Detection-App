// -------------------- yeh multiple face ek image k liye use ho rha---------------------------

// class FaceResult {
//   final String faceImage;
//   final bool isReal;
//   final double confidenceScore;
//   final int faceNumber;

//   FaceResult({
//     required this.faceImage,
//     required this.isReal,
//     required this.confidenceScore,
//     required this.faceNumber,
//   });

//   factory FaceResult.fromJson(Map<String, dynamic> json) {
//     return FaceResult(
//       faceImage: json['result_image'] ?? '', // ✅ from result_image
//       isReal: (json['result']?.toLowerCase() == 'real')
//           ? true
//           : false, // ✅ "Fake"/"Real"
//       confidenceScore: (json['confidence_score'] ?? 0).toDouble(),
//       faceNumber: json['face_index'] ?? 0,
//     );
//   }
// }

class FaceResultinmultiple_image {
  final int contentId;
  final int resultId;
  final String result;
  final double confidence;
  final String resultImage;

  FaceResultinmultiple_image({
    required this.contentId,
    required this.resultId,
    required this.result,
    required this.confidence,
    required this.resultImage,
  });

  factory FaceResultinmultiple_image.fromJson(Map<String, dynamic> json) {
    return FaceResultinmultiple_image(
      contentId: json['content_id'],
      resultId: json['result_id'],
      result: json['result'],
      confidence: json['confidence_score'],
      resultImage: json['result_image'],
    );
  }
}
