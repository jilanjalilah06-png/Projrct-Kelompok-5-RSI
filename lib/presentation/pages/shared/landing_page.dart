import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'role_selection_screen.dart';
import 'register_info_screen.dart';
import 'virtual_assistant_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  // Global keys for scrolling to sections
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _fiturKey = GlobalKey();
  final GlobalKey _tentangKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _kontakKey = GlobalKey();

  // Constants Colors matching CSS :root
  static const Color green900 = Color(0xFF1B5E20);
  static const Color green800 = Color(0xFF2E7D32);
  static const Color green700 = Color(0xFF388E3C);
  static const Color green500 = Color(0xFF4CAF50);
  static const Color green200 = Color(0xFFA5D6A7);
  static const Color green100 = Color(0xFFC8E6C9);
  static const Color green50 = Color(0xFFF1F8E9);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray600 = Color(0xFF4B5563);

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: white,
      endDrawer: isMobile ? _buildMobileDrawer() : null,
      body: Stack(
        children: [
          // ── Scrollable Body ──
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Spacing corresponding to navbar height
                  const SizedBox(height: 64),

                  // 1. Hero Section
                  _buildHeroSection(
                    key: _heroKey,
                    isMobile: isMobile,
                    width: screenWidth,
                  ),

                  // 2. Features Section
                  _buildFeaturesSection(
                    key: _fiturKey,
                    isMobile: isMobile,
                    width: screenWidth,
                  ),

                  // 3. How It Works Section
                  _buildHowItWorksSection(
                    isMobile: isMobile,
                    width: screenWidth,
                  ),

                  // 4. About Section
                  _buildAboutSection(
                    key: _tentangKey,
                    isMobile: isMobile,
                    width: screenWidth,
                  ),

                  // 5. FAQ Section
                  _buildFaqSection(
                    key: _faqKey,
                    isMobile: isMobile,
                    width: screenWidth,
                  ),

                  // 6. Contact Section
                  _buildContactSection(
                    key: _kontakKey,
                    isMobile: isMobile,
                    width: screenWidth,
                  ),

                  // 7. CTA Banner
                  _buildCtaBanner(isMobile: isMobile),

                  // 8. Footer
                  _buildFooter(isMobile: isMobile),
                ],
              ),
            ),
          ),

          // ── Sticky Header (Navbar) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 64,
            child: _buildNavbar(isMobile: isMobile),
          ),
          // ── Floating Chatbot ──
        ],
      ),
    );
  }

  // ── NAVBAR WIDGET ──
  Widget _buildNavbar({required bool isMobile}) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: green900.withValues(alpha: 0.96),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo & Tagline
              GestureDetector(
                onTap: () => _scrollToSection(_heroKey),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌿 AgriConnect',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 20,
                          color: white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'PLATFORM PERTANIAN DIGITAL',
                        style: TextStyle(
                          fontSize: 9,
                          color: green200,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Links & CTA for Desktop
              if (!isMobile) ...[
                Row(
                  children: [
                    _buildNavLink('Fitur', _fiturKey),
                    const SizedBox(width: 32),
                    _buildNavLink('Tentang', _tentangKey),
                    const SizedBox(width: 32),
                    _buildNavLink('FAQ', _faqKey),
                    const SizedBox(width: 32),
                    _buildNavLink('Kontak', _kontakKey),
                  ],
                ),
                Row(
                  children: [
                    // Masuk button (outline)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: white.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoleSelectionScreen(),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Daftar Sekarang button (solid)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: white,
                        foregroundColor: green900,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterInfoScreen(),
                        ),
                      ),
                      child: const Text(
                        'Daftar Sekarang',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Hamburger icon for Mobile
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: white),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(String label, GlobalKey sectionKey) {
    return GestureDetector(
      onTap: () => _scrollToSection(sectionKey),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          label,
          style: TextStyle(
            color: white.withValues(alpha: 0.85),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ── MOBILE DRAWER ──
  Widget _buildMobileDrawer() {
    return Drawer(
      backgroundColor: green900,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                '🌿 AgriConnect',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  color: white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              title: const Text('Fitur', style: TextStyle(color: white)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(_fiturKey);
              },
            ),
            ListTile(
              title: const Text('Tentang', style: TextStyle(color: white)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(_tentangKey);
              },
            ),
            ListTile(
              title: const Text('FAQ', style: TextStyle(color: white)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(_faqKey);
              },
            ),
            ListTile(
              title: const Text('Kontak', style: TextStyle(color: white)),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(_kontakKey);
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: white),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RoleSelectionScreen(),
                      ),
                    );
                  },
                  child: const Text('Masuk', style: TextStyle(color: white)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                bottom: 24.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: white,
                    foregroundColor: green900,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterInfoScreen(),
                      ),
                    );
                  },
                  child: const Text('Daftar Sekarang'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HERO SECTION WIDGET ──
  Widget _buildHeroSection({
    required Key key,
    required bool isMobile,
    required double width,
  }) {
    final contentPadding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 60)
        : const EdgeInsets.symmetric(horizontal: 48, vertical: 100);

    return Container(
      key: key,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [green900, green800, Color(0xFF1A4A1E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // SVG/Custom Paint grid pattern
          Positioned.fill(
            child: CustomPaint(painter: const GridPatternPainter()),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: contentPadding,
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroText(isMobile: true),
                          const SizedBox(height: 48),
                          _buildHeroVisual(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _buildHeroText(isMobile: false)),
                          const SizedBox(width: 80),
                          SizedBox(width: 360, child: _buildHeroVisual()),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroText({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: white.withValues(alpha: 0.2)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌿 ', style: TextStyle(fontSize: 14)),
              Text(
                'PLATFORM PERTANIAN DIGITAL V2.0',
                style: TextStyle(
                  color: green200,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Title
        RichText(
          text: TextSpan(
            style: GoogleFonts.playfairDisplay(
              fontSize: 48,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: white,
            ),
            children: const [
              TextSpan(text: 'Kelola Panen,\n'),
              TextSpan(
                text: 'Jual Lebih Mudah',
                style: TextStyle(color: green200),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Subtitle
        Text(
          'AgriConnect menghubungkan petani, pendamping, dan pembeli dalam satu platform digital yang cerdas — dari pencatatan panen hingga transaksi, semua dalam genggaman.',
          style: TextStyle(
            fontSize: 16,
            color: white.withValues(alpha: 0.75),
            height: 1.7,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 36),
        // Buttons
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: white,
                foregroundColor: green900,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterInfoScreen()),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🚀 Mulai Gratis',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                backgroundColor: white.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _scrollToSection(_fiturKey),
              child: const Text(
                '✦ Lihat Fitur',
                style: TextStyle(
                  color: white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroVisual() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedStatCard(
          icon: '🌾',
          value: '2.4 Ton',
          label: 'Total Panen Tercatat',
          delay: 200,
          marginLeft: 0,
        ),
        const SizedBox(height: 12),
        _buildAnimatedStatCard(
          icon: '🛒',
          value: '512 Order',
          label: 'Transaksi Bulan Ini',
          delay: 350,
          marginLeft: 0,
        ),
        const SizedBox(height: 12),
        _buildAnimatedStatCard(
          icon: '👨‍🌾',
          value: '128 Petani',
          label: 'Tergabung di Platform',
          delay: 500,
          marginLeft: 0,
        ),
      ],
    );
  }

  Widget _buildAnimatedStatCard({
    required String icon,
    required String value,
    required String label,
    required int delay,
    required double marginLeft,
  }) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: delay)),
      builder: (context, snapshot) {
        final bool show = snapshot.connectionState == ConnectionState.done;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          opacity: show ? 1.0 : 0.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(
              marginLeft,
              show ? 0.0 : 20.0,
              0.0,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            decoration: BoxDecoration(
              color: white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 22,
                          color: white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: green200,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── FEATURES SECTION WIDGET ──
  Widget _buildFeaturesSection({
    required Key key,
    required bool isMobile,
    required double width,
  }) {
    final padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 60)
        : const EdgeInsets.symmetric(horizontal: 48, vertical: 96);

    return Container(
      key: key,
      color: white,
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: padding,
            child: Column(
              children: [
                _buildSectionHeader(
                  tag: 'FITUR UNGGULAN',
                  title: 'Semua yang Kamu Butuhkan',
                  description:
                      'Dirancang khusus untuk ekosistem pertanian Indonesia — dari petani hingga pembeli.',
                ),
                const SizedBox(height: 56),

                // Responsive Feature Cards Grid
                LayoutBuilder(
                  builder: (context, gridConstraints) {
                    if (width > 900) {
                      // 3 Columns
                      return Table(
                        children: [
                          TableRow(
                            children: [
                              _buildFeatureCard(
                                icon: '📋',
                                title: 'Pencatatan Hasil Panen',
                                desc:
                                    'Catat setiap hasil panen dengan detail komoditas, jumlah, kualitas, dan foto langsung dari aplikasi.',
                                tag: 'Petani',
                              ),
                              _buildFeatureCard(
                                icon: '📅',
                                title: 'Jadwal Tanam Cerdas',
                                desc:
                                    'Buat jadwal tanam dan estimasi panen otomatis. Dapatkan notifikasi email H-7 & H-1 sebelum panen.',
                                tag: 'Petani',
                              ),
                              _buildFeatureCard(
                                icon: '💰',
                                title: 'Catatan Biaya Produksi',
                                desc:
                                    'Kelola biaya bibit, pupuk, pestisida, dan tenaga kerja. Hitung keuntungan bersih per musim tanam.',
                                tag: 'Petani',
                              ),
                            ],
                          ),
                          const TableRow(
                            children: [
                              SizedBox(height: 24),
                              SizedBox(height: 24),
                              SizedBox(height: 24),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildFeatureCard(
                                icon: '🛒',
                                title: 'Pemesanan & Pembayaran',
                                desc:
                                    'Pembeli dapat memesan langsung dari stok petani dan membayar via GoPay, OVO, DANA, atau ShopeePay.',
                                tag: 'Pembeli',
                              ),
                              _buildFeatureCard(
                                icon: '📊',
                                title: 'Laporan Keuangan PDF',
                                desc:
                                    'Lihat laporan lengkap panen, transaksi, dan keuntungan. Ekspor ke PDF kapan saja.',
                                tag: 'Petani',
                              ),
                              _buildFeatureCard(
                                icon: '🤖',
                                title: 'Asisten Virtual AI',
                                desc:
                                    'Tanya cara panen yang baik, perawatan tanaman, atau panduan penggunaan fitur lewat chatbot AI.',
                                tag: 'Semua Pengguna',
                              ),
                            ],
                          ),
                        ],
                      );
                    } else if (width > 600) {
                      // 2 Columns
                      return Table(
                        children: [
                          TableRow(
                            children: [
                              _buildFeatureCard(
                                icon: '📋',
                                title: 'Pencatatan Hasil Panen',
                                desc:
                                    'Catat setiap hasil panen dengan detail komoditas, jumlah, kualitas, dan foto langsung dari aplikasi.',
                                tag: 'Petani',
                              ),
                              _buildFeatureCard(
                                icon: '📅',
                                title: 'Jadwal Tanam Cerdas',
                                desc:
                                    'Buat jadwal tanam dan estimasi panen otomatis. Dapatkan notifikasi email H-7 & H-1 sebelum panen.',
                                tag: 'Petani',
                              ),
                            ],
                          ),
                          const TableRow(
                            children: [
                              SizedBox(height: 24),
                              SizedBox(height: 24),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildFeatureCard(
                                icon: '💰',
                                title: 'Catatan Biaya Produksi',
                                desc:
                                    'Kelola biaya bibit, pupuk, pestisida, dan tenaga kerja. Hitung keuntungan bersih per musim tanam.',
                                tag: 'Petani',
                              ),
                              _buildFeatureCard(
                                icon: '🛒',
                                title: 'Pemesanan & Pembayaran',
                                desc:
                                    'Pembeli dapat memesan langsung dari stok petani dan membayar via GoPay, OVO, DANA, atau ShopeePay.',
                                tag: 'Pembeli',
                              ),
                            ],
                          ),
                          const TableRow(
                            children: [
                              SizedBox(height: 24),
                              SizedBox(height: 24),
                            ],
                          ),
                          TableRow(
                            children: [
                              _buildFeatureCard(
                                icon: '📊',
                                title: 'Laporan Keuangan PDF',
                                desc:
                                    'Lihat laporan lengkap panen, transaksi, dan keuntungan. Ekspor ke PDF kapan saja.',
                                tag: 'Petani',
                              ),
                              _buildFeatureCard(
                                icon: '🤖',
                                title: 'Asisten Virtual AI',
                                desc:
                                    'Tanya cara panen yang baik, perawatan tanaman, atau panduan penggunaan fitur lewat chatbot AI.',
                                tag: 'Semua Pengguna',
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // 1 Column
                      return Column(
                        children: [
                          _buildFeatureCard(
                            icon: '📋',
                            title: 'Pencatatan Hasil Panen',
                            desc:
                                'Catat setiap hasil panen dengan detail komoditas, jumlah, kualitas, dan foto langsung dari aplikasi.',
                            tag: 'Petani',
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureCard(
                            icon: '📅',
                            title: 'Jadwal Tanam Cerdas',
                            desc:
                                'Buat jadwal tanam dan estimasi panen otomatis. Dapatkan notifikasi email H-7 & H-1 sebelum panen.',
                            tag: 'Petani',
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureCard(
                            icon: '💰',
                            title: 'Catatan Biaya Produksi',
                            desc:
                                'Kelola biaya bibit, pupuk, pestisida, dan tenaga kerja. Hitung keuntungan bersih per musim tanam.',
                            tag: 'Petani',
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureCard(
                            icon: '🛒',
                            title: 'Pemesanan & Pembayaran',
                            desc:
                                'Pembeli dapat memesan langsung dari stok petani dan membayar via GoPay, OVO, DANA, atau ShopeePay.',
                            tag: 'Pembeli',
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureCard(
                            icon: '📊',
                            title: 'Laporan Keuangan PDF',
                            desc:
                                'Lihat laporan lengkap panen, transaksi, dan keuntungan. Ekspor ke PDF kapan saja.',
                            tag: 'Petani',
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureCard(
                            icon: '🤖',
                            title: 'Asisten Virtual AI',
                            desc:
                                'Tanya cara panen yang baik, perawatan tanaman, atau panduan penggunaan fitur lewat chatbot AI.',
                            tag: 'Semua Pengguna',
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String icon,
    required String title,
    required String desc,
    required String tag,
  }) {
    Color tagBgColor;
    Color tagTextColor;
    if (tag == 'Petani') {
      tagBgColor = green100;
      tagTextColor = green900;
    } else if (tag == 'Pembeli') {
      tagBgColor = const Color(0xFFFFF8E1);
      tagTextColor = const Color(0xFFE65100);
    } else {
      tagBgColor = const Color(0xFFF3E5F5);
      tagTextColor = const Color(0xFF6A1B9A);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: HoverCard(
        onTap: () {
          if (title != 'Asisten Virtual AI') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterInfoScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VirtualAssistantPage()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(icon, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: green900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 14,
                  color: gray600,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: tagBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tagTextColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HOW IT WORKS SECTION WIDGET ──
  Widget _buildHowItWorksSection({
    required bool isMobile,
    required double width,
  }) {
    final padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 60)
        : const EdgeInsets.symmetric(horizontal: 48, vertical: 96);

    return Container(
      color: green50,
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: padding,
            child: Column(
              children: [
                _buildSectionHeader(
                  tag: 'CARA KERJA',
                  title: 'Mudah Digunakan',
                  description:
                      'Mulai dalam hitungan menit, tanpa perlu keahlian teknis.',
                ),
                const SizedBox(height: 56),

                // Steps layout
                isMobile
                    ? Column(
                        children: [
                          _buildStepItem(
                            num: '1',
                            title: 'Daftar Akun',
                            desc:
                                'Buat akun sebagai Petani atau Pembeli secara gratis.',
                          ),
                          const SizedBox(height: 32),
                          _buildStepItem(
                            num: '2',
                            title: 'Catat & Kelola',
                            desc:
                                'Petani mencatat panen, jadwal, dan biaya produksi.',
                          ),
                          const SizedBox(height: 32),
                          _buildStepItem(
                            num: '3',
                            title: 'Publikasi Stok',
                            desc:
                                'Petani mempublikasikan stok panen ke halaman publik.',
                          ),
                          const SizedBox(height: 32),
                          _buildStepItem(
                            num: '4',
                            title: 'Transaksi',
                            desc:
                                'Pembeli memesan dan membayar langsung via e-wallet.',
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          // Path Line Behind Circles
                          Positioned(
                            top: 32,
                            left: 80,
                            right: 80,
                            height: 2,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [green200, green500, green200],
                                ),
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildStepItem(
                                  num: '1',
                                  title: 'Daftar Akun',
                                  desc:
                                      'Buat akun sebagai Petani atau Pembeli secara gratis.',
                                ),
                              ),
                              Expanded(
                                child: _buildStepItem(
                                  num: '2',
                                  title: 'Catat & Kelola',
                                  desc:
                                      'Petani mencatat panen, jadwal, dan biaya produksi.',
                                ),
                              ),
                              Expanded(
                                child: _buildStepItem(
                                  num: '3',
                                  title: 'Publikasi Stok',
                                  desc:
                                      'Petani mempublikasikan stok panen ke halaman publik.',
                                ),
                              ),
                              Expanded(
                                child: _buildStepItem(
                                  num: '4',
                                  title: 'Transaksi',
                                  desc:
                                      'Pembeli memesan dan membayar langsung via e-wallet.',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required String num,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: green800,
              shape: BoxShape.circle,
              border: Border.all(color: green50, width: 4),
              boxShadow: [
                BoxShadow(
                  color: green800.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              num,
              style: GoogleFonts.playfairDisplay(
                color: white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: green900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: gray600, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── ABOUT SECTION WIDGET ──
  Widget _buildAboutSection({
    required Key key,
    required bool isMobile,
    required double width,
  }) {
    final padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 60)
        : const EdgeInsets.symmetric(horizontal: 48, vertical: 96);

    return Container(
      key: key,
      color: white,
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: padding,
            child: isMobile || width < 850
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAboutText(),
                      const SizedBox(height: 48),
                      _buildAboutVisual(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: _buildAboutText()),
                      const SizedBox(width: 80),
                      SizedBox(width: 380, child: _buildAboutVisual()),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section tag
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: green50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'TENTANG AGRICONNECT',
            style: TextStyle(
              color: green800,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Text(
          'Platform Pertanian Digital untuk Indonesia',
          style: GoogleFonts.playfairDisplay(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: green900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'AgriConnect adalah sistem informasi pertanian berbasis web dan mobile yang dirancang untuk membantu petani dan pendamping dalam mengelola seluruh siklus pertanian — dari perencanaan tanam hingga penjualan hasil panen.',
          style: TextStyle(fontSize: 15, color: gray600, height: 1.8),
        ),
        const SizedBox(height: 14),
        const Text(
          'Dibangun di atas Laravel 13 REST API dan Flutter, platform ini mengintegrasikan pencatatan panen, manajemen jadwal, biaya produksi, laporan keuangan, hingga marketplace sederhana untuk menghubungkan petani dan pembeli secara langsung.',
          style: TextStyle(fontSize: 15, color: gray600, height: 1.8),
        ),
        const SizedBox(height: 24),
        // Pills Wrap
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTechPill('🌿 Laravel 13'),
            _buildTechPill('📱 Flutter'),
            _buildTechPill('🔒 Laravel Sanctum'),
            _buildTechPill('💳 Midtrans'),
            _buildTechPill('🤖 n8n AI'),
            _buildTechPill('🐳 Docker'),
          ],
        ),
      ],
    );
  }

  Widget _buildTechPill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: green50,
        border: Border.all(color: green100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: green800,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAboutVisual() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [green900, green700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: green900.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌾 Statistik Platform',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              color: white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatRow('Petani Terdaftar', '128+'),
          _buildStatRow('Pembeli Aktif', '340+'),
          _buildStatRow('Total Panen Tercatat', '2.4 Ton'),
          _buildStatRow('Total Transaksi', 'Rp 48 Juta'),
          _buildStatRow('Komoditas Tersedia', '12 Jenis', isLast: true),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String val, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: green200)),
          Text(
            val,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: white,
            ),
          ),
        ],
      ),
    );
  }

  // ── FAQ SECTION WIDGET ──
  Widget _buildFaqSection({
    required Key key,
    required bool isMobile,
    required double width,
  }) {
    final padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 60)
        : const EdgeInsets.symmetric(horizontal: 48, vertical: 96);

    return Container(
      key: key,
      color: gray50,
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: padding,
            child: Column(
              children: [
                _buildSectionHeader(
                  tag: 'FAQ',
                  title: 'Pertanyaan yang Sering Ditanyakan',
                  description:
                      'Tidak menemukan jawaban? Hubungi kami langsung.',
                ),
                const SizedBox(height: 56),

                // FAQ Accordion List
                FaqItemWidget(
                  question: 'Apa itu AgriConnect?',
                  answer:
                      'AgriConnect adalah platform digital pertanian yang membantu petani mencatat hasil panen, mengelola jadwal tanam, mencatat biaya produksi, mempublikasikan stok jual, dan mengelola laporan keuangan. Pembeli dapat memesan langsung dan membayar via e-wallet.',
                  initiallyOpen: true,
                ),
                const FaqItemWidget(
                  question: 'Siapa saja yang bisa menggunakan AgriConnect?',
                  answer:
                      'AgriConnect dapat digunakan oleh Petani dan Pendamping untuk mengelola data pertanian, Pembeli untuk memesan produk segar langsung dari petani, dan Admin untuk mengelola platform secara keseluruhan.',
                ),
                const FaqItemWidget(
                  question: 'Apakah AgriConnect gratis?',
                  answer:
                      'Pendaftaran akun di AgriConnect gratis. Biaya hanya dikenakan pada transaksi pembayaran melalui Midtrans sesuai dengan ketentuan payment gateway yang berlaku.',
                ),
                const FaqItemWidget(
                  question: 'Metode pembayaran apa yang tersedia?',
                  answer:
                      'AgriConnect mendukung pembayaran via e-wallet: GoPay, OVO, DANA, dan ShopeePay melalui integrasi Midtrans Payment Gateway yang aman dan terpercaya.',
                ),
                const FaqItemWidget(
                  question: 'Bagaimana cara mengakses AgriConnect?',
                  answer:
                      'AgriConnect dapat diakses melalui Flutter Web di browser Chrome/Firefox untuk semua pengguna, dan melalui Flutter APK (Android 8.0+) yang dapat diunduh untuk petani, pendamping, dan pembeli.',
                ),
                const FaqItemWidget(
                  question: 'Apakah data saya aman?',
                  answer:
                      'Ya. AgriConnect menggunakan HTTPS/TLS 1.3 untuk semua komunikasi, Laravel Sanctum untuk autentikasi token, password di-hash dengan bcrypt, dan semua data pengguna dikelola sesuai UU PDP No. 27/2022.',
                ),
                const FaqItemWidget(
                  question: 'Apa itu fitur Asisten Virtual AI?',
                  answer:
                      'Asisten Virtual AI adalah fitur chatbot yang membantu pengguna menjawab pertanyaan seputar teknik pertanian (cara panen, perawatan tanaman, dll) dan panduan penggunaan fitur aplikasi. Didukung oleh n8n workflow automation yang terintegrasi dengan LLM.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── CONTACT SECTION WIDGET ──
  Widget _buildContactSection({
    required Key key,
    required bool isMobile,
    required double width,
  }) {
    final padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 60)
        : const EdgeInsets.symmetric(horizontal: 48, vertical: 96);

    return Container(
      key: key,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [green900, green800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      width: double.infinity,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: padding,
            child: Column(
              children: [
                // Header (with transparent/white text variant)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'HUBUNGI KAMI',
                    style: TextStyle(
                      color: green200,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Text(
                  'Ada Pertanyaan?',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tim AgriConnect siap membantu kamu. Hubungi kami melalui salah satu saluran berikut.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 48),

                // Grid/Column of Contacts
                isMobile || width < 700
                    ? Column(
                        children: [
                          _buildContactCard(
                            icon: '📧',
                            label: 'Email',
                            value: 'support@agriconnect.id',
                            isLink: true,
                            onTap: () => _launchContactEmail(context),
                          ),
                          const SizedBox(height: 20),
                          _buildContactCard(
                            icon: '💬',
                            label: 'WhatsApp',
                            value: '+62 812-3456-7890',
                            isLink: true,
                            onTap: () => _launchWhatsApp(context),
                          ),
                          const SizedBox(height: 20),
                          _buildContactCard(
                            icon: '🕐',
                            label: 'Jam Operasional',
                            value: 'Senin – Jumat, 08.00 – 17.00 WIB',
                            isLink: false,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildContactCard(
                              icon: '📧',
                              label: 'Email',
                              value: 'support@agriconnect.id',
                              isLink: true,
                              onTap: () => _launchContactEmail(context),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildContactCard(
                              icon: '💬',
                              label: 'WhatsApp',
                              value: '+62 812-3456-7890',
                              isLink: true,
                              onTap: () => _launchWhatsApp(context),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildContactCard(
                              icon: '🕐',
                              label: 'Jam Operasional',
                              value: 'Senin – Jumat, 08.00 – 17.00 WIB',
                              isLink: false,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String icon,
    required String label,
    required String value,
    required bool isLink,
    VoidCallback? onTap,
  }) {
    return HoverContactCard(
      onTap: onTap,
      child: MouseRegion(
        cursor: isLink ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: green200,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: white,
                  fontWeight: FontWeight.w500,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchContactEmail(BuildContext context) async {
    final mailUri = Uri(
      scheme: 'mailto',
      path: 'support@agriconnect.id',
      queryParameters: const {'subject': 'Bantuan AgriConnect'},
    );

    final launched = await launchUrl(
      mailUri,
      mode: LaunchMode.externalApplication,
    );
    if (launched) return;

    final gmailUri = Uri.https('mail.google.com', '/mail/', {
      'view': 'cm',
      'fs': '1',
      'to': 'support@agriconnect.id',
      'su': 'Bantuan AgriConnect',
    });
    final openedGmail = await launchUrl(
      gmailUri,
      mode: LaunchMode.externalApplication,
    );

    if (!openedGmail && context.mounted) {
      _showContactError(context);
    }
  }

  Future<void> _launchWhatsApp(BuildContext context) async {
    final uri = Uri.https('wa.me', '/6281234567890', {
      'text': 'Halo AgriConnect, saya ingin bertanya.',
    });
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      _showContactError(context);
    }
  }

  void _showContactError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tidak bisa membuka aplikasi kontak.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── CTA BANNER WIDGET ──
  Widget _buildCtaBanner({required bool isMobile}) {
    final padding = isMobile
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 60)
        : const EdgeInsets.symmetric(horizontal: 48, vertical: 72);

    return Container(
      color: green50,
      width: double.infinity,
      padding: padding,
      child: Column(
        children: [
          Text(
            'Siap Memulai?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: green900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bergabunglah dengan ratusan petani yang sudah menggunakan AgriConnect.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: gray600),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: green800,
                  foregroundColor: white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterInfoScreen()),
                ),
                child: const Text(
                  '🚀 Daftar Sekarang — Gratis',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: green200, width: 1.5),
                  backgroundColor: white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 36,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RoleSelectionScreen(),
                  ),
                ),
                child: const Text(
                  'Sudah punya akun? Masuk',
                  style: TextStyle(
                    color: green800,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── FOOTER WIDGET ──
  Widget _buildFooter({required bool isMobile}) {
    final padding = isMobile
        ? const EdgeInsets.all(24.0)
        : const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0);

    return Container(
      color: green900,
      padding: padding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: isMobile
              ? Column(
                  children: [
                    Text(
                      '🌿 AgriConnect',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '© 2026 AgriConnect — Kelompok 5, Rekayasa Sistem Informasi',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Laravel 13 · Flutter · MySQL 8.0',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🌿 AgriConnect',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: white,
                      ),
                    ),
                    const Text(
                      '© 2026 AgriConnect — Kelompok 5, Rekayasa Sistem Informasi',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    const Text(
                      'Laravel 13 · Flutter · MySQL 8.0',
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ── SECTION HEADER HELPER WIDGET ──
  Widget _buildSectionHeader({
    required String tag,
    required String title,
    required String description,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: green50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              color: green800,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: green900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: gray600),
        ),
      ],
    );
  }
}

// ── CUSTOM GRID PATTERN PAINTER ──
class GridPatternPainter extends CustomPainter {
  const GridPatternPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double step = 60.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        // Draw small crosses matching SVG pattern
        canvas.drawLine(Offset(x - 4, y), Offset(x + 4, y), paint);
        canvas.drawLine(Offset(x, y - 4), Offset(x, y + 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── HOVERCARD COMPONENT FOR FEATURES ──
class HoverCard extends StatefulWidget {
  final Widget child;
  final Function()? onTap;
  const HoverCard({super.key, required this.child, this.onTap});

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFFA5D6A7)
                : const Color(0xFFF3F4F6),
            width: 1.5,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                blurRadius: 32,
                offset: const Offset(0, 12),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── HOVERCONTACTCARD COMPONENT FOR CONTACTS ──
class HoverContactCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const HoverContactCard({super.key, required this.child, this.onTap});

  @override
  State<HoverContactCard> createState() => _HoverContactCardState();
}

class _HoverContactCardState extends State<HoverContactCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ── FAQ ACCORDION COMPONENT ──
class FaqItemWidget extends StatefulWidget {
  final String question;
  final String answer;
  final bool initiallyOpen;
  const FaqItemWidget({
    super.key,
    required this.question,
    required this.answer,
    this.initiallyOpen = false,
  });

  @override
  State<FaqItemWidget> createState() => _FaqItemWidgetState();
}

class _FaqItemWidgetState extends State<FaqItemWidget>
    with SingleTickerProviderStateMixin {
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.initiallyOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isOpen = !_isOpen),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.125 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF388E3C),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 22, right: 22, bottom: 18),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                  height: 1.7,
                ),
              ),
            ),
            crossFadeState: _isOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
