class MapPoint {
  final double x;
  final double y;

  const MapPoint(this.x, this.y);
}

class NavigationStateData {
  final MapPoint currentPosition;
  final MapPoint destination;
  final List<MapPoint> pathPoints;
  final List<MapPoint> obstaclePoints;
  final String navStatus; // e.g. 'SCANNING ENVIRONMENT', 'OBSTACLE DETECTED', 'NAVIGATING'
  final double currentSpeedMs;
  final double distanceRemainingMeters;
  final int obstacleCount;
  final double headingDegrees;

  const NavigationStateData({
    required this.currentPosition,
    required this.destination,
    required this.pathPoints,
    required this.obstaclePoints,
    required this.navStatus,
    required this.currentSpeedMs,
    required this.distanceRemainingMeters,
    required this.obstacleCount,
    required this.headingDegrees,
  });
}
