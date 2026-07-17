import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/user_model.dart';
import '../../controllers/admin_controller.dart';
import 'admin_komisi_pencairan_screen.dart';
import '../../../core/constanst/api_constants.dart';

class AdminPetaniDetailScreen extends StatefulWidget {
  final UserModel user;

  const AdminPetaniDetailScreen({super.key, required this.user});

  @override
  State<AdminPetaniDetailScreen> createState() => _AdminPetaniDetailScreenState();
}

class _AdminPetaniDetailScreenState extends State<AdminPetaniDetailScreen> {
  static const Color _bg = Color(0xFFF2ECE0);
  static const Color _textDark = Color(0xFF132A1D);
  static const Color _textMuted = Color(0xFF6E7E75);
  static const Color _primary = Color(0xFF2C6A4F);

  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadOrders();
      // Load products if not loaded or just to refresh
      final ctrl = context.read<AdminController>();
      ctrl.loadDashboard(); // loads dashboard stats
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // If not verified, show Verification layout, otherwise show Detail layout
    final isVerified = _currentUser.isVerified;

    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PETANI',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isVerified ? 'Detail Petani' : 'Verifikasi Petani',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 28,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textDark,
                  side: const BorderSide(color: Colors.black12),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Kembali ke Daftar Petani', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),

            // Profile Header Card
            _buildProfileCard(isVerified),
            const SizedBox(height: 24),

            // Main Content
            isVerified ? _buildDetailContent() : _buildVerificationContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(bool isVerified) {
    final initials = _currentUser.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final address = _currentUser.address ?? (isVerified ? 'Bandung, Jawa Barat' : 'Garut, Jawa Barat');
    final shopName = _currentUser.shopName ?? (isVerified ? 'Sawah A' : '');
    final phone = _currentUser.phone ?? '0812-4471-0093';
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    Widget avatar = CircleAvatar(
      radius: 28,
      backgroundColor: isVerified ? const Color(0xFFE5DFD3) : const Color(0xFFF5E1C8),
      backgroundImage: _currentUser.avatar != null && _currentUser.avatar!.isNotEmpty
          ? NetworkImage('${ApiConstants.storageUrl}/${_currentUser.avatar}')
          : null,
      child: _currentUser.avatar != null && _currentUser.avatar!.isNotEmpty
          ? null
          : Text(
              initials,
              style: TextStyle(
                color: isVerified ? const Color(0xFF5D4037) : const Color(0xFFB57018),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
    );

    Widget infoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentUser.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark),
        ),
        const SizedBox(height: 4),
        Text(
          isVerified ? 'Lahan: ${shopName.isEmpty ? '-' : shopName} • $address • $phone • Bergabung 14 Mar 2026'
                     : '$address · $phone · Mendaftar 02 Jul 2026, 10:15',
          style: const TextStyle(color: _textMuted, fontSize: 13),
        ),
      ],
    );

    Widget statusChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: !isVerified
            ? const Color(0xFFB57018).withValues(alpha: 0.1)
            : (_currentUser.isActive
                ? const Color(0xFF2C6A4F).withValues(alpha: 0.1)
                : const Color(0xFFD32F2F).withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        !isVerified
            ? 'Menunggu verifikasi'
            : (_currentUser.isActive ? 'Aktif' : 'Nonaktif'),
        style: TextStyle(
          color: !isVerified
              ? const Color(0xFFB57018)
              : (_currentUser.isActive ? const Color(0xFF2C6A4F) : const Color(0xFFD32F2F)),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    Widget actionButton = isVerified
        ? OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: _currentUser.isActive ? const Color(0xFFD32F2F) : const Color(0xFF2C6A4F),
              side: BorderSide(color: _currentUser.isActive ? const Color(0xFFD32F2F) : const Color(0xFF2C6A4F)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              try {
                await context.read<AdminController>().togglePetaniStatus(_currentUser.id);
                setState(() {
                  _currentUser = _currentUser.copyWith(isActive: !_currentUser.isActive);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Status keaktifan ${_currentUser.name} berhasil diperbarui')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal mengubah status: $e')),
                );
              }
            },
            child: Text(_currentUser.isActive ? 'Nonaktifkan Akun' : 'Aktifkan Akun'),
          )
        : const SizedBox();

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                avatar,
                const SizedBox(width: 16),
                Expanded(child: infoColumn),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                statusChip,
                if (isVerified) actionButton,
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 16),
          Expanded(child: infoColumn),
          const SizedBox(width: 16),
          statusChip,
          const SizedBox(width: 16),
          if (isVerified) actionButton,
        ],
      ),
    );
  }

  Widget _buildDetailContent() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth < 900;
    final admin = context.watch<AdminController>();

    // Calculate actual orders and sales for this farmer
    final farmerOrders = admin.orders.where((order) {
      final itemsList = order.items ?? [];
      return itemsList.any((item) => item.product?['seller_id'] == _currentUser.id);
    }).toList();

    double grossRevenue = 0;
    for (final order in farmerOrders) {
      final statusLower = order.status.toLowerCase();
      if (statusLower == 'completed' || statusLower == 'selesai' || statusLower == 'paid' || statusLower == 'delivered') {
        for (final item in (order.items ?? [])) {
          if (item.product?['seller_id'] == _currentUser.id) {
            grossRevenue += item.totalPrice;
          }
        }
      }
    }
    // Matching 6% Admin commission from OrderController.php
    final netRevenue = grossRevenue * 0.94;
    final commissionValue = grossRevenue * 0.06;

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Products list for this farmer
    final farmerProducts = admin.products.where((p) => p.sellerId == _currentUser.id).toList();
    final totalProductsCount = farmerProducts.length;
    final productsText = totalProductsCount == 0 ? '-' : farmerProducts.map((p) => p.name).join(', ');

    // 4 Stat Cards
    Widget statCardsSection;
    if (isMobileLayout) {
      final double cardWidth = screenWidth < 550 ? double.infinity : (screenWidth - 48 - 16) / 2;
      statCardsSection = Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          SizedBox(width: cardWidth, child: _buildStatCard('TOTAL LAHAN', '0.8 ha', '1 lahan terdaftar', const Color(0xFF2C6A4F))),
          SizedBox(width: cardWidth, child: _buildStatCard('PRODUK AKTIF', '$totalProductsCount', productsText, const Color(0xFF2C6A4F))),
          SizedBox(width: cardWidth, child: _buildStatCard('TOTAL PENJUALAN KOTOR', formatter.format(grossRevenue), 'Sepanjang bergabung', const Color(0xFF2C6A4F))),
          SizedBox(width: cardWidth, child: _buildStatCard('TOTAL PENJUALAN BERSIH', formatter.format(netRevenue), 'Sepanjang bergabung', const Color(0xFFB57018))),
        ],
      );
    } else {
      statCardsSection = Row(
        children: [
          Expanded(child: _buildStatCard('TOTAL LAHAN', '0.8 ha', '1 lahan terdaftar', const Color(0xFF2C6A4F))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('PRODUK AKTIF', '$totalProductsCount', productsText, const Color(0xFF2C6A4F))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('TOTAL PENJUALAN KOTOR', formatter.format(grossRevenue), 'Sepanjang bergabung', const Color(0xFF2C6A4F))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('TOTAL PENJUALAN BERSIH', formatter.format(netRevenue), 'Sepanjang bergabung', const Color(0xFFB57018))),
        ],
      );
    }

    final Widget lahanTerdaftarCard = _buildCardContainer(
      title: 'Lahan Terdaftar',
      subtitle: 'Plot yang dikelola petani ini',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          horizontalMargin: 0,
          columnSpacing: 24,
          columns: const [
            DataColumn(label: Text('NAMA LAHAN', style: _headerStyle)),
            DataColumn(label: Text('LUAS', style: _headerStyle)),
            DataColumn(label: Text('KOMODITAS', style: _headerStyle)),
            DataColumn(label: Text('STATUS TANAM', style: _headerStyle)),
          ],
          rows: [
            DataRow(cells: [
              DataCell(Text(_currentUser.shopName ?? 'Sawah ${_currentUser.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
              const DataCell(Text('0.8 ha', style: TextStyle(fontSize: 13))),
              const DataCell(Text('Beras/Jagung', style: TextStyle(fontSize: 13))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C6A4F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Aktif', style: TextStyle(color: Color(0xFF2C6A4F), fontSize: 11, fontWeight: FontWeight.bold)),
              )),
            ]),
          ],
        ),
      ),
    );

    final Widget identitasCard = _buildCardContainer(
      title: 'Identitas & Dokumen',
      subtitle: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildField('NIK', _currentUser.nik ?? '-')),
              const SizedBox(width: 16),
              Expanded(child: _buildField('TGL GABUNG', _currentUser.createdAt != null ? DateFormat('dd MMM yyyy').format(_currentUser.createdAt!) : '-')),
            ],
          ),
          const SizedBox(height: 16),
          _buildField('ALAMAT LAHAN', _currentUser.address ?? 'Kp. Sukamaju, Bandung, Jawa Barat'),
          const SizedBox(height: 16),
          const Text('DOKUMEN PENDUKUNG', style: _headerStyle),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_file, size: 16, color: _textMuted),
                SizedBox(width: 8),
                Text('Foto Lahan.jpg', style: TextStyle(color: _textMuted, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );

    final Widget produkAktifCard = _buildCardContainer(
      title: 'Produk Aktif',
      subtitle: '',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          horizontalMargin: 0,
          columnSpacing: 48,
          columns: const [
            DataColumn(label: Text('PRODUK', style: _headerStyle)),
            DataColumn(label: Text('STOK', style: _headerStyle)),
            DataColumn(label: Text('HARGA/KG', style: _headerStyle)),
          ],
          rows: farmerProducts.isEmpty
              ? [
                  DataRow(cells: [
                    DataCell(Text('Belum ada produk', style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic, fontSize: 13))),
                    const DataCell(Text('-')),
                    const DataCell(Text('-')),
                  ])
                ]
              : farmerProducts.map((p) {
                  return DataRow(cells: [
                    DataCell(Text(p.name, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text('${p.stock} ${p.unit}', style: const TextStyle(fontSize: 13))),
                    DataCell(Text(formatter.format(p.price), style: const TextStyle(fontSize: 13))),
                  ]);
                }).toList(),
        ),
      ),
    );

    final Widget ringkasanKomisiCard = _buildCardContainer(
      title: 'Ringkasan Komisi',
      subtitle: 'Rekap potongan komisi platform',
      child: Column(
        children: [
          _buildSummaryRow('Total penjualan kotor', formatter.format(grossRevenue)),
          const SizedBox(height: 12),
          _buildSummaryRow('Komisi admin (6%)', '- ${formatter.format(commissionValue)}', valueColor: const Color(0xFFD32F2F)),
          const Divider(height: 24),
          _buildSummaryRow('Total penjualan bersih', formatter.format(netRevenue), isBold: true),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB57018),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminKomisiPencairanScreen(),
                  ),
                );
              },
              child: const Text('Ke Halaman Pencairan', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        statCardsSection,
        const SizedBox(height: 24),
        if (isMobileLayout) ...[
          lahanTerdaftarCard,
          const SizedBox(height: 24),
          identitasCard,
          const SizedBox(height: 24),
          produkAktifCard,
          const SizedBox(height: 24),
          ringkasanKomisiCard,
        ] else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: lahanTerdaftarCard),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: identitasCard),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: produkAktifCard),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: ringkasanKomisiCard),
            ],
          ),
        ],
        const SizedBox(height: 24),
        _buildCardContainer(
          title: 'Riwayat Pesanan',
          subtitle: 'Transaksi yang melibatkan petani ini',
          child: SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                horizontalMargin: 0,
                columnSpacing: 64,
                columns: const [
                  DataColumn(label: Text('ID PESANAN', style: _headerStyle)),
                  DataColumn(label: Text('PEMBELI', style: _headerStyle)),
                  DataColumn(label: Text('TOTAL', style: _headerStyle)),
                  DataColumn(label: Text('STATUS', style: _headerStyle)),
                ],
                rows: farmerOrders.isEmpty
                    ? [
                        DataRow(
                          cells: [
                            const DataCell(Text('-')),
                            DataCell(Text(
                              'Belum ada transaksi',
                              style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                            )),
                            const DataCell(Text('-')),
                            const DataCell(Text('-')),
                          ],
                        ),
                      ]
                    : farmerOrders.map((o) {
                        final buyerName = o.buyerName;
                        final totalStr = formatter.format(o.totalPrice);
                        final statusStr = _statusLabel(o.status);
                        final statusColor = o.status.toLowerCase() == 'completed' || o.status.toLowerCase() == 'selesai'
                            ? const Color(0xFF2C6A4F)
                            : const Color(0xFF6E7E75);
                        return _buildOrderRow('#${o.orderNumber}', buyerName, totalStr, statusStr, statusColor);
                      }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationContent() {
    final fieldBgColor = const Color(0xFFF7F4ED);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileLayout = screenWidth < 850;

    final Widget dataPendaftaranCard = _buildCardContainer(
      title: 'Data Pendaftaran',
      subtitle: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobileLayout) ...[
            _buildField('NAMA LENGKAP', _currentUser.name, fieldBgColor),
            const SizedBox(height: 16),
            _buildField('NIK', _currentUser.nik ?? '-', fieldBgColor),
            const SizedBox(height: 16),
            _buildField('NO. HP', _currentUser.phone ?? '-', fieldBgColor),
            const SizedBox(height: 16),
            _buildField('LUAS LAHAN', '0.8 ha', fieldBgColor), // Currently hardcoded because backend doesn't have land area, but better than random dummy data
          ] else ...[
            Row(
              children: [
                Expanded(child: _buildField('NAMA LENGKAP', _currentUser.name, fieldBgColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('NIK', _currentUser.nik ?? '-', fieldBgColor)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildField('NO. HP', _currentUser.phone ?? '-', fieldBgColor)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('LUAS LAHAN', '0.8 ha', fieldBgColor)), // Backend mapping pending
              ],
            ),
          ],
          const SizedBox(height: 16),
          _buildField('ALAMAT LAHAN', _currentUser.address ?? '-', fieldBgColor),
          const SizedBox(height: 16),
          _buildField('KOMODITAS RENCANA', _currentUser.shopName ?? 'Belum ada', fieldBgColor), // Temporary mapping
          const SizedBox(height: 16),
          const Text('DOKUMEN PENDUKUNG', style: _headerStyle),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: fieldBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_file, size: 16, color: _textMuted),
                SizedBox(width: 8),
                Text('Foto Lahan.jpg', style: TextStyle(color: _textMuted, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );

    final Widget tindakanVerifikasiCard = _buildCardContainer(
      title: 'Tindakan Verifikasi',
      subtitle: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF132A1D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                try {
                  await context.read<AdminController>().verifyUser(_currentUser.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pendaftaran berhasil disetujui')),
                    );
                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menyetujui pendaftaran: $e')),
                  );
                }
              },
              child: const Text('Setujui Pendaftaran', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD32F2F),
                side: const BorderSide(color: Color(0xFFF0CDC9)),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              child: const Text('Tolak Pendaftaran', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('CATATAN (OPSIONAL)', style: _headerStyle),
          const SizedBox(height: 8),
          TextField(
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'mis. dokumen kurang jelas, minta unggah ulang',
              hintStyle: const TextStyle(color: _textMuted, fontSize: 13),
              filled: true,
              fillColor: fieldBgColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB88A44),
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {},
              child: const Text('Kirim Catatan ke Petani', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    if (isMobileLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dataPendaftaranCard,
          const SizedBox(height: 24),
          tindakanVerifikasiCard,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: dataPendaftaranCard),
        const SizedBox(width: 24),
        Expanded(flex: 4, child: tindakanVerifikasiCard),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color borderColor) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: _headerStyle),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _textDark, fontFamily: 'Georgia')),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: _textMuted)),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: _textMuted)),
          ],
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildField(String label, String value, [Color? bgColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _headerStyle),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor ?? const Color(0xFFF9F9F9),
            border: bgColor == null ? Border.all(color: const Color(0xFFE0E0E0)) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: const TextStyle(fontSize: 13, color: _textDark)),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isBold ? _textDark : _textMuted, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 13, color: valueColor ?? _textDark, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  DataRow _buildOrderRow(String id, String buyer, String total, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold))),
        DataCell(Text(buyer, style: const TextStyle(fontSize: 13))),
        DataCell(Text(total, style: const TextStyle(fontSize: 13))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Menunggu Bayar';
      case 'paid': return 'Diproses';
      case 'processing': return 'Diproses';
      case 'shipped': return 'Dikirim';
      case 'completed': return 'Selesai';
      case 'cancelled': return 'Batal';
      default: return status;
    }
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w800,
  color: Color(0xFF6E7E75),
  letterSpacing: 1.0,
);
