import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../services/document_rag_service.dart';

class DocumentAnalyzerScreen extends StatefulWidget {
  final DocumentRAGService ragService;

  const DocumentAnalyzerScreen({super.key, required this.ragService});

  @override
  State<DocumentAnalyzerScreen> createState() => _DocumentAnalyzerScreenState();
}

class _DocumentAnalyzerScreenState extends State<DocumentAnalyzerScreen> {
  final List<Map<String, dynamic>> _chatHistory = [];
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _explainSimply = false;
  RAGDocumentItem? _selectedDocForSummary;

  final List<String> _suggestedPrompts = [
    'What sensors are required for navigation?',
    'Explain autonomous navigation algorithm.',
    'What are the ESP32 hardware pinouts?',
    'Summarize robot_navigation_manual.pdf',
  ];

  @override
  void initState() {
    super.initState();
    _chatHistory.add({
      'sender': 'ai',
      'text': 'Welcome to the **AI Document Analyzer & Knowledge RAG**. '
          'Upload technical documentation (PDF, DOCX, TXT, MD) to perform grounded vector search with source citations.',
      'sources': <Map<String, dynamic>>[],
      'isDemo': !widget.ragService.isOnline,
    });
  }

  void _handleUploadDocument() {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController(text: 'autonomous_vision_spec.pdf');
        final textController = TextEditingController(
          text: 'The Vision-Language Autonomous Navigation System uses RGB-D cameras for 3D object detection '
              'and 360-degree LiDAR for SLAM occupancy grid mapping. It processes perception vectors via '
              'an onboard Jetson AI unit and sends PID velocity motor commands to dual brushless motors.',
        );

        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLow,
          title: Text(
            'UPLOAD TECHNICAL DOCUMENT',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Document Name (.pdf, .docx, .txt, .md)'),
                style: const TextStyle(color: AppColors.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Document Content Text'),
                style: const TextStyle(color: AppColors.onSurface),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.outline)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final name = titleController.text.trim();
                final content = textController.text.trim();
                if (name.isNotEmpty && content.isNotEmpty) {
                  setState(() {
                    widget.ragService.addDocument(name, 5, content);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Document "$name" indexed into vector store.'),
                      backgroundColor: AppColors.secondaryContainer,
                    ),
                  );
                }
              },
              child: const Text('INDEX DOCUMENT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _submitQuestion(String question) async {
    final cleanQ = question.trim();
    if (cleanQ.isEmpty || _isLoading) return;

    _questionController.clear();

    setState(() {
      _chatHistory.add({'sender': 'user', 'text': cleanQ, 'sources': <Map<String, dynamic>>[]});
      _isLoading = true;
    });

    _scrollToBottom();

    final result = await widget.ragService.queryDocumentRAG(cleanQ);

    if (mounted) {
      setState(() {
        _chatHistory.add({
          'sender': 'ai',
          'text': result['answer'] as String,
          'sources': result['sources'] as List<Map<String, dynamic>>,
          'isDemo': result['isDemo'] as bool,
        });
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

  @override
  Widget build(BuildContext context) {
    final docs = widget.ragService.indexedDocuments;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'DOCUMENT RAG ANALYZER',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.0,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add, color: AppColors.secondary),
            onPressed: _handleUploadDocument,
            tooltip: 'Upload Document',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.outline),
            onPressed: () {
              setState(() {
                _chatHistory.clear();
              });
            },
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Document Management & Summary Bar
            _buildDocumentManagementHeader(context, docs),

            // Document Summary Drawer if selected
            if (_selectedDocForSummary != null)
              _buildDocumentSummaryPanel(_selectedDocForSummary!),

            // Suggested Query Chips
            _buildSuggestedPrompts(),

            // RAG Chat Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _chatHistory.length,
                itemBuilder: (context, index) {
                  return _buildChatBubble(_chatHistory[index]);
                },
              ),
            ),

            if (_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary)),
                    const SizedBox(width: 8),
                    Text(
                      'RETRIEVING VECTOR CHUNKS & GENERATING GROUNDED ANSWER...',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),

            // Question Input Bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentManagementHeader(BuildContext context, List<RAGDocumentItem> docs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.description, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'INDEXED DOCUMENTS (${docs.length})',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _handleUploadDocument,
                icon: const Icon(Icons.upload_file, size: 14, color: Colors.black),
                label: const Text('UPLOAD', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: docs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final d = docs[index];
                final isSelected = _selectedDocForSummary?.id == d.id;

                return ActionChip(
                  avatar: const Icon(Icons.article, size: 14, color: AppColors.primary),
                  backgroundColor: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.3) : AppColors.surfaceContainerHigh,
                  side: BorderSide(color: isSelected ? AppColors.primary : AppColors.borderFrosted),
                  label: Text(
                    '${d.name} (${d.pageCount}p)',
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.onSurface,
                      fontSize: 11,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedDocForSummary = isSelected ? null : d;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSummaryPanel(RAGDocumentItem doc) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                doc.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              Row(
                children: [
                  Text('Explain Simply', style: Theme.of(context).textTheme.labelSmall),
                  Switch(
                    value: _explainSimply,
                    activeTrackColor: AppColors.secondary,
                    onChanged: (val) {
                      setState(() {
                        _explainSimply = val;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16, color: AppColors.outline),
                    onPressed: () {
                      setState(() {
                        _selectedDocForSummary = null;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          Text(
            '${doc.pageCount} Pages • ${doc.wordCount} Words • ${doc.chunkCount} Vector Chunks',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            _explainSimply
                ? 'Simplified Summary: This document teaches the robot how to use sensors (LiDAR, Camera) to see obstacles and navigate safely without crashing.'
                : doc.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPrompts() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestedPrompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = _suggestedPrompts[index];
          return ActionChip(
            backgroundColor: AppColors.surfaceContainerLow,
            side: const BorderSide(color: AppColors.borderFrosted),
            label: Text(p, style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
            onPressed: () => _submitQuestion(p),
          );
        },
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final isUser = msg['sender'] == 'user';
    final sources = msg['sources'] as List<Map<String, dynamic>>;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.84),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryContainer.withValues(alpha: 0.25) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isUser ? AppColors.primary : AppColors.borderFrosted),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? 'USER QUESTION' : 'GROUNDED RAG RESPONSE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isUser ? AppColors.primary : AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              msg['text'] as String,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurface, height: 1.4),
            ),
            if (sources.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(color: AppColors.borderFrosted, height: 1),
              const SizedBox(height: 6),
              Text(
                'SOURCES & CITATIONS:',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.secondary, fontSize: 9, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: sources.map((src) {
                  return Chip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    side: const BorderSide(color: AppColors.secondary, width: 0.8),
                    avatar: const Icon(Icons.bookmark, size: 12, color: AppColors.secondary),
                    label: Text(
                      '${src['document']} — Page ${src['page']}',
                      style: const TextStyle(fontSize: 9, color: AppColors.onSurface),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(top: BorderSide(color: AppColors.borderFrosted)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _questionController,
              onSubmitted: _submitQuestion,
              decoration: const InputDecoration(
                hintText: 'Ask a grounded technical document question...',
              ),
              style: const TextStyle(color: AppColors.onSurface),
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: () => _submitQuestion(_questionController.text),
            icon: const Icon(Icons.send, color: Colors.black, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
