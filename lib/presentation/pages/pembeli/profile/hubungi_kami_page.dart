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
    return Scaffold(
      backgroundColor: _greenLight,
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
                    _buildFaqSection(),
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
          icon: Icons.smart_toy_outlined,
          title: 'Chat Bantuan AI',
          subtitle: 'Buka Agri Asisten Bot',
          color: _green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const VirtualAssistantPage(roleContext: 'Pembeli'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle: 'agriconnect0626@gmail.com',
          color: const Color(0xFFEA4335),
          onTap: () => _launchEmail(context),
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.chat_outlined,
          title: 'WhatsApp',
          subtitle: '+62 856-7890-1234',
          color: const Color(0xFF25D366),
          onTap: () => _launchWhatsApp(context),
        ),
        const SizedBox(height: 12),
        _buildContactTile(
          icon: Icons.phone_outlined,
          title: 'Telepon',
          subtitle: '(021) 1234-5678',
          color: const Color(0xFF1976D2),
          onTap: () => _launchPhone(context),
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFD0D5DD)),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          const Row(
            children: [
              Icon(Icons.help_outline, color: _green, size: 20),
              SizedBox(width: 10),
              Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D2939),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFaqItem('Bagaimana cara melakukan pemesanan?'),
          _buildFaqItem('Berapa lama pengiriman pesanan?'),
          _buildFaqItem('Bagaimana cara membatalkan pesanan?'),
          _buildFaqItem('Bagaimana cara menghubungi penjual?'),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _greenLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF344054),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: _green, size: 20),
          ],
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
    final uri = Uri.parse('https://wa.me/6285678901234');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp tidak tersedia'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<void> _launchPhone(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: '02112345678');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Telepon tidak tersedia'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
