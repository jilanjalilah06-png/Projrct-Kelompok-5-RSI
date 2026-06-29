import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/agri_asisten_bot_widget.dart'; // reuse TypingIndicatorDots

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
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text':
          'Halo! Saya **Agri Asisten Bot** 🌾. Ada yang bisa saya bantu untuk produktivitas pertanian Anda hari ini? Tanggapan saya disesuaikan dengan data real-time platform AgriConnect!',
    },
  ];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    final role = widget.roleContext ?? 'Pengguna';
    _messages[0]['text'] =
        'Halo! Saya **Agri Asisten Bot**. Saat ini konteks Anda: **$role**. Ada yang bisa saya bantu di AgriConnect?';
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

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isTyping = true;
    });
    _inputController.clear();
    _scrollToBottom();

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final response = await apiService.sendChatbotMessage(text);
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': response['reply'] ?? 'Maaf, saya tidak menerima balasan.',
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text':
              'Maaf, terjadi gangguan koneksi. Berikut bantuan cepat offline:\n\n• Ketik "*stok*" untuk melihat produk.\n• Ketik "*petani*" untuk melihat daftar mitra.\n• Ketik "*fitur*" untuk info menu.',
        });
      });
    } finally {
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AgriColors.primary, AgriColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.25),
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online - ${widget.roleContext ?? "AgriConnect"}',
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
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
            // Chat Message List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(
                    msg['sender'] == 'user',
                    msg['text']!,
                  );
                },
              ),
            ),

            // Quick suggestion chips
            if (_messages.length <= 2 && !_isTyping) _buildSuggestions(),

            // Typing Dots
            if (_isTyping)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      radius: 12,
                      child: const Icon(
                        Icons.smart_toy,
                        color: AgriColors.primary,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const TypingIndicatorDots(),
                  ],
                ),
              ),

            // Input bottom bar
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(bool isUser, String text) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AgriColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _formatMessageText(text, isUser),
      ),
    );
  }

  Widget _formatMessageText(String text, bool isUser) {
    final style = TextStyle(
      color: isUser ? Colors.white : AgriColors.textDark,
      fontSize: 14,
      height: 1.4,
    );

    List<TextSpan> spans = [];
    final regExp = RegExp(r'(\*\*.*?\*\*|\*.*?\*|\n)');
    final matches = regExp.allMatches(text);

    int start = 0;
    for (final match in matches) {
      if (match.start > start) {
        spans.add(
          TextSpan(text: text.substring(start, match.start), style: style),
        );
      }
      final matchStr = match.group(0)!;
      if (matchStr == '\n') {
        spans.add(const TextSpan(text: '\n'));
      } else if (matchStr.startsWith('**') && matchStr.endsWith('**')) {
        spans.add(
          TextSpan(
            text: matchStr.substring(2, matchStr.length - 2),
            style: style.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      } else if (matchStr.startsWith('*') && matchStr.endsWith('*')) {
        spans.add(
          TextSpan(
            text: matchStr.substring(1, matchStr.length - 1),
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

  Widget _buildSuggestions() {
    final list = [
      '🌾 Stok padi terbaru',
      '🏬 Daftar petani mitra',
      '📦 Cek pesanan saya',
      '🚜 Panduan fitur',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, idx) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                final text = list[idx];
                final firstSpace = text.indexOf(' ');
                _sendMessage(firstSpace == -1 ? text : text.substring(firstSpace + 1));
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AgriColors.primary.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AgriColors.primary.withValues(alpha: 0.15),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  list[idx],
                  style: GoogleFonts.outfit(
                    color: AgriColors.primary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _inputController,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration(
                  hintText: 'Tanyakan sesuatu tentang pertanian...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AgriColors.primary,
            radius: 22,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(_inputController.text),
            ),
          ),
        ],
      ),
    );
  }
}
