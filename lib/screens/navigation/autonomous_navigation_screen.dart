import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../services/navigation_service.dart';
import '../../models/navigation_model.dart';

class AutonomousNavigationScreen extends StatefulWidget {
  final INavigationService navigationService;

  const AutonomousNavigationScreen({super.key, required this.navigationService});

  @override
  State<AutonomousNavigationScreen> createState() => _AutonomousNavigationScreenState();
}

class _AutonomousNavigationScreenState extends State<AutonomousNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'AUTONOMOUS NAVIGATION',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.primary),
            onPressed: () {
              widget.navigationService.triggerPathRecalculation();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recalculating A* SLAM Trajectory Path...'),
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              );
            },
            tooltip: 'Recalculate Path',
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<NavigationStateData>(
          stream: widget.navigationService.navigationStream,
          initialData: widget.navigationService.currentState,
          builder: (context, snapshot) {
            final state = snapshot.data ?? widget.navigationService.currentState;

            return Column(
              children: [
                // Top Status Banner State
                _buildStatusBanner(context, state),

                // 2D SLAM Occupancy Grid Map Viewport
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: _buildMapCanvas(context, state),
                  ),
                ),

                // Bottom Telemetry & Navigation Metrics Dashboard
                _buildNavigationTelemetryDashboard(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, NavigationStateData state) {
    final isDanger = state.navStatus == 'OBSTACLE DETECTED';
    final isCalc = state.navStatus.contains('CALCULATING');
    final statusColor = isDanger
        ? AppColors.error
        : isCalc
            ? AppColors.tertiary
            : AppColors.secondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppColors.surfaceContainerLow,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'STATE: ${state.navStatus}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
            ],
          ),
          Text(
            'HEADING: ${state.headingDegrees.toStringAsFixed(1)}°',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCanvas(BuildContext context, NavigationStateData state) {
    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPos = details.localPosition;
        final size = box.size;

        // Map local tap pixel coordinates to 0..40 grid map
        final targetX = (localPos.dx / size.width) * 40.0;
        final targetY = (localPos.dy / size.height) * 30.0;

        widget.navigationService.updateTargetDestination(targetX, targetY);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Target Waypoint Set: X=${targetX.toStringAsFixed(1)}m, Y=${targetY.toStringAsFixed(1)}m'),
            backgroundColor: AppColors.primaryContainer,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderFrosted),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Custom Painter for Grid Lines, Path & Nodes
              Positioned.fill(
                child: CustomPaint(
                  painter: SlamGridMapPainter(state: state),
                ),
              ),

              // Map Overlay Labels
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.borderFrosted),
                  ),
                  child: Text(
                    'SLAM OCCUPANCY GRID (2D)',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ),
              ),

              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'TAP CANVAS TO SET DESTINATION WAYPOINT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 9,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationTelemetryDashboard(BuildContext context, NavigationStateData state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(top: BorderSide(color: AppColors.borderFrosted)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavMetric('SPEED', '${state.currentSpeedMs} m/s', Icons.speed, AppColors.secondary),
          _buildNavMetric('REMAINING', '${state.distanceRemainingMeters} m', Icons.straighten, AppColors.primary),
          _buildNavMetric('OBSTACLES', '${state.obstacleCount} DETECTED', Icons.warning_amber, AppColors.tertiary),
          _buildNavMetric('LOCATION', '(${state.currentPosition.x.toStringAsFixed(1)}, ${state.currentPosition.y.toStringAsFixed(1)})', Icons.my_location, AppColors.primaryFixed),
        ],
      ),
    );
  }

  Widget _buildNavMetric(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SlamGridMapPainter extends CustomPainter {
  final NavigationStateData state;

  SlamGridMapPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.borderFrosted.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    // Draw blueprint 2D grid lines
    const double step = 25.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Convert grid coordinates (0..40, 0..30) to canvas pixel offsets
    Offset toCanvasOffset(MapPoint pt) {
      return Offset(
        (pt.x / 40.0) * size.width,
        (pt.y / 30.0) * size.height,
      );
    }

    // Draw planned trajectory line
    final pathPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (state.pathPoints.isNotEmpty) {
      final start = toCanvasOffset(state.pathPoints.first);
      path.moveTo(start.dx, start.dy);

      for (int i = 1; i < state.pathPoints.length; i++) {
        final pt = toCanvasOffset(state.pathPoints[i]);
        path.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(path, pathPaint);

    // Draw obstacle nodes (red circles with safety aura)
    final obsPaint = Paint()..color = AppColors.error;
    final obsAuraPaint = Paint()..color = AppColors.error.withValues(alpha: 0.2);

    for (final obs in state.obstaclePoints) {
      final pt = toCanvasOffset(obs);
      canvas.drawCircle(pt, 16.0, obsAuraPaint);
      canvas.drawCircle(pt, 6.0, obsPaint);
    }

    // Draw destination target waypoint marker (green pulse ring)
    final destPt = toCanvasOffset(state.destination);
    final destPaint = Paint()..color = AppColors.secondary;
    final destAuraPaint = Paint()..color = AppColors.secondary.withValues(alpha: 0.25);
    canvas.drawCircle(destPt, 18.0, destAuraPaint);
    canvas.drawCircle(destPt, 8.0, destPaint);

    // Draw Robot Position Marker (primary blue arrow/circle)
    final robotPt = toCanvasOffset(state.currentPosition);
    final robotPaint = Paint()..color = AppColors.primary;
    final robotAuraPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.3);

    canvas.drawCircle(robotPt, 22.0, robotAuraPaint);
    canvas.drawCircle(robotPt, 10.0, robotPaint);
  }

  @override
  bool shouldRepaint(covariant SlamGridMapPainter oldDelegate) => true;
}
