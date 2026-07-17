import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/virtual_assistant_page.dart';

class HubungiKamiPage extends StatelessWidget {
  const HubungiKamiPage({super.key});

  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenLight = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : _greenLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildHeroCard(context),
                    const SizedBox(height: 20),
                    _buildContactOptions(context),
                    const SizedBox(height: 20),
                    _buildFaqSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_greenDark, _green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Hubungi Kami',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_green, Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('📞', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'CS 24/7 Siap Membantu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kami siap membantu Anda kapan saja.\nPilih cara komunikasi yang Anda inginkan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOptions(BuildContext context) {
    return Column(
      children: [
        _buildContactTile(
          context: context,
          icon: Icons.smart_toy_outlined,
          title: 'Chat Bantuan AI',
          subtitle: 'Buka Agri Asisten Bot',
          color: _green,
          onTap: () {
            final auth = context.read<AuthController>();
            final role = auth.currentUser?.role ?? 'Pembeli';
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VirtualAssistantPage(roleContext: role),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          context: context,
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle: 'agriconnect0626@gmail.com',
          color: const Color(0xFFEA4335),
          onTap: () => _launchEmail(context),
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          context: context,
          icon: Icons.chat_outlined,
          title: 'WhatsApp',
          subtitle: '+62 856-5920-2445',
          color: const Color(0xFF25D366),
          onTap: () => _launchWhatsApp(context),
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white70 : const Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.white24 : const Color(0xFFD0D5DD)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: _green, size: 20),
              const SizedBox(width: 10),
              Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFaqItem(context, 'Bagaimana cara melakukan pemesanan?'),
          _buildFaqItem(context, 'Berapa lama pengiriman pesanan?'),
          _buildFaqItem(context, 'Bagaimana cara membatalkan pesanan?'),
          _buildFaqItem(context, 'Bagaimana cara menghubungi penjual?'),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : _greenLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              question,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white70 : const Color(0xFF344054),
                fontWeight: FontWeight.w500,
              ),
            ),
            iconColor: _green,
            collapsedIconColor: _green,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  'Silakan hubungi customer service kami melalui WhatsApp atau Email untuk bantuan lebih lanjut mengenai ini.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'agriconnect0626@gmail.com',
      queryParameters: const {'subject': 'Bantuan AgriConnect'},
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aplikasi email tidak tersedia'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final waAppUri = Uri.parse('whatsapp://send?phone=6285659202445');
    final waWebUri = Uri.parse('https://wa.me/6285659202445');
    
    try {
      if (await canLaunchUrl(waAppUri)) {
        await launchUrl(waAppUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    if (!await launchUrl(waWebUri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp tidak tersedia'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
