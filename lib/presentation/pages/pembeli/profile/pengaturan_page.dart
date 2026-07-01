import 'package:flutter/material.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenLight = Color(0xFFE8F5E9);

  String _selectedLanguage = 'Indonesia';
  String _selectedTheme = 'Terang';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSection(
                      title: 'Bahasa',
                      icon: Icons.language,
                      children: [
                        _buildRadioTile('Indonesia', 'id', _selectedLanguage == 'Indonesia', () {
                          setState(() => _selectedLanguage = 'Indonesia');
                        }),
                        _buildRadioTile('English', 'en', _selectedLanguage == 'English', () {
                          setState(() => _selectedLanguage = 'English');
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Tema',
                      icon: Icons.palette_outlined,
                      children: [
                        _buildRadioTile('Terang', '☀️', _selectedTheme == 'Terang', () {
                          setState(() => _selectedTheme = 'Terang');
                        }),
                        _buildRadioTile('Gelap', '🌙', _selectedTheme == 'Gelap', () {
                          setState(() => _selectedTheme = 'Gelap');
                        }),
                        _buildRadioTile('Sistem', '⚙️', _selectedTheme == 'Sistem', () {
                          setState(() => _selectedTheme = 'Sistem');
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Tentang Aplikasi',
                      icon: Icons.info_outline,
                      children: [
                        _buildInfoRow('Versi', '1.0.0'),
                        _buildInfoRow('Terakhir diperbarui', '01 Juli 2026'),
                        _buildInfoRow('Pengembang', 'AgriConnect Team'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Lainnya',
                      icon: Icons.more_horiz,
                      children: [
                        _buildActionTile(
                          icon: Icons.description_outlined,
                          title: 'Syarat & Ketentuan',
                          onTap: () {},
                        ),
                        _buildActionTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Kebijakan Privasi',
                          onTap: () {},
                        ),
                        _buildActionTile(
                          icon: Icons.delete_outline,
                          title: 'Hapus Cache',
                          subtitle: '12.4 MB',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Cache berhasil dihapus'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: _green,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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
              'Pengaturan',
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _green, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D2939),
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String title, String subtitle, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? _green : const Color(0xFFD0D5DD),
                  width: 2,
                ),
                color: selected ? _green : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? _green : const Color(0xFF1D2939),
                ),
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1D2939),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF667085), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1D2939),
                ),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF98A2B3)),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Color(0xFFD0D5DD), size: 20),
          ],
        ),
      ),
    );
  }
}
