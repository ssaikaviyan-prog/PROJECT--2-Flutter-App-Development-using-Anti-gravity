import '../models/component_model.dart';
import '../models/detection_model.dart';
import '../models/navigation_model.dart';

class MockData {
  MockData._();

  static const List<RobotComponent> robotComponents = [
    RobotComponent(
      id: 'cam_01',
      name: 'RGB-D Depth Camera',
      category: 'Perception Sensors',
      iconName: 'videocam',
      description: 'High-frame-rate stereo visual depth sensor with active IR illumination for spatial mapping.',
      function: 'Captures 1080p color feed and real-time point-cloud depth maps up to 10 meters.',
      physicalAiRole: 'SENSE / PERCEIVE — Provides visual ground truth for object classification and obstacle bounding boxes.',
      hardwareInterface: 'USB 3.2 Gen 2 / MIPI CSI-2 via ESP32-CAM or Raspberry Pi 5',
      status: 'OPTIMAL (60 FPS)',
      specs: {
        'Resolution': '1920 x 1080 @ 60fps',
        'Field of View': '87° × 58°',
        'Range': '0.2m – 10.0m',
        'Interface': 'USB 3.2 / MIPI',
      },
    ),
    RobotComponent(
      id: 'lidar_01',
      name: '360° Solid-State LiDAR',
      category: 'Perception Sensors',
      iconName: 'radar',
      description: 'High-precision laser rangefinder scanning 360 degrees horizontally at 15 Hz.',
      function: 'Generates 2D/3D occupancy grid maps and precise distance vectors to surrounding structures.',
      physicalAiRole: 'PERCEIVE / NAVIGATE — Enables SLAM (Simultaneous Localization and Mapping) and micro-collision prevention.',
      hardwareInterface: 'UART / Ethernet socket to main onboard AI computer',
      status: 'ACTIVE (15 Hz)',
      specs: {
        'Scan Frequency': '15 Hz',
        'Angular Range': '360° Horizontal',
        'Distance Accuracy': '±15mm',
        'Max Distance': '25 meters',
      },
    ),
    RobotComponent(
      id: 'sonar_array',
      name: 'Ultrasonic Distance Sensors',
      category: 'Safety & Proximity',
      iconName: 'sensors',
      description: 'Array of 4x HC-SR04 ultrasonic transducers surrounding lower chassis bumpers.',
      function: 'Provides low-latency physical wall and drop-off fallback safety sensing.',
      physicalAiRole: 'SENSE — Emergency override trigger when optical sensors fail in zero-light or glass environments.',
      hardwareInterface: 'GPIO Trigger / Echo pins to ESP32 microcontroller',
      status: 'READY (Ping 20ms)',
      specs: {
        'Count': '4 Transducers',
        'Frequency': '40 kHz',
        'Response Time': '< 15 ms',
        'Cone Angle': '15°',
      },
    ),
    RobotComponent(
      id: 'imu_6axis',
      name: '6-DOF IMU (Accelerometer + Gyro)',
      category: 'Inertial Navigation',
      iconName: 'explore',
      description: 'High-rate MEMS Inertial Measurement Unit measuring 3-axis linear acceleration and angular velocity.',
      function: 'Continuously estimates orientation, tilt angle, pitch, roll, and dead-reckoning trajectory.',
      physicalAiRole: 'ACT / ADAPT — Fuses motion vectors with wheel odometry for pose estimation.',
      hardwareInterface: 'I2C / SPI Bus @ 400kHz to ESP32',
      status: 'CALIBRATED',
      specs: {
        'Update Rate': '200 Hz',
        'Gyro Range': '±2000 dps',
        'Accel Range': '±16g',
        'Interface': 'I2C / SPI',
      },
    ),
    RobotComponent(
      id: 'motor_driver',
      name: 'Brushless DC Hub Motors & Encoders',
      category: 'Actuation & Motion',
      iconName: 'settings_input_component',
      description: 'Dual high-torque brushless hub motors with 1024-CPR quadrature optical encoders.',
      function: 'Executes closed-loop PID speed, directional steering, and precise wheel displacement.',
      physicalAiRole: 'ACT — Converts AI path velocity commands (v, ω) into physical motor torque.',
      hardwareInterface: 'PWM Speed + Direction signals to CAN / RS485 Motor Driver',
      status: 'ENGAGED (PID Locked)',
      specs: {
        'Max Speed': '2.5 m/s',
        'Torque': '12 N·m',
        'Encoder Resolution': '1024 CPR',
        'Voltage': '24V DC',
      },
    ),
    RobotComponent(
      id: 'chassis_wheels',
      name: 'Differential Omni Wheels',
      category: 'Kinematics',
      iconName: 'trip_origin',
      description: 'High-traction rubber tread wheels engineered for indoor and industrial floor stability.',
      function: 'Enables zero-radius turning circles and precise straight-line trajectory adherence.',
      physicalAiRole: 'ACT — Direct kinetic contact surface transferring energy into physical movement.',
      hardwareInterface: 'Mechanical Axle Mount',
      status: 'NOMINAL',
      specs: {
        'Wheel Diameter': '150 mm',
        'Payload Capacity': '45 kg',
        'Tread Type': 'High-grip polyurethane',
      },
    ),
    RobotComponent(
      id: 'battery_bms',
      name: 'LiFePO4 Power Cell & Smart BMS',
      category: 'Energy & Power System',
      iconName: 'battery_charging_full',
      description: '24V 20Ah Lithium Iron Phosphate battery pack with integrated CAN-bus Smart BMS.',
      function: 'Supplies isolated 24V motor power and regulated 5V/12V DC power to compute boards.',
      physicalAiRole: 'SYSTEM — Powers physical motors and AI perception compute continuously for 8 hours.',
      hardwareInterface: 'CAN-bus BMS Telemetry / ADC Voltage Divider',
      status: 'CHARGING (85%)',
      specs: {
        'Capacity': '20 Ah (480 Wh)',
        'Nominal Voltage': '25.6 V',
        'Estimated Runtime': '8.5 Hours',
        'Health': '99% State of Health',
      },
    ),
    RobotComponent(
      id: 'ai_processor',
      name: 'Edge AI Compute Unit (NVIDIA Jetson / Raspberry Pi 5)',
      category: 'AI & Processing Core',
      iconName: 'memory',
      description: 'Edge Neural Processing Unit capable of 40 TOPS AI compute for real-time vision & navigation model inference.',
      function: 'Runs local neural networks for object detection, SLAM map generation, and Gemini cloud sync.',
      physicalAiRole: 'UNDERSTAND / DECIDE — Central nervous system processing sensor streams into motor actions.',
      hardwareInterface: 'PCIe Gen 3 / USB 3.2 / Wi-Fi 6 / Bluetooth 5.2',
      status: 'AI ONLINE (24.5% Load)',
      specs: {
        'Compute Power': '40 TOPS INT8',
        'RAM': '16 GB LPDDR5',
        'Storage': '512 GB NVMe SSD',
        'Power Consumption': '15W - 25W',
      },
    ),
  ];

  static const List<DetectedObject> mockDetections = [
    DetectedObject(
      label: 'PERSON',
      confidence: 0.96,
      x: 0.15,
      y: 0.20,
      width: 0.25,
      height: 0.55,
      distanceMeters: '1.8m',
      category: 'Dynamic Obstacle',
    ),
    DetectedObject(
      label: 'CHAIR',
      confidence: 0.94,
      x: 0.58,
      y: 0.45,
      width: 0.22,
      height: 0.35,
      distanceMeters: '2.4m',
      category: 'Static Furniture',
    ),
    DetectedObject(
      label: 'OBSTACLE',
      confidence: 0.98,
      x: 0.42,
      y: 0.65,
      width: 0.18,
      height: 0.25,
      distanceMeters: '0.9m',
      category: 'Safety Hazard',
    ),
  ];

  static const NavigationStateData mockNavigationState = NavigationStateData(
    currentPosition: MapPoint(14.2, 8.7),
    destination: MapPoint(28.5, 19.4),
    pathPoints: [
      MapPoint(14.2, 8.7),
      MapPoint(16.0, 10.5),
      MapPoint(19.5, 12.0),
      MapPoint(22.0, 15.2),
      MapPoint(25.4, 17.8),
      MapPoint(28.5, 19.4),
    ],
    obstaclePoints: [
      MapPoint(18.0, 10.0),
      MapPoint(20.5, 14.5),
      MapPoint(13.0, 16.0),
      MapPoint(26.0, 14.0),
    ],
    navStatus: 'NAVIGATING',
    currentSpeedMs: 1.2,
    distanceRemainingMeters: 16.8,
    obstacleCount: 4,
    headingDegrees: 42.0,
  );

  static const Map<String, String> demoChatResponses = {
    'what is physical ai':
        '**Physical AI** combines artificial intelligence (neural networks, computer vision, spatial reasoning) with real-world mechanical robotics. Unlike screen-bound AI, Physical AI perceives physical surroundings via sensors (Camera, LiDAR, IMU), understands spatial relationships, makes real-time decisions, and executes physical actions via motors and actuators.',
    'how does obstacle detection work':
        'Obstacle detection uses a dual-sensing approach:\n\n1. **LiDAR Rangefinder**: Scans 360 degrees to build a point cloud of static structures.\n2. **RGB-D Vision Camera**: Detects dynamic objects (people, chairs) and outputs bounding boxes with confidence scores (e.g. `PERSON 96%`).\n3. **Occupancy Grid Mapping**: Combines sensor vectors into a collision safety buffer around the robot.',
    'explain this robot sensor':
        'This robot utilizes 4 main sensor categories:\n- **Camera**: Visual detection & object classification.\n- **LiDAR**: 360° laser distance & SLAM map generation.\n- **IMU**: 6-axis gyro/accel pose & tilt odometry.\n- **Ultrasonic**: Proximity bumper fallback safety sensing.',
    'what is the robot seeing':
        'The robot currently sees:\n- **PERSON** (1.8m away, 96% confidence)\n- **CHAIR** (2.4m away, 94% confidence)\n- **OBSTACLE** (0.9m away, 98% confidence)\n\nAI Understanding: Safety pathway clear to navigate around obstacle towards waypoint X: 28.5m, Y: 19.4m.',
    'how does autonomous navigation work':
        'Autonomous navigation operates via the **Sense → Understand → Decide → Act** loop:\n1. **SLAM Mapping**: Builds 2D grid map from LiDAR/Odometry.\n2. **A* / TEB Path Planning**: Calculates shortest collision-free path.\n3. **PID Motor Control**: Adjusts wheel speed left/right to follow planned waypoints.',
    'how can i connect this system to an esp32':
        'To connect this Flutter Mobile App to physical hardware (ESP32/Raspberry Pi):\n1. Use **WebSocket / MQTT protocol** over Wi-Fi.\n2. ESP32 sends telemetry JSON (`battery`, `imu_yaw`, `sonar_distance`).\n3. Flutter App sends velocity commands (`v`, `w`).\n4. Replace `MockRobotService` with `ESP32RobotService` in `lib/services/robot_service.dart`.',
  };
}
