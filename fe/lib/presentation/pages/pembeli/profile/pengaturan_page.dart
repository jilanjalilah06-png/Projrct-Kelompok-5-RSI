import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/theme_controller.dart';
import '../../../controllers/language_controller.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenLight = Color(0xFFE8F5E9);

  String _selectedTheme = 'Terang';
  String _cacheSize = '12.4 MB';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final mode = context.read<ThemeController>().themeMode;
        setState(() {
          if (mode == ThemeMode.light) {
            _selectedTheme = 'Terang';
          } else if (mode == ThemeMode.dark) {
            _selectedTheme = 'Gelap';
          } else {
            _selectedTheme = 'Sistem';
          }
        });
      }
    });
  }

  Color _getBgColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF121212) : _greenLight;
  }

  Color _getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : const Color(0xFF1D2939);
  }

  Color _getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white70 : const Color(0xFF667085);
  }

  String _t(String key, bool isEnglish) {
    final translations = {
      'pengaturan': {'id': 'Pengaturan', 'en': 'Settings'},
      'bahasa': {'id': 'Bahasa', 'en': 'Language'},
      'tema': {'id': 'Tema', 'en': 'Theme'},
      'terang': {'id': 'Terang', 'en': 'Light'},
      'gelap': {'id': 'Gelap', 'en': 'Dark'},
      'sistem': {'id': 'Sistem', 'en': 'System'},
      'tentang': {'id': 'Tentang Aplikasi', 'en': 'About Application'},
      'versi': {'id': 'Versi', 'en': 'Version'},
      'diperbarui': {'id': 'Terakhir diperbarui', 'en': 'Last updated'},
      'pengembang': {'id': 'Pengembang', 'en': 'Developer'},
      'lainnya': {'id': 'Lainnya', 'en': 'Others'},
      'syarat': {'id': 'Syarat & Ketentuan', 'en': 'Terms & Conditions'},
      'privasi': {'id': 'Kebijakan Privasi', 'en': 'Privacy Policy'},
      'hapus_cache': {'id': 'Hapus Cache', 'en': 'Clear Cache'},
      'cache_bersih': {'id': 'Cache berhasil dihapus', 'en': 'Cache cleared successfully'},
      'lang_bersih': {'id': 'Bahasa berhasil diubah menjadi ', 'en': 'Language successfully changed to '},
      'saya_mengerti': {'id': 'Saya Mengerti', 'en': 'I Understand'},
    };

    final lang = isEnglish ? 'en' : 'id';
    return translations[key]?[lang] ?? key;
  }

  String _getTermsContent(bool isEnglish) {
    if (isEnglish) {
      return 'Welcome to AgriConnect. By using our application, you agree to the following terms & conditions:\n\n'
          '1. Use of Service: This application connects local farmers with buyers for fair and transparent produce transactions.\n\n'
          '2. User Account: You are responsible for maintaining the confidentiality of your password and account.\n\n'
          '3. Transactions: Payments are processed digitally using our integrated online payment gateway (Midtrans) for mutual safety.\n\n'
          '4. Shipping: Farmer partners are responsible for packing and handing over orders to the courier according to the agreed schedule.\n\n'
          '5. Cancellation: Paid transactions can only be cancelled according to the store cancellation policy registered in the system.\n\n'
          'These terms and conditions may be updated at any time by the AgriConnect management without prior notice.';
    } else {
      return 'Selamat datang di AgriConnect. Dengan menggunakan aplikasi kami, Anda menyetujui syarat & ketentuan berikut:\n\n'
          '1. Penggunaan Layanan: Aplikasi ini berfungsi untuk mempertemukan petani lokal dengan pembeli demi transaksi hasil bumi yang adil dan transparan.\n\n'
          '2. Akun Pengguna: Anda bertanggung jawab untuk menjaga kerahasiaan password dan akun Anda.\n\n'
          '3. Transaksi: Pembayaran dilakukan secara digital menggunakan gerbang pembayaran online terintegrasi (Midtrans) demi keamanan bersama.\n\n'
          '4. Pengiriman: Mitra petani bertanggung jawab untuk mengemas dan menyerahkan pesanan kepada kurir sesuai dengan jadwal yang disepakati.\n\n'
          '5. Pembatalan: Transaksi yang sudah dibayar hanya dapat dibatalkan sesuai kebijakan pembatalan toko yang terdaftar di sistem.\n\n'
          'Syarat dan ketentuan ini dapat diperbarui sewaktu-waktu oleh pihak manajemen AgriConnect tanpa pemberitahuan sebelumnya.';
    }
  }

  String _getPrivacyContent(bool isEnglish) {
    if (isEnglish) {
      return 'This Privacy Policy explains how AgriConnect collects, uses, and protects your personal data:\n\n'
          '1. Information Collected: We collect name, shipping address, email address, phone number, and location data for smooth delivery of orders.\n\n'
          '2. Use of Data: Your personal data is only used for processing shopping transactions, managing farmer partner accounts, and improving our services.\n\n'
          '3. Security: We are committed to securing your data using industry-standard encryption and secure JWT token protocols.\n\n'
          '4. Third Parties: We do not sell or distribute your personal data to third parties except for payment verification (Midtrans) or logistics delivery.\n\n'
          'By using this service, you knowingly consent to the personal data handling policy above.';
    } else {
      return 'Kebijakan Privasi ini menjelaskan bagaimana AgriConnect mengumpulkan, menggunakan, dan melindungi data pribadi Anda:\n\n'
          '1. Informasi yang Dikumpulkan: Kami mengumpulkan data nama, alamat pengiriman, alamat email, nomor telepon, dan lokasi Anda demi kepentingan kelancaran pengiriman pesanan.\n\n'
          '2. Penggunaan Data: Data pribadi Anda hanya digunakan untuk kebutuhan pemrosesan transaksi belanja, pengelolaan akun mitra petani, serta peningkatan fitur layanan kami.\n\n'
          '3. Keamanan: Kami berkomitmen menjaga keamanan data Anda dengan menggunakan enkripsi standar industri dan protokol token JWT yang aman.\n\n'
          '4. Pihak Ketiga: Kami tidak akan menjual atau menyebarluaskan data pribadi Anda kepada pihak ketiga selain untuk keperluan verifikasi pembayaran (Midtrans) atau pengiriman logistik.\n\n'
          'Dengan menggunakan layanan ini, Anda secara sadar menyetujui kebijakan penanganan data pribadi di atas.';
    }
  }

  void _showLanguageSnackBar(String lang, bool isEnglish) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_t('lang_bersih', isEnglish) + lang),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _green,
      ),
    );
  }

  void _showDocumentDialog(String title, String content, bool isEnglish) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1D2939),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: isDark ? Colors.white70 : const Color(0xFF667085)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      content,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.white70 : const Color(0xFF475467),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _t('saya_mengerti', isEnglish),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCtrl = context.watch<LanguageController>();
    final isEnglish = langCtrl.isEnglish;

    return Scaffold(
      backgroundColor: _getBgColor(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(isEnglish),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSection(
                      title: _t('bahasa', isEnglish),
                      icon: Icons.language,
                      children: [
                        _buildRadioTile('Indonesia', 'id', langCtrl.selectedLanguage == 'id', () {
                          langCtrl.updateLanguage('id');
                          _showLanguageSnackBar('Indonesia', isEnglish);
                        }),
                        _buildRadioTile('English', 'en', langCtrl.selectedLanguage == 'en', () {
                          langCtrl.updateLanguage('en');
                          _showLanguageSnackBar('English', isEnglish);
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: _t('tema', isEnglish),
                      icon: Icons.palette_outlined,
                      children: [
                        _buildRadioTile(_t('terang', isEnglish), '', _selectedTheme == 'Terang', () {
                          setState(() => _selectedTheme = 'Terang');
                          context.read<ThemeController>().updateTheme(ThemeMode.light);
                        }),
                        _buildRadioTile(_t('gelap', isEnglish), '', _selectedTheme == 'Gelap', () {
                          setState(() => _selectedTheme = 'Gelap');
                          context.read<ThemeController>().updateTheme(ThemeMode.dark);
                        }),
                        _buildRadioTile(_t('sistem', isEnglish), '', _selectedTheme == 'Sistem', () {
                          setState(() => _selectedTheme = 'Sistem');
                          context.read<ThemeController>().updateTheme(ThemeMode.system);
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: _t('tentang', isEnglish),
                      icon: Icons.info_outline,
                      children: [
                        _buildInfoRow(_t('versi', isEnglish), '1.0.0'),
                        _buildInfoRow(_t('diperbarui', isEnglish), isEnglish ? 'July 01, 2026' : '01 Juli 2026'),
                        _buildInfoRow(_t('pengembang', isEnglish), 'AgriConnect Team'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: _t('lainnya', isEnglish),
                      icon: Icons.more_horiz,
                      children: [
                        _buildActionTile(
                          icon: Icons.description_outlined,
                          title: _t('syarat', isEnglish),
                          onTap: () {
                            _showDocumentDialog(
                              _t('syarat', isEnglish),
                              _getTermsContent(isEnglish),
                              isEnglish,
                            );
                          },
                        ),
                        _buildActionTile(
                          icon: Icons.privacy_tip_outlined,
                          title: _t('privasi', isEnglish),
                          onTap: () {
                            _showDocumentDialog(
                              _t('privasi', isEnglish),
                              _getPrivacyContent(isEnglish),
                              isEnglish,
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

  Widget _buildAppBar(bool isEnglish) {
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
          Expanded(
            child: Text(
              _t('pengaturan', isEnglish),
              style: const TextStyle(
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
        color: _getCardColor(context),
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
                    color: _getBgColor(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: _green, size: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(context),
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
                  color: selected ? _green : _getTextColor(context),
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
            style: TextStyle(
              fontSize: 13,
              color: _getSecondaryTextColor(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _getTextColor(context),
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
            Icon(icon, color: _getSecondaryTextColor(context), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(context),
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
