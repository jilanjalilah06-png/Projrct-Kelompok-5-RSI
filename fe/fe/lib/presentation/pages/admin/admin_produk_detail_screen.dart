import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/product_model.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/admin_controller.dart';

class AdminProdukDetailScreen extends StatefulWidget {
  final ProductModel product;

  const AdminProdukDetailScreen({super.key, required this.product});

  @override
  State<AdminProdukDetailScreen> createState() => _AdminProdukDetailScreenState();
}

class _AdminProdukDetailScreenState extends State<AdminProdukDetailScreen> {
  static const Color _bg = Color(0xFFF2ECE0);
  static const Color _textDark = Color(0xFF132A1D);
  static const Color _textMuted = Color(0xFF6E7E75);
  static const Color _primary = Color(0xFF2C6A4F);
  
  final TextEditingController _noteController = TextEditingController();
  late bool _isActive;
  late String _status;

  @override
  void initState() {
    super.initState();
    _isActive = widget.product.isActive;
    _status = widget.product.status;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _formatRupiahValue(int value) {
    final number = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < number.length; i++) {
      final position = number.length - i;
      buffer.write(number[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  Widget _buildReadOnlyField(String label, String value, {bool isMultiLine = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: _textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F2EB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5DFD3)),
          ),
          child: Text(
            value,
            maxLines: isMultiLine ? 5 : 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sellerName = widget.product.seller?['name']?.toString() ?? 'Petani';
    final shopName = widget.product.seller?['shop_name']?.toString() ?? '-';
    final categoryName = widget.product.category?['name']?.toString() ?? '-';
    String statusText;
    Color statusColor;
    switch (_status) {
      case 'public':
        statusText = 'Public';
        statusColor = const Color(0xFF2C6A4F);
        break;
      case 'ditolak':
        statusText = 'Ditolak';
        statusColor = const Color(0xFFD32F2F);
        break;
      default:
        statusText = 'Tinjau';
        statusColor = const Color(0xFFB57018);
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
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
                label: const Text(
                  'Kembali ke Daftar Produk',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Two Column Layout for Detail and Actions
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                
                final leftColumn = Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5DFD3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header title & status badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.product.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'Georgia',
                                    fontWeight: FontWeight.bold,
                                    color: _textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Milik $sellerName — $shopName',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: _textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Fields
                      Row(
                        children: [
                          Expanded(child: _buildReadOnlyField('NAMA PRODUK', widget.product.name)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildReadOnlyField('KATEGORI KOMODITAS', categoryName)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildReadOnlyField('STOK TERSEDIA', '${widget.product.stock} ${widget.product.unit}')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildReadOnlyField('HARGA PER KG', 'Rp ${_formatRupiahValue(widget.product.price.round())}')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildReadOnlyField('DESKRIPSI', widget.product.description.isNotEmpty ? widget.product.description : 'Tidak ada deskripsi.', isMultiLine: true),
                      const SizedBox(height: 24),

                      // Info box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7F5EC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC3ECCF)),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info, color: Color(0xFF2C6A4F), size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Data produk diisi dan dikelola sendiri oleh petani. Admin hanya meninjau — bandingkan harga jual dengan Harga Referensi sebelum menyetujui.',
                                style: TextStyle(
                                  color: Color(0xFF2C6A4F),
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );

                final rightColumn = Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5DFD3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tindakan',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Setujui button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF132A1D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _updateProductStatus(context, true, 'public'),
                          child: const Text(
                            'Setujui & Tayangkan',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tolak button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFD32F2F),
                            side: const BorderSide(color: Color(0xFFF0CDC9)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _updateProductStatus(context, false, 'ditolak'),
                          child: const Text(
                            'Tolak Produk',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Note field
                      const Text(
                        'CATATAN UNTUK PETANI (OPSIONAL)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _textMuted,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'mis. sesuaikan harga dengan harga referensi',
                          hintStyle: const TextStyle(color: Colors.black26, fontSize: 13),
                          filled: true,
                          fillColor: const Color(0xFFFBF9F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5DFD3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE5DFD3)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kirim catatan button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB57F3D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _sendNote(context),
                          child: const Text(
                            'Kirim Catatan',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Catatan ini akan masuk ke notifikasi petani terkait.',
                        style: TextStyle(
                          fontSize: 11,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: leftColumn),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: rightColumn),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      leftColumn,
                      const SizedBox(height: 24),
                      rightColumn,
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 32),

            // Riwayat Penjualan Section
            _buildRiwayatPenjualanTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatPenjualanTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Penjualan Produk Ini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textDark,
            fontFamily: 'Georgia',
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sejak produk ditayangkan',
          style: TextStyle(
            fontSize: 13,
            color: _textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5DFD3)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              horizontalMargin: 24,
              columns: const [
              DataColumn(label: Text('ID PESANAN', style: _tableHeaderStyle)),
              DataColumn(label: Text('PEMBELI', style: _tableHeaderStyle)),
              DataColumn(label: Text('JUMLAH', style: _tableHeaderStyle)),
              DataColumn(label: Text('TOTAL', style: _tableHeaderStyle)),
              DataColumn(label: Text('TANGGAL', style: _tableHeaderStyle)),
            ],
            rows: [
              DataRow(
                cells: [
                  const DataCell(Text('#1075', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                  const DataCell(Text('Keysha', style: TextStyle(color: _textDark))),
                  DataCell(Text('2 ${widget.product.unit}', style: const TextStyle(color: _textDark))),
                  DataCell(Text('Rp ${_formatRupiahValue((widget.product.price * 2).round())}', style: const TextStyle(color: _textDark))),
                  const DataCell(Text('29 Jun 2026', style: TextStyle(color: _textDark))),
                ],
              ),
            ],
          )),
        ),
      ],
    );
  }

  Future<void> _updateProductStatus(BuildContext context, bool status, String statusValue) async {
    final controller = context.read<ProductController>();
    final success = await controller.toggleProductStatus(widget.product.id, status, status: statusValue);
    
    if (mounted) {
      if (success) {
        setState(() {
          _isActive = status;
          _status = statusValue;
        });
        
        // Reload admin categories/products to refresh tables
        context.read<AdminController>().loadCategories();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status ? 'Produk berhasil ditayangkan!' : 'Produk berhasil ditolak.'),
            backgroundColor: status ? const Color(0xFF2C6A4F) : const Color(0xFFD32F2F),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.lastError ?? 'Gagal memperbarui status produk.'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  Future<void> _sendNote(BuildContext context) async {
    final noteText = _noteController.text.trim();
    if (noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan catatan terlebih dahulu.'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    final controller = context.read<ProductController>();
    final success = await controller.sendProductReviewNote(widget.product.id, noteText);

    if (mounted) {
      if (success) {
        _noteController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Catatan berhasil dikirim ke petani terkait.'),
            backgroundColor: Color(0xFF2C6A4F),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.lastError ?? 'Gagal mengirim catatan.'),
            backgroundColor: const Color(0xFFD32F2F),
          ),
        );
      }
    }
  }
}

const TextStyle _tableHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF6E7E75),
  letterSpacing: 0.5,
);
