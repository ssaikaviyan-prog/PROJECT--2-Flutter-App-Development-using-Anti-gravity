import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../services/vision_service.dart';
import '../../models/detection_model.dart';

class VisionPerceptionScreen extends StatefulWidget {
  final IVisionService visionService;

  const VisionPerceptionScreen({super.key, required this.visionService});

  @override
  State<VisionPerceptionScreen> createState() => _VisionPerceptionScreenState();
}

class _VisionPerceptionScreenState extends State<VisionPerceptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'VISION & PERCEIVE',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.5)),
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
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<DetectedObject>>(
          stream: widget.visionService.detectionsStream,
          initialData: widget.visionService.currentDetections,
          builder: (context, snapshot) {
            final detections = snapshot.data ?? widget.visionService.currentDetections;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section title 1: WHAT THE ROBOT SEES
                  Text(
                    'WHAT THE ROBOT SEES',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),

                  // Simulated Camera Viewport Container with Bounding Boxes
                  _buildCameraViewport(context, detections),

                  const SizedBox(height: 20),

                  // Analyze Environment Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        widget.visionService.triggerEnvironmentAnalysis();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Triggered spatial vision scan...'),
                            backgroundColor: AppColors.surfaceContainerHigh,
                          ),
                        );
                      },
                      icon: const Icon(Icons.center_focus_strong, color: Colors.black),
                      label: Text(
                        'ANALYZE ENVIRONMENT',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header section title 2: WHAT THE AI UNDERSTANDS
                  Text(
                    'WHAT THE AI UNDERSTANDS',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.secondary,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Detected Objects & Perception Summary Cards
                  _buildPerceptionSummaryCards(context, detections),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraViewport(BuildContext context, List<DetectedObject> detections) {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderFrosted),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Vision Feed Image / Placeholder
            Positioned.fill(
              child: Image.asset(
                'assets/images/vision_screen.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.surfaceContainerLow,
                    child: const Center(
                      child: Icon(Icons.videocam_off, size: 48, color: AppColors.outline),
                    ),
                  );
                },
              ),
            ),
            // Semi-transparent HUD scanline gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surfaceContainerLowest.withValues(alpha: 0.2),
                      Colors.transparent,
                      AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),

            // Render Bounding Boxes Overlay
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;

                  return Stack(
                    children: detections.map((obj) {
                      final rectLeft = obj.x * w;
                      final rectTop = obj.y * h;
                      final rectW = obj.width * w;
                      final rectH = obj.height * h;

                      final color = obj.label == 'PERSON'
                          ? AppColors.secondary
                          : obj.label == 'OBSTACLE'
                              ? AppColors.error
                              : AppColors.primary;

                      return Positioned(
                        left: rectLeft,
                        top: rectTop,
                        width: rectW,
                        height: rectH,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: color, width: 2),
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: -22,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    '${obj.label} — ${(obj.confidence * 100).toInt()}%',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.black,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            // Top Status Bar Overlay
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: AppColors.secondary, size: 8),
                        const SizedBox(width: 6),
                        Text(
                          'CAM_01: 1080P @ 60FPS',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.onSurface,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'DEPTH: ACTIVE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerceptionSummaryCards(BuildContext context, List<DetectedObject> detections) {
    return Column(
      children: detections.map((obj) {
        final color = obj.label == 'PERSON'
            ? AppColors.secondary
            : obj.label == 'OBSTACLE'
                ? AppColors.error
                : AppColors.primary;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
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
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.visibility, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${obj.label} (${obj.category})',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                        ),
                        Text(
                          '${(obj.confidence * 100).toInt()}% CONFIDENCE',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Distance: ${obj.distanceMeters} • Spatial Bounding Box: (${obj.x.toStringAsFixed(2)}, ${obj.y.toStringAsFixed(2)})',
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
      }).toList(),
    );
  }
}
