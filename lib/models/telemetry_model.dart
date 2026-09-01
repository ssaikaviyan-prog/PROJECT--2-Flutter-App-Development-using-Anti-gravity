class TelemetryData {
  final int batteryPercentage;
  final bool isCharging;
  final String status;
  final bool aiOnline;
  final bool isSimulationMode;
  final int signalDbm;
  final double coreTempCelsius;
  final double cpuLoadPercent;
  final double memoryUsageGb;

  const TelemetryData({
    required this.batteryPercentage,
    required this.isCharging,
    required this.status,
    required this.aiOnline,
    required this.isSimulationMode,
    required this.signalDbm,
    required this.coreTempCelsius,
    required this.cpuLoadPercent,
    required this.memoryUsageGb,
  });

  factory TelemetryData.initialMock() {
    return const TelemetryData(
      batteryPercentage: 85,
      isCharging: true,
      status: 'ONLINE',
      aiOnline: true,
      isSimulationMode: true,
      signalDbm: -42,
      coreTempCelsius: 38.4,
      cpuLoadPercent: 24.5,
      memoryUsageGb: 3.2,
    );
  }
}
