import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class SystemArchitectureScreen extends StatelessWidget {
  const SystemArchitectureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'SYSTEM ARCHITECTURE',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: PHYSICAL AI PIPELINE
              Text(
                'PHYSICAL AI PIPELINE',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              _buildPipelineStepList(context),

              const SizedBox(height: 28),

              // Section 2: FUTURE HARDWARE INTEGRATION ARCHITECTURE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HARDWARE INTEGRATION',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'FUTURE INTEGRATION',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.tertiary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildHardwareArchitectureFlow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineStepList(BuildContext context) {
    final steps = [
      {'title': 'SENSE', 'desc': 'Raw sensor data acquisition (Camera RGB-D, LiDAR 360°, IMU 6-DOF, Sonar array).', 'icon': Icons.sensors, 'color': AppColors.primary},
      {'title': 'PERCEIVE', 'desc': 'Computer vision neural detection, spatial point-cloud depth processing & bounding box overlay.', 'icon': Icons.visibility, 'color': AppColors.secondary},
      {'title': 'UNDERSTAND', 'desc': 'Gemini AI & Edge NPU multi-modal context understanding & safety spatial hazard mapping.', 'icon': Icons.psychology, 'color': AppColors.tertiary},
      {'title': 'DECIDE', 'desc': 'A* / TEB SLAM trajectory calculation, goal selection & dynamic obstacle evasion strategy.', 'icon': Icons.alt_route, 'color': AppColors.primary},
      {'title': 'ACT', 'desc': 'PID closed-loop motor torque commands sent to dual brushless wheel hub actuators.', 'icon': Icons.directions_run, 'color': AppColors.secondary},
      {'title': 'ADAPT', 'desc': 'Inertial IMU odometry feedback loop continuously refining future spatial confidence vectors.', 'icon': Icons.autorenew, 'color': AppColors.primaryFixed},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final step = steps[index];
        final color = step['color'] as Color;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderFrosted),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Icon(step['icon'] as IconData, color: color, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'] as String,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 1.0,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step['desc'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHardwareArchitectureFlow(BuildContext context) {
    final flowNodes = [
      {'title': 'Mobile App (Flutter / Android)', 'subtitle': 'UI Dashboard & Gemini Assistant', 'icon': Icons.phone_android},
      {'title': 'Cloud & Edge AI (Gemini API)', 'subtitle': 'Multi-modal Perception & Query Engine', 'icon': Icons.cloud_sync},
      {'title': 'Robot Communication Link', 'subtitle': 'WebSocket / MQTT / ROS2 Bridge', 'icon': Icons.router},
      {'title': 'Embedded Microcontrollers', 'subtitle': 'ESP32 / Raspberry Pi / Jetson', 'icon': Icons.memory},
      {'title': 'Physical Hardware Actuation', 'subtitle': 'LiDAR, Cameras, Sonar, Motors & BMS', 'icon': Icons.precision_manufacturing},
    ];

    return Column(
      children: List.generate(flowNodes.length, (index) {
        final node = flowNodes[index];
        final isLast = index == flowNodes.length - 1;

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderFrosted),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(node['icon'] as IconData, color: AppColors.secondary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node['title'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                        ),
                        Text(
                          node['subtitle'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Icon(Icons.arrow_downward, color: AppColors.outline, size: 18),
              ),
          ],
        );
      }),
    );
  }
}
