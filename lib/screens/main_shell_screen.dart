import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../services/robot_service.dart';
import '../services/vision_service.dart';
import '../services/navigation_service.dart';
import '../services/gemini_service.dart';
import '../services/document_rag_service.dart';
import 'home/home_screen.dart';
import 'robot/robot_explorer_screen.dart';
import 'vision/vision_perception_screen.dart';
import 'navigation/autonomous_navigation_screen.dart';
import 'chatbot/ai_assistant_screen.dart';
import 'components/robot_components_screen.dart';
import 'architecture/system_architecture_screen.dart';
import 'document_analyzer/document_analyzer_screen.dart';

class MainShellScreen extends StatefulWidget {
  final IRobotService robotService;
  final IVisionService visionService;
  final INavigationService navigationService;
  final GeminiService geminiService;
  final DocumentRAGService ragService;

  const MainShellScreen({
    super.key,
    required this.robotService,
    required this.visionService,
    required this.navigationService,
    required this.geminiService,
    required this.ragService,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _onNavigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        robotService: widget.robotService,
        onNavigateTab: _onNavigateTab,
      ),
      RobotExplorerScreen(
        robotService: widget.robotService,
      ),
      VisionPerceptionScreen(
        visionService: widget.visionService,
      ),
      AutonomousNavigationScreen(
        navigationService: widget.navigationService,
      ),
      AiAssistantScreen(
        geminiService: widget.geminiService,
      ),
      DocumentAnalyzerScreen(
        ragService: widget.ragService,
      ),
      RobotComponentsScreen(
        robotService: widget.robotService,
      ),
      const SystemArchitectureScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildAppDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border(top: BorderSide(color: AppColors.borderFrosted, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex < 6 ? _currentIndex : 0,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.surfaceContainerLowest,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.outline,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_in_ar_outlined),
              activeIcon: Icon(Icons.view_in_ar, color: AppColors.primary),
              label: 'Robot',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.visibility_outlined),
              activeIcon: Icon(Icons.visibility, color: AppColors.primary),
              label: 'Vision',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.navigation_outlined),
              activeIcon: Icon(Icons.navigation, color: AppColors.primary),
              label: 'Navigate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              activeIcon: Icon(Icons.smart_toy, color: AppColors.primary),
              label: 'AI Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description, color: AppColors.primary),
              label: 'Doc RAG',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceContainerLow,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border(bottom: BorderSide(color: AppColors.borderFrosted)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.memory, color: AppColors.primary, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'PROMETHEUS-1',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Vision-Language Autonomous Navigation System',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: AppColors.primary),
            title: const Text('Home Dashboard', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              _onNavigateTab(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_in_ar, color: AppColors.primary),
            title: const Text('Robot Explorer (3D View)', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              _onNavigateTab(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.visibility, color: AppColors.primary),
            title: const Text('Vision & Perception Feed', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              _onNavigateTab(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map, color: AppColors.primary),
            title: const Text('Autonomous SLAM Navigation', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              _onNavigateTab(3);
            },
          ),
          ListTile(
            leading: const Icon(Icons.smart_toy, color: AppColors.primary),
            title: const Text('Gemini AI Assistant', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              _onNavigateTab(4);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: AppColors.secondary),
            title: const Text('AI Document Analyzer (RAG)', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              _onNavigateTab(5);
            },
          ),
          const Divider(color: AppColors.borderFrosted),
          ListTile(
            leading: const Icon(Icons.hardware, color: AppColors.secondary),
            title: const Text('Robot Hardware Modules', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              _onNavigateTab(6);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_tree, color: AppColors.tertiary),
            title: const Text('System Architecture & Future HW', style: TextStyle(color: AppColors.onSurface)),
            onTap: () {
              Navigator.pop(context);
              _onNavigateTab(7);
            },
          ),
        ],
      ),
    );
  }
}
