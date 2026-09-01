import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../services/robot_service.dart';
import '../../models/telemetry_model.dart';

class HomeScreen extends StatelessWidget {
  final IRobotService robotService;
  final Function(int) onNavigateTab;

  const HomeScreen({
    super.key,
    required this.robotService,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<TelemetryData>(
          stream: robotService.telemetryStream,
          initialData: robotService.currentTelemetry,
          builder: (context, snapshot) {
            final telemetry = snapshot.data ?? robotService.currentTelemetry;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar Header
                  _buildHeader(context),

                  const SizedBox(height: 20),

                  // Hero 3D Robot Panel
                  _buildHeroPanel(context),

                  const SizedBox(height: 24),

                  // Telemetry & Status Grid Row
                  _buildTelemetryGrid(context, telemetry),

                  const SizedBox(height: 24),

                  // Quick Action Modules Section
                  Text(
                    'QUICK ACTION CONTROL',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionGrid(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.memory, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROMETHEUS-1',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                ),
                Text(
                  'AUTONOMOUS AMR PLATFORM',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondaryContainer.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'ONLINE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPanel(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderFrosted),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/robot_3d_render.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceContainerHigh,
                    child: const Center(
                      child: Icon(Icons.smart_toy, size: 64, color: AppColors.primary),
                    ),
                  );
                },
              ),
            ),
            // Dark Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.surfaceContainerLowest.withValues(alpha: 0.4),
                      AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // Text Content Overlay
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Physical AI Robot',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.primaryFixed,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SENSE • UNDERSTAND • DECIDE • ACT • ADAPT',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.tertiary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SIMULATION MODE',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'AI ONLINE',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryGrid(BuildContext context, TelemetryData telemetry) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildMetricCard(
          context: context,
          icon: Icons.battery_charging_full,
          label: 'CORE POWER',
          value: '${telemetry.batteryPercentage}%',
          subtext: telemetry.isCharging ? 'CHARGING' : 'DISCHARGING',
          accentColor: AppColors.secondary,
        ),
        _buildMetricCard(
          context: context,
          icon: Icons.cell_tower,
          label: 'LINK UPLINK',
          value: '${telemetry.signalDbm} dBm',
          subtext: '5G / MESH ACTIVE',
          accentColor: AppColors.primary,
        ),
        _buildMetricCard(
          context: context,
          icon: Icons.thermostat,
          label: 'CORE TEMP',
          value: '${telemetry.coreTempCelsius}°C',
          subtext: 'THERMAL OPTIMAL',
          accentColor: AppColors.tertiary,
        ),
        _buildMetricCard(
          context: context,
          icon: Icons.developer_board,
          label: 'CPU LOAD',
          value: '${telemetry.cpuLoadPercent}%',
          subtext: 'JETSON / PI 5',
          accentColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required String subtext,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFrosted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Icon(icon, size: 18, color: accentColor),
            ],
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
          ),
          Text(
            subtext,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: accentColor,
                  fontSize: 9,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    final actions = [
      {'title': 'Explore Robot', 'subtitle': '3D Hardware Hotspots', 'icon': Icons.view_in_ar, 'tab': 1},
      {'title': 'Vision Feed', 'subtitle': 'Perception Bounding Boxes', 'icon': Icons.visibility, 'tab': 2},
      {'title': 'Navigation', 'subtitle': 'SLAM Mapping & Trajectory', 'icon': Icons.map, 'tab': 3},
      {'title': 'AI Assistant', 'subtitle': 'Gemini Physical AI Chat', 'icon': Icons.smart_toy, 'tab': 4},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = actions[index];
        return InkWell(
          onTap: () => onNavigateTab(item['tab'] as int),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderFrosted),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                      ),
                      Text(
                        item['subtitle'] as String,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.outline),
              ],
            ),
          ),
        );
      },
    );
  }
}
