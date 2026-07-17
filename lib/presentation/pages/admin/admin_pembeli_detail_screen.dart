import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/api_service.dart';
import '../../controllers/admin_controller.dart';
import '../../../core/constanst/api_constants.dart';

class AdminPembeliDetailScreen extends StatefulWidget {
  final UserModel user;

  const AdminPembeliDetailScreen({super.key, required this.user});

  @override
  State<AdminPembeliDetailScreen> createState() => _AdminPembeliDetailScreenState();
}

class _AdminPembeliDetailScreenState extends State<AdminPembeliDetailScreen> {
  static const Color _textDark = Color(0xFF132A1D);
  static const Color _textMuted = Color(0xFF6B7280);
  static const TextStyle _headerStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: _textMuted,
    letterSpacing: 1.2,
  );

  late UserModel _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadOrders();
    });
  }

  Future<void> _toggleStatus() async {
    setState(() => _isLoading = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.postRequest('/admin/users/${_user.id}/toggle', {});
      
      if (response.statusCode == 200) {
        final resData = jsonDecode(response.body);
        if (resData['success'] == true) {
          setState(() {
            _user = _user.copyWith(isActive: !_user.isActive);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_user.isActive ? 'Akun diaktifkan' : 'Akun dinonaktifkan')),
            );
          }
        }
      } else {
        throw Exception('Gagal mengubah status');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2ECE0), // Sand/cream background
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PENGGUNA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Detail Pembeli',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Georgia',
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Back Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _textDark,
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Kembali ke Daftar Pembeli', style: TextStyle(fontSize: 13)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 24),

            // Profile Header Card
            _buildProfileCard(),
            const SizedBox(height: 24),

            // Stat Cards
            LayoutBuilder(
              builder: (context, cardConstraints) {
                final admin = context.watch<AdminController>();
                final buyerOrders = admin.orders.where((o) => o.buyerId == _user.id).toList();
                final totalOrdersCount = buyerOrders.length;
                
                double totalSpent = 0;
                int completedCount = 0;
                for (final o in buyerOrders) {
                  final status = o.status.toLowerCase();
                  if (status == 'completed' || status == 'selesai' || status == 'paid') {
                    totalSpent += o.totalPrice;
                    completedCount++;
                  }
                }
                
                final averageSpent = totalOrdersCount == 0 ? 0.0 : totalSpent / totalOrdersCount;
                final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                
                final totalSpentStr = formatter.format(totalSpent);
                final averageSpentStr = formatter.format(averageSpent);

                final bool isMobileCard = cardConstraints.maxWidth < 600;
                final double cardWidth = isMobileCard ? cardConstraints.maxWidth : (cardConstraints.maxWidth - 32) / 3;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(width: cardWidth, child: _buildStatCard('TOTAL PESANAN', '$totalOrdersCount', 'Selesai: $completedCount')),
                    SizedBox(width: cardWidth, child: _buildStatCard('TOTAL BELANJA', totalSpentStr, 'Sepanjang bergabung')),
                    SizedBox(width: cardWidth, child: _buildStatCard('RATA-RATA / PESANAN', averageSpentStr, '$totalOrdersCount transaksi')),
                  ],
                );
              }
            ),
            const SizedBox(height: 24),

            // Riwayat Pesanan Table
            _buildRiwayatPesanan(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final initials = _user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
    final address = _user.address ?? '-';
    final phone = _user.phone ?? '-';
    final joinDate = _user.createdAt != null ? DateFormat('dd MMM yyyy').format(_user.createdAt!) : '-';
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    Widget avatar = CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFFE5DFD3), // Tan color from screenshot
      backgroundImage: _user.avatar != null && _user.avatar!.isNotEmpty
          ? NetworkImage('${ApiConstants.storageUrl}/${_user.avatar}')
          : null,
      child: _user.avatar != null && _user.avatar!.isNotEmpty
          ? null
          : Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF5D4037),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
    );

    Widget infoColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _user.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark, fontFamily: 'Georgia'),
        ),
        const SizedBox(height: 4),
        Text(
          '$address · $phone · Bergabung $joinDate',
          style: const TextStyle(color: _textMuted, fontSize: 13),
        ),
      ],
    );

    Widget statusChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _user.isActive
            ? const Color(0xFF2C6A4F).withValues(alpha: 0.1)
            : const Color(0xFFD32F2F).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _user.isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          color: _user.isActive ? const Color(0xFF2C6A4F) : const Color(0xFFD32F2F),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    Widget actionButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: _user.isActive ? const Color(0xFFD32F2F) : const Color(0xFF2C6A4F),
        side: BorderSide(color: _user.isActive ? const Color(0xFFF0CDC9) : const Color(0xFFA5D6A7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: _isLoading ? null : _toggleStatus,
      child: _isLoading 
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
          : Text(_user.isActive ? 'Nonaktifkan Akun' : 'Aktifkan Akun'),
    );

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
                actionButton,
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
          actionButton,
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11), // Slightly smaller to fit inside outer border
        child: Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide(color: Color(0xFF2C6A4F), width: 4)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _headerStyle),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _textDark,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: _textMuted, fontSize: 13),
          ),
        ],
      ),
      ),
      ),
    );
  }

  Widget _buildRiwayatPesanan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Riwayat Pesanan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark, fontFamily: 'Georgia')),
          const SizedBox(height: 4),
          const Text('Semua transaksi pembeli ini', style: TextStyle(color: _textMuted, fontSize: 13)),
          const SizedBox(height: 24),
          
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    horizontalMargin: 0,
                    columnSpacing: 24,
                    columns: const [
                      DataColumn(label: Text('ID PESANAN', style: _headerStyle)),
                      DataColumn(label: Text('PETANI', style: _headerStyle)),
                      DataColumn(label: Text('TOTAL', style: _headerStyle)),
                      DataColumn(label: Text('TANGGAL', style: _headerStyle)),
                      DataColumn(label: Text('STATUS', style: _headerStyle)),
                    ],
                    rows: () {
                      final admin = context.read<AdminController>();
                      final buyerOrders = admin.orders.where((o) => o.buyerId == _user.id).toList();
                      final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

                      if (buyerOrders.isEmpty) {
                        return [
                          DataRow(
                            cells: [
                              const DataCell(Text('-')),
                              DataCell(Text(
                                'Belum ada pesanan',
                                style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                              )),
                              const DataCell(Text('-')),
                              const DataCell(Text('-')),
                              const DataCell(Text('-')),
                            ],
                          ),
                        ];
                      }

                      return buyerOrders.map((o) {
                        final itemsList = o.items ?? [];
                        final sellerName = itemsList.isNotEmpty 
                            ? (itemsList.first.product?['seller']?['name']?.toString() ?? 'Petani') 
                            : 'Petani';
                        final dateStr = o.createdAt != null ? DateFormat('dd MMM yyyy').format(o.createdAt!) : '-';
                        
                        return _buildPesananRow(
                          '#${o.orderNumber}',
                          sellerName,
                          formatter.format(o.totalPrice),
                          dateStr,
                          o.status,
                        );
                      }).toList();
                    }(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  DataRow _buildPesananRow(String id, String petani, String total, String tanggal, String status) {
    Color statusColor;
    Color statusBgColor;

    final normStatus = status.toLowerCase();
    String displayStatus = status;

    if (normStatus == 'selesai' || normStatus == 'completed' || normStatus == 'delivered') {
      statusColor = const Color(0xFF2C6A4F);
      statusBgColor = const Color(0xFF2C6A4F).withValues(alpha: 0.1);
      displayStatus = 'Selesai';
    } else if (normStatus == 'diproses' || normStatus == 'processing' || normStatus == 'paid' || normStatus == 'pending') {
      statusColor = const Color(0xFF6B7280);
      statusBgColor = const Color(0xFFE5E7EB);
      displayStatus = normStatus == 'pending' ? 'Menunggu Bayar' : 'Diproses';
    } else {
      statusColor = const Color(0xFFD32F2F);
      statusBgColor = const Color(0xFFFDE7E7);
      displayStatus = 'Batal';
    }

    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w500))),
        DataCell(Text(petani, style: const TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.w500))),
        DataCell(Text(total, style: const TextStyle(fontSize: 13, color: _textDark))),
        DataCell(Text(tanggal, style: const TextStyle(fontSize: 13, color: _textDark))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              displayStatus,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
