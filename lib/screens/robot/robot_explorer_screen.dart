import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../services/robot_service.dart';
import '../../models/component_model.dart';

class RobotExplorerScreen extends StatefulWidget {
  final IRobotService robotService;

  const RobotExplorerScreen({super.key, required this.robotService});

  @override
  State<RobotExplorerScreen> createState() => _RobotExplorerScreenState();
}

class _RobotExplorerScreenState extends State<RobotExplorerScreen> {
  RobotComponent? _selectedComponent;
  double _rotationDegrees = 0.0;
  double _zoomScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final components = widget.robotService.components;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ROBOT EXPLORER',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.onSurfaceVariant),
            onPressed: () {
              setState(() {
                _rotationDegrees = 0.0;
                _zoomScale = 1.0;
                _selectedComponent = null;
              });
            },
            tooltip: 'Reset 3D View',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Interactive 3D Canvas Container
            Expanded(
              child: Stack(
                children: [
                  // Blueprint Grid Background
                  Positioned.fill(
                    child: Container(
                      color: AppColors.surfaceContainerLowest,
                    ),
                  ),

                  // Robot Image Viewport with Transform rotation and zoom
                  Center(
                    child: GestureDetector(
                      onScaleUpdate: (details) {
                        setState(() {
                          _zoomScale = (_zoomScale * details.scale).clamp(0.8, 2.5);
                        });
                      },
                      child: Transform.scale(
                        scale: _zoomScale,
                        child: Transform.rotate(
                          angle: _rotationDegrees * 3.14159 / 180,
                          child: Image.asset(
                            'assets/images/robot_3d_render.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.smart_toy, size: 120, color: AppColors.primary);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Hotspot Pins overlay
                  Positioned.fill(
                    child: Stack(
                      children: [
                        _buildHotspotPin(
                          leftFraction: 0.48,
                          topFraction: 0.22,
                          label: 'CAM',
                          component: components.firstWhere((c) => c.id == 'cam_01'),
                        ),
                        _buildHotspotPin(
                          leftFraction: 0.50,
                          topFraction: 0.14,
                          label: 'LIDAR',
                          component: components.firstWhere((c) => c.id == 'lidar_01'),
                        ),
                        _buildHotspotPin(
                          leftFraction: 0.28,
                          topFraction: 0.52,
                          label: 'SONAR',
                          component: components.firstWhere((c) => c.id == 'sonar_array'),
                        ),
                        _buildHotspotPin(
                          leftFraction: 0.48,
                          topFraction: 0.42,
                          label: 'AI CORE',
                          component: components.firstWhere((c) => c.id == 'ai_processor'),
                        ),
                        _buildHotspotPin(
                          leftFraction: 0.72,
                          topFraction: 0.65,
                          label: 'MOTOR',
                          component: components.firstWhere((c) => c.id == 'motor_driver'),
                        ),
                        _buildHotspotPin(
                          leftFraction: 0.50,
                          topFraction: 0.76,
                          label: 'BATTERY',
                          component: components.firstWhere((c) => c.id == 'battery_bms'),
                        ),
                      ],
                    ),
                  ),

                  // Floating 3D Control Bar (Rotate left, right, reset)
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderFrosted),
                      ),
                      child: Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.rotate_left, color: AppColors.primary, size: 20),
                            onPressed: () {
                              setState(() => _rotationDegrees -= 15);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.rotate_right, color: AppColors.primary, size: 20),
                            onPressed: () {
                              setState(() => _rotationDegrees += 15);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.zoom_in, color: AppColors.primary, size: 20),
                            onPressed: () {
                              setState(() => _zoomScale = (_zoomScale + 0.2).clamp(0.8, 2.5));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.zoom_out, color: AppColors.primary, size: 20),
                            onPressed: () {
                              setState(() => _zoomScale = (_zoomScale - 0.2).clamp(0.8, 2.5));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Instruction Chip
                  Positioned(
                    left: 20,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.borderFrosted),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.touch_app, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'TAP HOTSPOT PINS TO INSPECT COMPONENT',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Selected Component Details Drawer
            if (_selectedComponent != null)
              _buildComponentDetailSheet(_selectedComponent!)
            else
              _buildComponentSelectorBar(components),
          ],
        ),
      ),
    );
  }

  Widget _buildHotspotPin({
    required double leftFraction,
    required double topFraction,
    required String label,
    required RobotComponent component,
  }) {
    final isSelected = _selectedComponent?.id == component.id;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Positioned(
          left: constraints.maxWidth * leftFraction - 20,
          top: constraints.maxHeight * topFraction - 20,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedComponent = component;
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.secondary : AppColors.primaryContainer.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isSelected ? Icons.check : Icons.hub,
                    color: isSelected ? Colors.black : Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? AppColors.secondary : AppColors.borderFrosted,
                    ),
                  ),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          color: isSelected ? AppColors.secondary : AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComponentSelectorBar(List<RobotComponent> components) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: const Border(top: BorderSide(color: AppColors.borderFrosted)),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: components.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final comp = components[index];
          return ActionChip(
            backgroundColor: AppColors.surfaceContainerHigh,
            side: const BorderSide(color: AppColors.borderFrosted),
            avatar: const Icon(Icons.memory, size: 16, color: AppColors.primary),
            label: Text(
              comp.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
            onPressed: () {
              setState(() {
                _selectedComponent = comp;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildComponentDetailSheet(RobotComponent comp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(top: BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.memory, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comp.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                      ),
                      Text(
                        comp.category.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.outline),
                onPressed: () {
                  setState(() {
                    _selectedComponent = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comp.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderFrosted),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PHYSICAL AI ROLE:',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  comp.physicalAiRole,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
