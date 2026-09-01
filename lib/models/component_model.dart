class RobotComponent {
  final String id;
  final String name;
  final String category;
  final String iconName;
  final String description;
  final String function;
  final String physicalAiRole;
  final String hardwareInterface;
  final String status;
  final Map<String, String> specs;

  const RobotComponent({
    required this.id,
    required this.name,
    required this.category,
    required this.iconName,
    required this.description,
    required this.function,
    required this.physicalAiRole,
    required this.hardwareInterface,
    required this.status,
    required this.specs,
  });
}
