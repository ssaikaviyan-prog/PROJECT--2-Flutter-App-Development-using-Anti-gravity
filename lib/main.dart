import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/theme/app_theme.dart';
import 'services/robot_service.dart';
import 'services/vision_service.dart';
import 'services/navigation_service.dart';
import 'services/gemini_service.dart';
import 'services/document_rag_service.dart';
import 'screens/main_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load local environment config if present
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Note: .env file not found or could not be loaded. Demo Mode active.");
  }

  // Instantiate Hardware-Ready Services & RAG Document Service
  final robotService = MockRobotService();
  final visionService = MockVisionService();
  final navigationService = MockNavigationService();
  final geminiService = GeminiService();
  final ragService = DocumentRAGService();

  runApp(PhysicalAiRobotApp(
    robotService: robotService,
    visionService: visionService,
    navigationService: navigationService,
    geminiService: geminiService,
    ragService: ragService,
  ));
}

class PhysicalAiRobotApp extends StatelessWidget {
  final IRobotService robotService;
  final IVisionService visionService;
  final INavigationService navigationService;
  final GeminiService geminiService;
  final DocumentRAGService ragService;

  const PhysicalAiRobotApp({
    super.key,
    required this.robotService,
    required this.visionService,
    required this.navigationService,
    required this.geminiService,
    required this.ragService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision-Language Autonomous Navigation System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MainShellScreen(
        robotService: robotService,
        visionService: visionService,
        navigationService: navigationService,
        geminiService: geminiService,
        ragService: ragService,
      ),
    );
  }
}
