import 'package:flutter/material.dart';

class NotifikasiSettingsPage extends StatefulWidget {
  const NotifikasiSettingsPage({super.key});

  @override
  State<NotifikasiSettingsPage> createState() => _NotifikasiSettingsPageState();
}

class _NotifikasiSettingsPageState extends State<NotifikasiSettingsPage> {
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenLight = Color(0xFFE8F5E9);

  bool _orderStatus = true;
  bool _delivery = true;
  bool _promo = false;
  bool _chat = true;
  bool _priceAlert = false;
  bool _newsletter = false;

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
                      title: 'Pesanan',
                      icon: Icons.shopping_bag_outlined,
                      children: [
                        _buildToggleTile(
                          title: 'Status Pesanan',
                          subtitle: 'Notifikasi saat status pesanan berubah',
                          value: _orderStatus,
                          onChanged: (v) => setState(() => _orderStatus = v),
                        ),
                        _buildToggleTile(
                          title: 'Pengiriman',
                          subtitle: 'Update pengiriman dan estimasi tiba',
                          value: _delivery,
                          onChanged: (v) => setState(() => _delivery = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Promosi',
                      icon: Icons.local_offer_outlined,
                      children: [
                        _buildToggleTile(
                          title: 'Promo & Diskon',
                          subtitle: 'Info promo dan penawaran menarik',
                          value: _promo,
                          onChanged: (v) => setState(() => _promo = v),
                        ),
                        _buildToggleTile(
                          title: 'Alert Harga',
                          subtitle: 'Notifikasi saat harga produk turun',
                          value: _priceAlert,
                          onChanged: (v) => setState(() => _priceAlert = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'Lainnya',
                      icon: Icons.more_horiz,
                      children: [
                        _buildToggleTile(
                          title: 'Chat',
                          subtitle: 'Pesan dari penjual dan CS',
                          value: _chat,
                          onChanged: (v) => setState(() => _chat = v),
                        ),
                        _buildToggleTile(
                          title: 'Newsletter',
                          subtitle: 'Tips pertanian dan update AgriConnect',
                          value: _newsletter,
                          onChanged: (v) => setState(() => _newsletter = v),
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
              'Notifikasi',
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
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
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
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: _green,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D2939),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF667085),
          ),
        ),
      ),
    );
  }
}
