import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

// ─────────────────────────────────────────────
//  P4 – Stok Jual
// ─────────────────────────────────────────────
class P4StokJualScreen extends StatefulWidget {
  const P4StokJualScreen({super.key});
  @override
  State<P4StokJualScreen> createState() => _P4StokJualScreenState();
}

class _P4StokJualScreenState extends State<P4StokJualScreen> {
  final List<Map<String, dynamic>> _stok = [
    {
      'kategori': 'Padi',
      'subJenis': 'Beras Pandan Wangi',
      'nama': 'Beras Pandan Wangi',
      'stok': 80,
      'harga': 5500,
      'satuan': 'kg',
      'tanggal': '15 Mar',
      'status': 'Publik',
    },
    {
      'kategori': 'Jagung',
      'subJenis': 'Jagung Manis',
      'nama': 'Jagung Manis',
      'stok': 50,
      'harga': 4000,
      'satuan': 'kg',
      'tanggal': '10 Apr',
      'status': 'Draft',
    },
    {
      'kategori': 'Padi',
      'subJenis': 'Beras Merah',
      'nama': 'Beras Merah',
      'stok': 20,
      'harga': 12500,
      'satuan': 'kg',
      'tanggal': '1 Mei',
      'status': 'Publik',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        title: const Text(
          'Stok Jual',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _stok.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _StokCard(
          item: _stok[i],
          onEdit: () => _showEditSheet(context, i),
          onHapus: () => setState(() => _stok.removeAt(i)),
          onToggleStatus: () => setState(() {
            _stok[i]['status'] = _stok[i]['status'] == 'Publik'
                ? 'Draft'
                : 'Publik';
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTambahSheet(context),
        backgroundColor: AgriColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          '+ Tambah Stok',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showEditSheet(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _StokFormPage(
          initial: _stok[index],
          onSave: (data) => setState(() => _stok[index] = data),
        ),
      ),
    );
  }

  void _showTambahSheet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _StokFormPage(onSave: (data) => setState(() => _stok.add(data))),
      ),
    );
  }
}

class _StokFormPage extends StatelessWidget {
  final Map<String, dynamic>? initial;
  final void Function(Map<String, dynamic>) onSave;

  const _StokFormPage({this.initial, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final isEdit = initial != null;
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        foregroundColor: Colors.white,
        title: Text(isEdit ? 'Edit Hasil Tani' : 'Tambah Hasil Tani'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: _StokFormSheet(initial: initial, onSave: onSave),
      ),
    );
  }
}

// ── Stok Card ────────────────────────────────
class _StokCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onHapus;
  final VoidCallback onToggleStatus;
  const _StokCard({
    required this.item,
    required this.onEdit,
    required this.onHapus,
    required this.onToggleStatus,
  });

  bool get _isPublik => item['status'] == 'Publik';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AgriColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: AgriColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AgriColors.textDark,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Stok: ${item['stok']} ${item['satuan']} · Rp ${_formatRupiah(item['harga'] as int)}/${item['satuan']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AgriColors.textLight,
                      ),
                    ),
                    Text(
                      'dari panen ${item['tanggal']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AgriColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isPublik
                      ? AgriColors.primaryLight.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['status'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _isPublik
                        ? AgriColors.primary
                        : AgriColors.textLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionChip(
                label: 'Edit',
                icon: Icons.edit_outlined,
                color: AgriColors.primary,
                onTap: onEdit,
              ),
              const SizedBox(width: 8),
              _ActionChip(
                label: 'Hapus',
                icon: Icons.delete_outline,
                color: AgriColors.danger,
                onTap: onHapus,
              ),
              const Spacer(),
              _ActionChip(
                label: _isPublik ? 'Tarik' : 'Publikasi',
                icon: _isPublik ? Icons.visibility_off_outlined : Icons.public,
                color: _isPublik
                    ? AgriColors.textLight
                    : AgriColors.primaryLight,
                onTap: onToggleStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRupiah(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form Sheet Tambah / Edit Stok ─────────────
class _StokFormSheet extends StatefulWidget {
  final Map<String, dynamic>? initial;
  final void Function(Map<String, dynamic>) onSave;
  const _StokFormSheet({this.initial, required this.onSave});
  @override
  State<_StokFormSheet> createState() => _StokFormSheetState();
}

class _StokFormSheetState extends State<_StokFormSheet> {
  late TextEditingController _stokCtrl;
  late TextEditingController _hargaCtrl;
  String _status = 'Draft';
  String _kategori = 'Padi';
  String _subJenis = 'Beras Pandan Wangi';

  static const Map<String, List<String>> productOptions = {
    'Padi': [
      'Beras Pandan Wangi',
      'Beras Cianjur',
      'Beras Merah',
      'Beras Setra Ramos',
    ],
    'Jagung': ['Jagung Manis', 'Jagung Pipil', 'Jagung Ketan'],
  };

  @override
  void initState() {
    super.initState();
    _kategori = widget.initial?['kategori'] as String? ?? 'Padi';
    _subJenis =
        widget.initial?['subJenis'] as String? ??
        productOptions[_kategori]!.first;
    _stokCtrl = TextEditingController(
      text: widget.initial?['stok']?.toString() ?? '',
    );
    _hargaCtrl = TextEditingController(
      text: widget.initial?['harga']?.toString() ?? '',
    );
    _status = widget.initial?['status'] as String? ?? 'Draft';
  }

  @override
  void dispose() {
    _stokCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isEdit ? 'Edit Stok' : 'Tambah Stok Baru',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AgriColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _kategori,
            decoration: InputDecoration(
              labelText: 'Kategori',
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
            items: productOptions.keys
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _kategori = value;
                _subJenis = productOptions[value]!.first;
              });
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _subJenis,
            decoration: InputDecoration(
              labelText: 'Sub-jenis Produk',
              prefixIcon: const Icon(Icons.grain),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              isDense: true,
            ),
            items: productOptions[_kategori]!
                .map(
                  (subType) =>
                      DropdownMenuItem(value: subType, child: Text(subType)),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _subJenis = value);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Stok (kg)',
                  _stokCtrl,
                  type: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  'Harga (Rp/kg)',
                  _hargaCtrl,
                  type: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Status:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              _StatusToggle(
                value: _status,
                onChanged: (v) => setState(() => _status = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onSave({
                  'kategori': _kategori,
                  'subJenis': _subJenis,
                  'nama': _subJenis,
                  'stok': int.tryParse(_stokCtrl.text) ?? 0,
                  'harga': int.tryParse(_hargaCtrl.text) ?? 0,
                  'satuan': 'kg',
                  'tanggal': 'Baru',
                  'status': _status,
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AgriColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        isDense: true,
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  const _StatusToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['Draft', 'Publik'].map((s) {
        final sel = value == s;
        return GestureDetector(
          onTap: () => onChanged(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: sel ? AgriColors.primary : Colors.white,
              border: Border.all(
                color: sel
                    ? AgriColors.primary
                    : AgriColors.textLight.withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: sel ? Colors.white : AgriColors.textLight,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
