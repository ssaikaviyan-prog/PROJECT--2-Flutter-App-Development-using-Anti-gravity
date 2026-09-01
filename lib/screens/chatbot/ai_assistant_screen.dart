import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../services/gemini_service.dart';
import '../../models/message_model.dart';

class AiAssistantScreen extends StatefulWidget {
  final GeminiService geminiService;

  const AiAssistantScreen({super.key, required this.geminiService});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<String> _suggestedQuestions = [
    'What is Physical AI?',
    'How does obstacle detection work?',
    'Explain this robot sensor.',
    'What is the robot seeing?',
    'How does autonomous navigation work?',
    'How can I connect this system to an ESP32?',
  ];

  @override
  void initState() {
    super.initState();
    // Initial welcome message
    _messages.add(
      ChatMessage(
        id: 'msg_welcome',
        sender: MessageSender.assistant,
        text: 'Hello! I am **AQ**, your Physical AI Robot Assistant.\n\n'
            'Ask me anything about computer vision perception, LiDAR SLAM navigation, sensor fusion, hardware integration (ESP32 / Raspberry Pi), or system architecture.',
        timestamp: DateTime.now(),
        isDemoResponse: !widget.geminiService.isOnline,
      ),
    );
  }

  void _sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _isLoading) return;

    _inputController.clear();

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: MessageSender.user,
      text: cleanText,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });

    _scrollToBottom();

    // Query Gemini API / Demo Service
    final result = await widget.geminiService.askAssistant(cleanText);

    final replyMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      sender: MessageSender.assistant,
      text: result['text'] as String,
      timestamp: DateTime.now(),
      isDemoResponse: result['isDemo'] as bool,
    );

    if (mounted) {
      setState(() {
        _messages.add(replyMsg);
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _messages.add(
        ChatMessage(
          id: 'msg_welcome_cleared',
          sender: MessageSender.assistant,
          text: 'Conversation cleared. Ready for new Physical AI questions.',
          timestamp: DateTime.now(),
          isDemoResponse: !widget.geminiService.isOnline,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = widget.geminiService.isOnline;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PHYSICAL AI ASSISTANT',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.0,
                  ),
            ),
            Text(
              widget.geminiService.statusMessage,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isOnline ? AppColors.secondary : AppColors.tertiary,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.outline),
            onPressed: _clearChat,
            tooltip: 'Clear Conversation',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Suggested Questions Scrollable Chip Bar
            _buildSuggestedChips(),

            // Chat Message Trajectory
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // Loading Indicator
            if (_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI IS PROCESSING QUERY...',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
              ),

            // Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestedQuestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final question = _suggestedQuestions[index];
          return ActionChip(
            backgroundColor: AppColors.surfaceContainerHigh,
            side: const BorderSide(color: AppColors.borderFrosted),
            label: Text(
              question,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            onPressed: () => _sendMessage(question),
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.sender == MessageSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primaryContainer.withValues(alpha: 0.25)
              : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.borderFrosted,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUser ? 'YOU' : 'AQ ASSISTANT',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isUser ? AppColors.primary : AppColors.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                ),
                if (!isUser && msg.isDemoResponse) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'DEMO MODE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.tertiary,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              msg.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: const Border(top: BorderSide(color: AppColors.borderFrosted)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              onSubmitted: _sendMessage,
              decoration: const InputDecoration(
                hintText: 'Ask physical robotics or Gemini question...',
              ),
              style: const TextStyle(color: AppColors.onSurface),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: () => _sendMessage(_inputController.text),
            icon: const Icon(Icons.send, color: Colors.black, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
