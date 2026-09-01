import 'dart:async';
import '../models/component_model.dart';
import '../models/telemetry_model.dart';
import '../data/mock_data.dart';

abstract class IRobotService {
  Stream<TelemetryData> get telemetryStream;
  TelemetryData get currentTelemetry;
  List<RobotComponent> get components;
  void toggleSimulationMode();
}

class MockRobotService implements IRobotService {
  final _controller = StreamController<TelemetryData>.broadcast();
  late TelemetryData _currentTelemetry;

  MockRobotService() {
    _currentTelemetry = TelemetryData.initialMock();
    _startTelemetryLoop();
  }

  void _startTelemetryLoop() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      // Simulate microscopic sensor fluctuations
      final nextTemp = 38.0 + (timer.tick % 5) * 0.2;
      final nextCpu = 22.0 + (timer.tick % 7) * 0.8;

      _currentTelemetry = TelemetryData(
        batteryPercentage: 85,
        isCharging: true,
        status: 'ONLINE',
        aiOnline: true,
        isSimulationMode: _currentTelemetry.isSimulationMode,
        signalDbm: -42 + (timer.tick % 3),
        coreTempCelsius: double.parse(nextTemp.toStringAsFixed(1)),
        cpuLoadPercent: double.parse(nextCpu.toStringAsFixed(1)),
        memoryUsageGb: 3.2,
      );

      _controller.add(_currentTelemetry);
    });
  }

  @override
  Stream<TelemetryData> get telemetryStream => _controller.stream;

  @override
  TelemetryData get currentTelemetry => _currentTelemetry;

  @override
  List<RobotComponent> get components => MockData.robotComponents;

  @override
  void toggleSimulationMode() {
    _currentTelemetry = TelemetryData(
      batteryPercentage: _currentTelemetry.batteryPercentage,
      isCharging: _currentTelemetry.isCharging,
      status: _currentTelemetry.status,
      aiOnline: _currentTelemetry.aiOnline,
      isSimulationMode: !_currentTelemetry.isSimulationMode,
      signalDbm: _currentTelemetry.signalDbm,
      coreTempCelsius: _currentTelemetry.coreTempCelsius,
      cpuLoadPercent: _currentTelemetry.cpuLoadPercent,
      memoryUsageGb: _currentTelemetry.memoryUsageGb,
    );
    _controller.add(_currentTelemetry);
  }
}
