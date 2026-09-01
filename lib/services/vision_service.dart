import 'dart:async';
import '../models/detection_model.dart';
import '../data/mock_data.dart';

abstract class IVisionService {
  Stream<List<DetectedObject>> get detectionsStream;
  List<DetectedObject> get currentDetections;
  String get perceptionStatus;
  void triggerEnvironmentAnalysis();
}

class MockVisionService implements IVisionService {
  final _controller = StreamController<List<DetectedObject>>.broadcast();
  final List<DetectedObject> _detections = MockData.mockDetections;
  String _status = 'PERCEPTION ACTIVE (SIMULATION)';

  MockVisionService() {
    _startPerceptionLoop();
  }

  void _startPerceptionLoop() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      _controller.add(_detections);
    });
  }

  @override
  Stream<List<DetectedObject>> get detectionsStream => _controller.stream;

  @override
  List<DetectedObject> get currentDetections => _detections;

  @override
  String get perceptionStatus => _status;

  @override
  void triggerEnvironmentAnalysis() {
    _status = 'ANALYZING SPATIAL DEPTH MAP...';
    _controller.add(_detections);

    Future.delayed(const Duration(milliseconds: 1200), () {
      _status = 'PERCEPTION UPDATED (3 OBJECTS TRACKED)';
      _controller.add(_detections);
    });
  }
}
