import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/reference_price_model.dart';

class AdminHargaReferensiScreen extends StatefulWidget {
  const AdminHargaReferensiScreen({super.key});

  @override
  State<AdminHargaReferensiScreen> createState() => _AdminHargaReferensiScreenState();
}

class _AdminHargaReferensiScreenState extends State<AdminHargaReferensiScreen> {
  final _minPriceCtrl = TextEditingController(text: '18000');
  final _maxPriceCtrl = TextEditingController(text: '20000');
  final _noteCtrl = TextEditingController(text: 'hasil pantauan pasar induk');
  String _selectedKomoditas = 'Beras Premium';

  static const Color _bg = Color(0xFFF2ECE0);
  static const Color _textDark = Color(0xFF132A1D);
  static const Color _textMuted = Color(0xFF6E7E75);

  final List<String> _komoditasList = [
    'Beras Premium',
    'Beras Standar',
    'Jagung Premium',
    'Jagung Standar'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadReferencePrices().then((_) {
        _prefillSelectedPrices();
      });
      context.read<AdminController>().loadActivityLogs();
    });
  }

  void _prefillSelectedPrices() {
    final admin = context.read<AdminController>();
    final match = admin.referencePrices.firstWhere(
      (p) => p.name == _selectedKomoditas,
      orElse: () => ReferencePriceModel(id: 0, name: _selectedKomoditas, minPrice: 0, maxPrice: 0),
    );
    if (match.id != 0) {
      setState(() {
        _minPriceCtrl.text = match.minPrice.toString();
        _maxPriceCtrl.text = match.maxPrice.toString();
        _noteCtrl.text = match.note ?? '';
      });
    } else {
      setState(() {
        if (_selectedKomoditas == 'Beras Premium') {
          _minPriceCtrl.text = '18000';
          _maxPriceCtrl.text = '20000';
        } else if (_selectedKomoditas == 'Beras Standar') {
          _minPriceCtrl.text = '14500';
          _maxPriceCtrl.text = '16000';
        } else if (_selectedKomoditas == 'Jagung Premium') {
          _minPriceCtrl.text = '10000';
          _maxPriceCtrl.text = '12000';
        } else {
          _minPriceCtrl.text = '8000';
          _maxPriceCtrl.text = '9500';
        }
      });
    }
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  String _formatPrice(int value) {
    final number = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < number.length; i++) {
      final position = number.length - i;
      buffer.write(number[i]);
      if (position > 1 && position % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam lalu';
    } else {
      return 'Hari ini';
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminCtrl = context.watch<AdminController>();

    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MARKETPLACE',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Harga Referensi',
                  style: TextStyle(
                    fontSize: 28,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top Area: Split layout (Table on Left, Form on Right)
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 950;
                final widgets = [
                  // Left Side: Harga Referensi Komoditas Table
                  Expanded(
                    flex: isNarrow ? 1 : 7,
                    child: Container(
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
                          const Text(
                            'Harga Referensi Komoditas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Acuan harga yang tampil di aplikasi petani',
                            style: TextStyle(fontSize: 13, color: _textMuted),
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, tblConstraints) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(minWidth: tblConstraints.maxWidth),
                                  child: DataTable(
                                    horizontalMargin: 8,
                                    columnSpacing: 24,
                                    headingRowColor: WidgetStateProperty.all(const Color(0xFFFBFBFB)),
                                    columns: const [
                                      DataColumn(label: Text('KOMODITAS', style: _headerStyle)),
                                      DataColumn(label: Text('HARGA TERENDAH', style: _headerStyle)),
                                      DataColumn(label: Text('HARGA TERTINGGI', style: _headerStyle)),
                                      DataColumn(label: Text('DIPERBARUI', style: _headerStyle)),
                                    ],
                                    rows: (adminCtrl.referencePrices.isEmpty && adminCtrl.searchQuery.isEmpty)
                                        ? [
                                            _buildHargaRow('Beras Premium', 'Rp 18.000', 'Rp 20.000', 'Hari ini', tblConstraints, isBlueText: true),
                                            _buildHargaRow('Beras Standar', 'Rp 14.500', 'Rp 16.000', 'Hari ini', tblConstraints, isBlueText: true),
                                            _buildHargaRow('Jagung Premium', 'Rp 10.000', 'Rp 12.000', 'Hari ini', tblConstraints, isBlueText: true),
                                            _buildHargaRow('Jagung Standar', 'Rp 8.000', 'Rp 9.500', 'Hari ini', tblConstraints, isBlueText: false),
                                          ]
                                        : adminCtrl.referencePrices.map((p) {
                                            return _buildHargaRow(
                                              p.name,
                                              'Rp ${_formatPrice(p.minPrice)}',
                                              'Rp ${_formatPrice(p.maxPrice)}',
                                              p.updatedAt != null ? _formatTimeAgo(p.updatedAt!) : 'Hari ini',
                                              tblConstraints,
                                              isBlueText: true,
                                            );
                                          }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: isNarrow ? 0 : 20, height: isNarrow ? 20 : 0),
                  // Right Side: Perbarui Harga Form
                  Expanded(
                    flex: isNarrow ? 1 : 5,
                    child: Container(
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
                          const Text(
                            'Perbarui Harga',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // KOMODITAS dropdown
                          const Text('KOMODITAS', style: _formLabelStyle),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFD0D5DD)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedKomoditas,
                                isExpanded: true,
                                style: const TextStyle(color: _textDark, fontSize: 14),
                                items: _komoditasList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() {
                                      _selectedKomoditas = v;
                                    });
                                    _prefillSelectedPrices();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // HARGA TERENDAH / TERTINGGI Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('HARGA TERENDAH', style: _formLabelStyle),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _minPriceCtrl,
                                      style: const TextStyle(fontSize: 14),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixText: 'Rp ',
                                        prefixStyle: const TextStyle(color: _textDark),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('HARGA TERTINGGI', style: _formLabelStyle),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _maxPriceCtrl,
                                      style: const TextStyle(fontSize: 14),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        prefixText: 'Rp ',
                                        prefixStyle: const TextStyle(color: _textDark),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // CATATAN (OPSIONAL)
                          const Text('CATATAN (OPSIONAL)', style: _formLabelStyle),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _noteCtrl,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'mis. hasil pantauan pasar induk',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF132A1D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () async {
                                final minVal = int.tryParse(_minPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
                                final maxVal = int.tryParse(_maxPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''));
                                if (minVal == null || maxVal == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Harga tidak valid')),
                                  );
                                  return;
                                }

                                try {
                                  await adminCtrl.updateReferencePrice(
                                    name: _selectedKomoditas,
                                    minPrice: minVal,
                                    maxPrice: maxVal,
                                    note: _noteCtrl.text,
                                  );
                                  
                                  // Refresh logs
                                  await adminCtrl.loadActivityLogs();

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Perubahan harga berhasil disimpan')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
                                    );
                                  }
                                }
                              },
                              child: adminCtrl.loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ];

                return isNarrow
                    ? Column(children: widgets.map((w) => w is Expanded ? w.child : w).toList())
                    : Row(crossAxisAlignment: CrossAxisAlignment.start, children: widgets);
              },
            ),
            const SizedBox(height: 24),

            // Bottom Area: Riwayat Perubahan Harga Table
            Container(
              width: double.infinity,
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
                  const Text(
                    'Riwayat Perubahan Harga',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Catatan semua pembaruan harga referensi',
                    style: TextStyle(fontSize: 13, color: _textMuted),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final komoditasLogs = adminCtrl.activityLogs.where((log) => (log['category'] as String? ?? '').toLowerCase() == 'komoditas').toList();
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            horizontalMargin: 8,
                            columnSpacing: 24,
                            headingRowColor: WidgetStateProperty.all(const Color(0xFFFBFBFB)),
                            columns: const [
                              DataColumn(label: Text('TANGGAL', style: _headerStyle)),
                              DataColumn(label: Text('KOMODITAS', style: _headerStyle)),
                              DataColumn(label: Text('KEJADIAN', style: _headerStyle)),
                              DataColumn(label: Text('DIUBAH OLEH', style: _headerStyle)),
                            ],
                            rows: komoditasLogs.isEmpty
                                ? [
                                    DataRow(
                                      cells: [
                                        const DataCell(Text('-')),
                                        DataCell(Text(
                                          'Belum ada riwayat perubahan',
                                          style: TextStyle(color: Colors.grey.shade500, fontStyle: FontStyle.italic),
                                        )),
                                        const DataCell(Text('-')),
                                        const DataCell(Text('-')),
                                      ],
                                    ),
                                  ]
                                : komoditasLogs.map((log) {
                                    final createdAt = log['created_at'] as String? ?? '';
                                    String waktu = '';
                                    try {
                                      final dt = DateTime.parse(createdAt).toLocal();
                                      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
                                      waktu = '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                                    } catch (_) {
                                      waktu = createdAt;
                                    }

                                    // Extract commodity name from log event
                                    final event = log['event'] as String? ?? '';
                                    String commodity = 'Komoditas';
                                    for (final name in ['Beras Premium', 'Beras Standar', 'Jagung Premium', 'Jagung Standar']) {
                                      if (event.contains(name)) {
                                        commodity = name;
                                        break;
                                      }
                                    }

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(waktu, style: const TextStyle(fontSize: 13, color: _textDark))),
                                        DataCell(
                                          Text(commodity, style: const TextStyle(fontWeight: FontWeight.bold, color: _textDark, fontSize: 13)),
                                        ),
                                        DataCell(Text(event, style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.bold))),
                                        DataCell(Text(log['user_name'] as String? ?? 'Admin', style: const TextStyle(fontSize: 13, color: Colors.blueAccent))),
                                      ],
                                    );
                                  }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildHargaRow(String name, String min, String max, String date, BoxConstraints constraints, {required bool isBlueText}) {
    return DataRow(
      cells: [
        DataCell(
          Container(
            width: constraints.maxWidth > 600 ? constraints.maxWidth - 450 : null,
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: _textDark, fontSize: 13)),
          ),
        ),
        DataCell(Text(min, style: const TextStyle(fontSize: 13, color: _textDark))),
        DataCell(Text(max, style: const TextStyle(fontSize: 13, color: _textDark))),
        DataCell(
          Text(
            date,
            style: TextStyle(
              fontSize: 13,
              color: isBlueText ? Colors.blueAccent : _textMuted,
              fontWeight: isBlueText ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  DataRow _buildRiwayatRowStatic(String date, String name, String event, String author, BoxConstraints constraints) {
    return DataRow(
      cells: [
        DataCell(Text(date, style: const TextStyle(fontSize: 13, color: _textDark))),
        DataCell(
          Container(
            width: constraints.maxWidth > 800 ? constraints.maxWidth - 750 : null,
            child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: _textDark, fontSize: 13)),
          ),
        ),
        DataCell(Text(event, style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.bold))),
        DataCell(Text(author, style: const TextStyle(fontSize: 13, color: Colors.blueAccent))),
      ],
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF6E7E75),
  letterSpacing: 0.5,
);

const TextStyle _formLabelStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w800,
  color: Color(0xFF6E7E75),
  letterSpacing: 1.0,
);
