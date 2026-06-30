import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constanst/agri_colors.dart';
import '../../data/services/api_service.dart';

class AgriAsistenBotWidget extends StatefulWidget {
  final VoidCallback? onPressed;

  const AgriAsistenBotWidget({super.key, this.onPressed});

  @override
  State<AgriAsistenBotWidget> createState() => _AgriAsistenBotWidgetState();
}

class _AgriAsistenBotWidgetState extends State<AgriAsistenBotWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text':
          'Halo! Saya **Agri Asisten Bot** 🌾. Ada yang bisa saya bantu untuk produktivitas pertanian Anda hari ini?',
    },
  ];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Chat Window Overlay
        if (_isExpanded)
          Positioned(
            bottom: 80,
            right: 0,
            child: FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: _buildChatWindow(isMobile, size),
            ),
          ),

        // Floating Chat Button
        ScaleTransition(
          scale: _pulseAnimation,
          child: FloatingActionButton(
            heroTag: 'agri_assistant_fab',
            onPressed: () {
              if (widget.onPressed != null) {
                widget.onPressed!();
                return;
              }
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            backgroundColor: AgriColors.primary,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              _isExpanded ? Icons.close : Icons.chat_bubble_outline,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatWindow(bool isMobile, Size size) {
    double width = isMobile ? size.width - 32 : 360;
    double height = isMobile ? size.height - 180 : 500;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Message History
              Expanded(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.4),
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
              ),

              // Suggestion Chips (only when user has not typed much)
              if (_messages.length <= 2 && !_isTyping) _buildSuggestions(),

              // Typing Indicator
              if (_isTyping) _buildTypingIndicator(),

              // Input Field
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AgriColors.primary, AgriColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            radius: 20,
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online • n8n AI Smart',
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.minimize, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                _isExpanded = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(bool isUser, String text) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
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
      fontSize: 13.5,
      height: 1.4,
    );

    // Simple markdown interpreter for **bold** and *italic* and bullet lists
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                _sendMessage(
                  firstSpace == -1 ? text : text.substring(firstSpace + 1),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
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
                    fontSize: 12,
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

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              onSubmitted: _sendMessage,
              decoration: const InputDecoration(
                hintText: 'Tanyakan stok, cara panen, dll...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AgriColors.primary, size: 22),
            onPressed: () => _sendMessage(_inputController.text),
          ),
        ],
      ),
    );
  }
}

// Fade in Up transition
class FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const FadeInUp({super.key, required this.child, required this.duration});

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _opacity;
  late Animation<double> _translate;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _translate = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translate.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Pulsing typing indicator dots
class TypingIndicatorDots extends StatefulWidget {
  const TypingIndicatorDots({super.key});

  @override
  State<TypingIndicatorDots> createState() => _TypingIndicatorDotsState();
}

class _TypingIndicatorDotsState extends State<TypingIndicatorDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotsController;

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _dotsController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (idx) {
            final double progress = (_dotsController.value - (idx * 0.2)).clamp(
              0.0,
              1.0,
            );
            final double bounce = 1.0 - (progress - 0.5).abs() * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AgriColors.primary.withValues(
                  alpha: 0.3 + (bounce * 0.7),
                ),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
