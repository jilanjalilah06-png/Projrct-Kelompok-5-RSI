import 'package:flutter/material.dart';

class AlamatPengirimanPage extends StatefulWidget {
  const AlamatPengirimanPage({super.key});

  @override
  State<AlamatPengirimanPage> createState() => _AlamatPengirimanPageState();
}

class _AlamatPengirimanPageState extends State<AlamatPengirimanPage> {
  static const Color _green = Color(0xFF159447);
  static const Color _greenDark = Color(0xFF0D7A3A);
  static const Color _greenLight = Color(0xFFE8F5E9);

  final List<Map<String, String>> _addresses = [
    {
      'label': 'Rumah',
      'name': 'Aryo',
      'phone': '0856-7890-1234',
      'address': 'Jl. Merdeka No. 12, Kec. Menteng, Kota Jakarta Pusat, DKI Jakarta 10310',
      'isPrimary': 'true',
    },
    {
      'label': 'Kantor',
      'name': 'Aryo',
      'phone': '0856-7890-1234',
      'address': 'Jl. Sudirman No. 45, Kec. Karet, Kota Jakarta Selatan, DKI Jakarta 12190',
      'isPrimary': 'false',
    },
  ];

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
                    ..._addresses.asMap().entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildAddressCard(entry.value, entry.key),
                          ),
                        ),
                    const SizedBox(height: 8),
                    _buildAddButton(),
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
              'Alamat & Pengiriman',
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

  Widget _buildAddressCard(Map<String, String> addr, int index) {
    final isPrimary = addr['isPrimary'] == 'true';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPrimary
            ? Border.all(color: _green, width: 1.5)
            : null,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPrimary ? _green : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  addr['label'] ?? '',
                  style: TextStyle(
                    color: isPrimary ? Colors.white : const Color(0xFF667085),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isPrimary) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Utama',
                    style: TextStyle(
                      color: _green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditAddressDialog(index);
                  } else if (value == 'delete') {
                    setState(() => _addresses.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alamat berhasil dihapus'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } else if (value == 'primary') {
                    setState(() {
                      for (var a in _addresses) {
                        a['isPrimary'] = 'false';
                      }
                      _addresses[index]['isPrimary'] = 'true';
                    });
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18, color: Color(0xFF667085)),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (!isPrimary)
                    const PopupMenuItem(
                      value: 'primary',
                      child: Row(
                        children: [
                          Icon(Icons.star_outline, size: 18, color: Color(0xFF667085)),
                          SizedBox(width: 8),
                          Text('Jadikan Utama'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert, color: Color(0xFF98A2B3), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            addr['name'] ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            addr['phone'] ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF667085),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            addr['address'] ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF344054),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () => _showAddAddressDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _green.withValues(alpha: 0.3),
            width: 1.5,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: _green, size: 22),
            SizedBox(width: 8),
            Text(
              'Tambah Alamat Baru',
              style: TextStyle(
                color: _green,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    final labelCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tambah Alamat Baru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _dialogField(controller: labelCtrl, label: 'Label (Rumah/Kantor/dll)', icon: Icons.label_outline),
            const SizedBox(height: 12),
            _dialogField(controller: nameCtrl, label: 'Nama Penerima', icon: Icons.person_outline),
            const SizedBox(height: 12),
            _dialogField(controller: phoneCtrl, label: 'Nomor HP', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _dialogField(controller: addressCtrl, label: 'Alamat Lengkap', icon: Icons.location_on_outlined, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _addresses.add({
                      'label': labelCtrl.text.isNotEmpty ? labelCtrl.text : 'Lainnya',
                      'name': nameCtrl.text.isNotEmpty ? nameCtrl.text : 'Penerima',
                      'phone': phoneCtrl.text,
                      'address': addressCtrl.text,
                      'isPrimary': 'false',
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alamat berhasil ditambahkan'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAddressDialog(int index) {
    final addr = _addresses[index];
    final labelCtrl = TextEditingController(text: addr['label']);
    final nameCtrl = TextEditingController(text: addr['name']);
    final phoneCtrl = TextEditingController(text: addr['phone']);
    final addressCtrl = TextEditingController(text: addr['address']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Alamat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _dialogField(controller: labelCtrl, label: 'Label', icon: Icons.label_outline),
            const SizedBox(height: 12),
            _dialogField(controller: nameCtrl, label: 'Nama Penerima', icon: Icons.person_outline),
            const SizedBox(height: 12),
            _dialogField(controller: phoneCtrl, label: 'Nomor HP', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _dialogField(controller: addressCtrl, label: 'Alamat Lengkap', icon: Icons.location_on_outlined, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _addresses[index] = {
                      'label': labelCtrl.text,
                      'name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                      'address': addressCtrl.text,
                      'isPrimary': addr['isPrimary'] ?? 'false',
                    };
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alamat berhasil diperbarui'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _green, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
