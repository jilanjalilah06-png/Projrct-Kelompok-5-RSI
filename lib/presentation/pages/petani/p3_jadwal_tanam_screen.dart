import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';
import 'p3a_biaya_produksi_screen.dart';

class P3JadwalTanamScreen extends StatefulWidget {
  const P3JadwalTanamScreen({super.key});

  @override
  State<P3JadwalTanamScreen> createState() => _P3JadwalTanamScreenState();
}

class _P3JadwalTanamScreenState extends State<P3JadwalTanamScreen> {
  final List<Map<String, dynamic>> _jadwal = [
    {
      'varietas': 'Beras Pandan Wangi',
      'lahan': 'Sawah A',
      'tanggalMulai': DateTime(2026, 3, 15),
      'estimasiPanen': DateTime(2026, 6, 15),
      'status': 'Vegetatif',
      'statusColor': AgriColors.primaryLight,
      'notif': 'Notifikasi H-7 aktif',
      'icon': Icons.grass,
      'color': AgriColors.primary,
    },
    {
      'varietas': 'Jagung Manis',
      'lahan': 'Ladang B',
      'tanggalMulai': DateTime(2026, 4, 8),
      'estimasiPanen': DateTime(2026, 6, 22),
      'status': 'Aktif',
      'statusColor': AgriColors.primaryLight,
      'notif': null,
      'icon': Icons.eco,
      'color': Color(0xFFE9A824),
    },
    {
      'varietas': 'Beras Merah',
      'lahan': 'Sawah C',
      'tanggalMulai': DateTime(2026, 3, 1),
      'estimasiPanen': DateTime(2026, 6, 1),
      'status': 'Selesai',
      'statusColor': AgriColors.textLight,
      'notif': null,
      'icon': Icons.grass,
      'color': Color(0xFF52B788),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        title: const Text(
          'Jadwal Tanam',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _jadwal.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final item = _jadwal[i];
          return _JadwalCard(
            item: item,
            onEditTap: () => _showJadwalForm(context, index: i),
            onBiayaTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => P3aBiayaProduksiScreen(
                  jadwalName: '${item['varietas']} - ${item['lahan']}',
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showJadwalForm(context),
        backgroundColor: AgriColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Jadwal',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showJadwalForm(BuildContext context, {int? index}) {
    final initial = index == null ? null : _jadwal[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _JadwalFormPage(
          initial: initial,
          onSave: (data) {
            setState(() {
              if (index == null) {
                _jadwal.add(data);
              } else {
                _jadwal[index] = data;
              }
            });
          },
        ),
      ),
    );
  }
}

class _JadwalFormPage extends StatelessWidget {
  final Map<String, dynamic>? initial;
  final ValueChanged<Map<String, dynamic>> onSave;

  const _JadwalFormPage({this.initial, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final isEdit = initial != null;
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: AgriColors.primary,
        foregroundColor: Colors.white,
        title: Text(isEdit ? 'Edit Jadwal Tanam' : 'Tambah Jadwal Tanam'),
        elevation: 0,
      ),
      body: _JadwalFormSheet(initial: initial, onSave: onSave),
    );
  }
}

class _JadwalCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onBiayaTap;
  final VoidCallback onEditTap;

  const _JadwalCard({
    required this.item,
    required this.onBiayaTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = item['statusColor'] as Color;
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
                  color: (item['color'] as Color).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['varietas']} - ${item['lahan']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AgriColors.textDark,
                      ),
                    ),
                    Text(
                      'Mulai tanam: ${_formatDate(item['tanggalMulai'] as DateTime)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AgriColors.textLight,
                      ),
                    ),
                    Text(
                      'Estimasi panen: ${_formatDate(item['estimasiPanen'] as DateTime)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AgriColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['status'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor == const Color(0xFFE9C46A)
                        ? const Color(0xFF9A6E00)
                        : statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (item['notif'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    color: Color(0xFF856404),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item['notif'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF856404),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              _ActionBtn(
                label: 'Biaya Produksi',
                icon: Icons.receipt_long,
                color: AgriColors.primary,
                onTap: onBiayaTap,
              ),
              const SizedBox(width: 8),
              _ActionBtn(
                label: 'Edit',
                icon: Icons.edit_outlined,
                color: AgriColors.textLight,
                onTap: onEditTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
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

class _JadwalFormSheet extends StatefulWidget {
  final Map<String, dynamic>? initial;
  final ValueChanged<Map<String, dynamic>> onSave;

  const _JadwalFormSheet({this.initial, required this.onSave});

  @override
  State<_JadwalFormSheet> createState() => _JadwalFormSheetState();
}

class _JadwalFormSheetState extends State<_JadwalFormSheet> {
  late final TextEditingController _varietasCtrl;
  late final TextEditingController _lahanCtrl;
  late DateTime _tanggalMulai;
  late DateTime _estimasiPanen;
  late String _status;

  final List<String> _statusOptions = const [
    'Persiapan Lahan',
    'Semai',
    'Vegetatif',
    'Generatif',
    'Aktif',
    'Siap Panen',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    _varietasCtrl = TextEditingController(
      text: widget.initial?['varietas'] as String? ?? '',
    );
    _lahanCtrl = TextEditingController(
      text: widget.initial?['lahan'] as String? ?? '',
    );
    _tanggalMulai =
        widget.initial?['tanggalMulai'] as DateTime? ?? DateTime.now();
    _estimasiPanen =
        widget.initial?['estimasiPanen'] as DateTime? ??
        _tanggalMulai.add(const Duration(days: 90));
    _status = widget.initial?['status'] as String? ?? _statusOptions.first;
  }

  @override
  void dispose() {
    _varietasCtrl.dispose();
    _lahanCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: 'Pilih tanggal',
    );

    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'Edit Jadwal Tanam' : 'Tambah Jadwal Tanam',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _varietasCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Varietas Benih',
                prefixIcon: Icon(Icons.spa_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lahanCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Lahan',
                prefixIcon: Icon(Icons.landscape_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Tanggal Mulai Tanam',
              value: _formatDate(_tanggalMulai),
              onTap: () => _pickDate(
                initialDate: _tanggalMulai,
                onPicked: (date) {
                  _tanggalMulai = date;
                  if (_estimasiPanen.isBefore(date)) {
                    _estimasiPanen = date.add(const Duration(days: 90));
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            _DateField(
              label: 'Estimasi Tanggal Panen',
              value: _formatDate(_estimasiPanen),
              onTap: () => _pickDate(
                initialDate: _estimasiPanen,
                onPicked: (date) => _estimasiPanen = date,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status Perkembangan Lahan',
                prefixIcon: Icon(Icons.timeline_outlined),
                border: OutlineInputBorder(),
              ),
              items: _statusOptions
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSave({
                    'varietas': _varietasCtrl.text.trim().isEmpty
                        ? 'Varietas baru'
                        : _varietasCtrl.text.trim(),
                    'lahan': _lahanCtrl.text.trim().isEmpty
                        ? 'Lahan baru'
                        : _lahanCtrl.text.trim(),
                    'tanggalMulai': _tanggalMulai,
                    'estimasiPanen': _estimasiPanen,
                    'status': _status,
                    'statusColor': _status == 'Selesai'
                        ? AgriColors.textLight
                        : AgriColors.primaryLight,
                    'notif': widget.initial?['notif'],
                    'icon': Icons.grass,
                    'color': AgriColors.primary,
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
                  'Simpan Jadwal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.calendar_month_outlined),
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
        child: Text(value),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
