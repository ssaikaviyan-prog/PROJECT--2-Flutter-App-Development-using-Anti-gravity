import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../services/robot_service.dart';
import '../../models/component_model.dart';

class RobotComponentsScreen extends StatefulWidget {
  final IRobotService robotService;

  const RobotComponentsScreen({super.key, required this.robotService});

  @override
  State<RobotComponentsScreen> createState() => _RobotComponentsScreenState();
}

class _RobotComponentsScreenState extends State<RobotComponentsScreen> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final components = widget.robotService.components;
    final categories = ['ALL', 'Perception Sensors', 'Safety & Proximity', 'Actuation & Motion', 'AI & Processing Core'];

    final filtered = _selectedCategory == 'ALL'
        ? components
        : components.where((c) => c.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ROBOT HARDWARE MODULES',
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
              // Top Visual Banner: End-to-End Physical AI Pipeline
              _buildPipelineBanner(context),

              const SizedBox(height: 20),

              // Category Filter Bar
              _buildCategoryFilter(categories),

              const SizedBox(height: 16),

              // Component List View
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildComponentCard(context, filtered[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PHYSICAL AI HARDWARE PIPELINE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sensors → Perception → AI Understanding → Decision → Motion Planning → Actuation',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(List<String> categories) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;

          return FilterChip(
            selected: isSelected,
            label: Text(
              cat,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isSelected ? Colors.black : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
            ),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderFrosted,
              ),
            ),
            onSelected: (_) {
              setState(() {
                _selectedCategory = cat;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildComponentCard(BuildContext context, RobotComponent comp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderFrosted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                      ),
                      Text(
                        comp.category.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontSize: 9,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  comp.status,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comp.function,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderFrosted),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PHYSICAL AI RELEVANCE:',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  comp.physicalAiRole,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurface,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'HARDWARE INTERFACE: ${comp.hardwareInterface}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.outline,
                        fontSize: 9,
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
