import 'dart:async';
import '../models/navigation_model.dart';
import '../data/mock_data.dart';

abstract class INavigationService {
  Stream<NavigationStateData> get navigationStream;
  NavigationStateData get currentState;
  void updateTargetDestination(double x, double y);
  void triggerPathRecalculation();
}

class MockNavigationService implements INavigationService {
  final _controller = StreamController<NavigationStateData>.broadcast();
  late NavigationStateData _state;

  MockNavigationService() {
    _state = MockData.mockNavigationState;
    _startSimulatedMovement();
  }

  void _startSimulatedMovement() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      final step = (timer.tick % 5) * 0.4;
      final newX = 14.2 + step;
      final newY = 8.7 + step * 0.8;
      final remainingDist = (16.8 - step * 1.2).clamp(0.0, 50.0);

      _state = NavigationStateData(
        currentPosition: MapPoint(newX, newY),
        destination: _state.destination,
        pathPoints: _state.pathPoints,
        obstaclePoints: _state.obstaclePoints,
        navStatus: timer.tick % 4 == 0 ? 'OBSTACLE DETECTED' : 'NAVIGATING',
        currentSpeedMs: 1.2,
        distanceRemainingMeters: double.parse(remainingDist.toStringAsFixed(1)),
        obstacleCount: 4,
        headingDegrees: (42.0 + step * 2) % 360,
      );

      _controller.add(_state);
    });
  }

  @override
  Stream<NavigationStateData> get navigationStream => _controller.stream;

  @override
  NavigationStateData get currentState => _state;

  @override
  void updateTargetDestination(double x, double y) {
    _state = NavigationStateData(
      currentPosition: _state.currentPosition,
      destination: MapPoint(x, y),
      pathPoints: [
        _state.currentPosition,
        MapPoint((_state.currentPosition.x + x) / 2, (_state.currentPosition.y + y) / 2),
        MapPoint(x, y),
      ],
      obstaclePoints: _state.obstaclePoints,
      navStatus: 'CALCULATING PATH',
      currentSpeedMs: 0.0,
      distanceRemainingMeters: 22.4,
      obstacleCount: _state.obstacleCount,
      headingDegrees: _state.headingDegrees,
    );
    _controller.add(_state);

    Future.delayed(const Duration(milliseconds: 1500), () {
      _state = NavigationStateData(
        currentPosition: _state.currentPosition,
        destination: _state.destination,
        pathPoints: _state.pathPoints,
        obstaclePoints: _state.obstaclePoints,
        navStatus: 'NAVIGATING',
        currentSpeedMs: 1.2,
        distanceRemainingMeters: 22.4,
        obstacleCount: _state.obstacleCount,
        headingDegrees: _state.headingDegrees,
      );
      _controller.add(_state);
    });
  }

  @override
  void triggerPathRecalculation() {
    _state = NavigationStateData(
      currentPosition: _state.currentPosition,
      destination: _state.destination,
      pathPoints: _state.pathPoints,
      obstaclePoints: _state.obstaclePoints,
      navStatus: 'RE-CALCULATING PATH',
      currentSpeedMs: 0.0,
      distanceRemainingMeters: _state.distanceRemainingMeters,
      obstacleCount: _state.obstacleCount,
      headingDegrees: _state.headingDegrees,
    );
    _controller.add(_state);
  }
}
