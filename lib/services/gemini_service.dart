import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/mock_data.dart';

class GeminiService {
  GenerativeModel? _model;
  bool _isOnline = false;
  String _statusMessage = 'Initializing AI...';

  bool get isOnline => _isOnline;
  String get statusMessage => _statusMessage;

  GeminiService() {
    _initialize();
  }

  void _initialize() {
    try {
      // 1. Try loading from .env
      String? apiKey = dotenv.env['GEMINI_API_KEY'];

      // 2. Fallback to --dart-define environment variable
      if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        const envKey = String.fromEnvironment('GEMINI_API_KEY');
        if (envKey.isNotEmpty && envKey != 'YOUR_GEMINI_API_KEY_HERE') {
          apiKey = envKey;
        }
      }

      if (apiKey != null && apiKey.isNotEmpty && apiKey != 'YOUR_GEMINI_API_KEY_HERE') {
        _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          systemInstruction: Content.system(
            'You are AQ, an advanced Physical AI Robotics Assistant integrated into the PROMETHEUS-1 Autonomous Mobile Robot app. '
            'You specialize in Physical AI, computer vision, autonomous SLAM navigation, sensor fusion (LiDAR, RGB-D Camera, IMU, Sonar), '
            'robot system architecture, and hardware integration (ESP32, Raspberry Pi, NVIDIA Jetson, ROS2). '
            'Provide clear, technical, concise engineering explanations for all physical robotics and AI questions.',
          ),
        );
        _isOnline = true;
        _statusMessage = 'AI ONLINE (Gemini 1.5 Flash)';
        if (kDebugMode) {
          print('Gemini API initialized successfully.');
        }
      } else {
        _isOnline = false;
        _statusMessage = 'DEMO MODE (No API Key)';
        if (kDebugMode) {
          print('Gemini API key not found. Engaging Demo Mode fallback.');
        }
      }
    } catch (e) {
      _isOnline = false;
      _statusMessage = 'DEMO MODE (Init Error)';
      if (kDebugMode) {
        print('Error initializing Gemini API: $e');
      }
    }
  }

  Future<Map<String, dynamic>> askAssistant(String prompt) async {
    if (!_isOnline || _model == null) {
      return _generateDemoResponse(prompt);
    }

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final replyText = response.text;

      if (replyText != null && replyText.isNotEmpty) {
        return {
          'text': replyText,
          'isDemo': false,
        };
      } else {
        return _generateDemoResponse(prompt);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Gemini API query error: $e');
      }
      return _generateDemoResponse(prompt);
    }
  }

  Map<String, dynamic> _generateDemoResponse(String prompt) {
    final cleanPrompt = prompt.trim().toLowerCase();

    for (final entry in MockData.demoChatResponses.entries) {
      if (cleanPrompt.contains(entry.key)) {
        return {
          'text': entry.value,
          'isDemo': true,
        };
      }
    }

    // Default intelligent Physical AI fallback response for unlisted questions
    final fallbackText =
        '**PROMETHEUS-1 Physical AI Assistant [Demo Mode]**\n\n'
        'Regarding: "$prompt"\n\n'
        'In physical robotics, this concept relies on our **Sense → Understand → Decide → Act** pipeline. '
        'Sensors capture physical environmental data (LiDAR distance, camera vision vectors, IMU odometry), '
        'the onboard AI processor executes neural network perception, motion planning algorithms determine the path, '
        'and motor drivers actuate physical wheel movement.\n\n'
        '*Tip: Configure your `GEMINI_API_KEY` in `.env` to unlock live generative Gemini AI responses.*';

    return {
      'text': fallbackText,
      'isDemo': true,
    };
  }
}
