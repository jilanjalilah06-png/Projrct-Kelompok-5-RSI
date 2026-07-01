import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/services/api_service.dart';
import '../../widgets/agri_asisten_bot_widget.dart';

class VirtualAssistantPage extends StatefulWidget {
  final bool showBackButton;
  final String? roleContext;

  const VirtualAssistantPage({
    super.key,
    this.showBackButton = true,
    this.roleContext,
  });

  @override
  State<VirtualAssistantPage> createState() => _VirtualAssistantPageState();
}

class _VirtualAssistantPageState extends State<VirtualAssistantPage> {
  static const _green = Color(0xFF2D832F);
  static const _background = Color(0xFFEFF8EF);
  static const _title = Color(0xFF001A3D);
  static const _muted = Color(0xFF98A2B3);

  late final List<Map<String, String>> _messages;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    final role = widget.roleContext ?? 'Pengguna';
    _messages = [
      {
        'sender': 'bot',
        'text':
            'Halo! Saya **Agri Asisten Bot**. Saat ini konteks Anda: **$role**. Ada yang bisa saya bantu di AgriConnect?',
      },
    ];
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': trimmed});
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final response = await apiService.sendChatbotMessage(trimmed);
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': response['reply'] ?? 'Maaf, saya tidak menerima balasan.',
        });
      });
    } catch (_) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text':
              'Maaf, terjadi gangguan koneksi. Bantuan cepat: ketik "stok", "jadwal", "produk", atau "fitur".',
        });
      });
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _green,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              radius: 18,
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Agri Asisten Bot',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Online - ${widget.roleContext ?? "AgriConnect"}',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _ChatBubble(
                    isUser: message['sender'] == 'user',
                    text: message['text']!,
                  );
                },
              ),
            ),
            if (_messages.length <= 2 && !_isTyping)
              _Suggestions(onSelected: _sendMessage),
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xFFD7FBE5),
                      radius: 13,
                      child: Icon(Icons.smart_toy, color: _green, size: 15),
                    ),
                    SizedBox(width: 8),
                    TypingIndicatorDots(),
                  ],
                ),
              ),
            _InputBar(
              controller: _inputController,
              onSubmitted: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;

  const _ChatBubble({required this.isUser, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? _VirtualAssistantPageState._green : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _FormattedText(text: text, isUser: isUser),
      ),
    );
  }
}

class _FormattedText extends StatelessWidget {
  final String text;
  final bool isUser;

  const _FormattedText({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: isUser ? Colors.white : _VirtualAssistantPageState._title,
      fontSize: 14,
      height: 1.4,
    );
    final spans = <TextSpan>[];
    final regExp = RegExp(r'(\*\*.*?\*\*|\*.*?\*|\n)');
    final matches = regExp.allMatches(text);
    var start = 0;

    for (final match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start), style: style));
      }
      final token = match.group(0)!;
      if (token == '\n') {
        spans.add(const TextSpan(text: '\n'));
      } else if (token.startsWith('**') && token.endsWith('**')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: style.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      } else if (token.startsWith('*') && token.endsWith('*')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: style.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      }
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _Suggestions extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const _Suggestions({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const suggestions = [
      'Stok padi terbaru',
      'Daftar produk',
      'Cek pesanan',
      'Panduan fitur',
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final text = suggestions[index];
          return ActionChip(
            onPressed: () => onSelected(text),
            label: Text(text),
            labelStyle: GoogleFonts.outfit(
              color: _VirtualAssistantPageState._green,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
            backgroundColor: const Color(0xFFD7FBE5),
            side: BorderSide(
              color: _VirtualAssistantPageState._green.withValues(alpha: 0.12),
            ),
            shape: const StadiumBorder(),
          );
        },
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const _InputBar({required this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F4F7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                onSubmitted: onSubmitted,
                decoration: const InputDecoration(
                  hintText: 'Tanyakan sesuatu tentang pertanian...',
                  hintStyle: TextStyle(color: _VirtualAssistantPageState._muted),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: _VirtualAssistantPageState._green,
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => onSubmitted(controller.text),
            ),
          ),
        ],
      ),
    );
  }
}
