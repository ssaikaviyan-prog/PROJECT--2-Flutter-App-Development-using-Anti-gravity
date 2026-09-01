class DetectedObject {
  final String label;
  final double confidence; // e.g. 0.96 for 96%
  final double x; // normalized 0..1
  final double y; // normalized 0..1
  final double width;
  final double height;
  final String distanceMeters;
  final String category;

  const DetectedObject({
    required this.label,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.distanceMeters,
    required this.category,
  });
}
