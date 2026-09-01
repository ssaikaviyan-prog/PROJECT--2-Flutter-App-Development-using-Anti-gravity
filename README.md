# Physical AI Robot — Autonomous Intelligence Platform

Tagline: **Sense • Understand • Decide • Act • Adapt**

A production-grade Android mobile application built with Flutter, Material 3, and Google Gemini AI based on the Google Stitch **Kinetic Logic** design system (`stitch_export/`).

---

## Features

- **Home Dashboard (Screen 1)**:
  - 3D AMR Robot visual card with high-res render.
  - Telemetry grid: Core Power (85% battery), 5G Link Uplink (-42 dBm), Thermal Core Temp (38.4°C), Jetson/Pi 5 CPU load.
  - Quick action controls linking directly to all robot subsystems.
- **Robot Explorer (Screen 2)**:
  - Interactive 3D AMR viewport with pan/zoom/rotate controls.
  - Interactive hotspot pins for Camera, LiDAR, Sonar, IMU, Motors, Battery, and AI Processor.
  - Hardware inspection drawer detailing function, specs, pinout reference, and Physical AI role.
- **Vision & Perception (Screen 3)**:
  - Simulated 1080p camera feed with real-time bounding box HUD overlays (`PERSON 96%`, `CHAIR 94%`, `OBSTACLE 98%`).
  - Dual perspective headers: *WHAT THE ROBOT SEES* & *WHAT THE AI UNDERSTANDS*.
  - Interactive "Analyze Environment" spatial depth scan trigger.
- **Autonomous Navigation (Screen 4)**:
  - 2D SLAM Occupancy Grid Map canvas rendered with `CustomPainter`.
  - Robot location marker, target destination point, obstacle safety nodes, and planned A* trajectory path.
  - Tap-to-set destination waypoint functionality.
  - State indicators: `SCANNING ENVIRONMENT`, `OBSTACLE DETECTED`, `CALCULATING PATH`, `NAVIGATING`.
- **Physical AI Assistant (Screen 5)**:
  - Powered by **Google Gemini API** (`gemini-1.5-flash`).
  - Automatic fallback to **Demo Mode** when no API key is configured.
  - Suggested question chips (*What is Physical AI?*, *How does obstacle detection work?*, *How can I connect this system to an ESP32?*).
- **Robot Components Catalog (Screen 6)**:
  - Hardware module catalog featuring all 8 primary sensors, actuators, and compute units.
  - Visual end-to-end Physical AI pipeline banner.
- **System Architecture (Screen 7)**:
  - Complete 6-stage Physical AI Pipeline diagram.
  - Hardware integration architecture clearly labeled **FUTURE INTEGRATION**.

---

## Project Structure

```
lib/
├── app/
│   ├── theme/
│   │   ├── app_colors.dart    # Kinetic Logic design system tokens
│   │   └── app_theme.dart     # Material 3 Dark theme & Google Fonts
├── data/
│   └── mock_data.dart         # Hardware component specs & fallback chat responses
├── models/
│   ├── component_model.dart
│   ├── detection_model.dart
│   ├── message_model.dart
│   ├── navigation_model.dart
│   └── telemetry_model.dart
├── services/
│   ├── gemini_service.dart     # Gemini API integration & Demo Mode handler
│   ├── navigation_service.dart # Hardware-ready navigation interface & mock service
│   ├── robot_service.dart      # Hardware-ready telemetry interface & mock service
│   └── vision_service.dart     # Hardware-ready perception interface & mock service
├── screens/
│   ├── architecture/
│   │   └── system_architecture_screen.dart
│   ├── chatbot/
│   │   └── ai_assistant_screen.dart
│   ├── components/
│   │   └── robot_components_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── navigation/
│   │   └── autonomous_navigation_screen.dart
│   ├── robot/
│   │   └── robot_explorer_screen.dart
│   ├── vision/
│   │   └── vision_perception_screen.dart
│   └── main_shell_screen.dart
└── main.dart
```

---

## Gemini API Key Setup

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` and set your key:
   ```env
   GEMINI_API_KEY=YOUR_ACTUAL_GEMINI_API_KEY
   ```
3. Alternatively, run with `--dart-define`:
   ```bash
   flutter run --dart-define=GEMINI_API_KEY=YOUR_ACTUAL_GEMINI_API_KEY
   ```
*Note: If no API key is provided, the application automatically runs in **Demo Mode** with predefined domain-specific responses.*

---

## Build Instructions

### Prerequisites
- Flutter SDK (3.24+)
- Android SDK (API Level 21+)
- Java / Gradle

### Steps
1. Fetch dependencies:
   ```bash
   flutter pub get
   ```
2. Verify code quality:
   ```bash
   dart analyze lib
   ```
3. Build Android Release APK:
   ```bash
   flutter build apk --release
   ```
The output APK is generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Future Hardware Integration Architecture

To connect real hardware (ESP32, Raspberry Pi, NVIDIA Jetson, ROS2):
1. Replace `MockRobotService` in `lib/main.dart` with a custom `ESP32RobotService` implementing `IRobotService` (via WebSocket/MQTT over Wi-Fi).
2. Replace `MockVisionService` with a `CameraVisionService` fetching RTSP/WebRTC video streams.
3. Replace `MockNavigationService` with a `ROS2NavigationService` subscribing to `/map` and `/cmd_vel` topics.
