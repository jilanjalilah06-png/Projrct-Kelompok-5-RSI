import 'package:flutter/material.dart';
import '../../../core/constanst/agri_colors.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});
  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _filterRole = 'Semua Role';
  final _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _users = [
    {
      'nama': 'Budi Santoso',
      'email': 'budi@mail.com',
      'role': 'Petani',
      'lokasi': 'Bandung',
      'aktif': true,
    },
    {
      'nama': 'Siti Aminah',
      'email': 'siti@mail.com',
      'role': 'Pembeli',
      'lokasi': 'Jakarta',
      'aktif': true,
    },
    {
      'nama': 'Joko Widodo',
      'email': 'joko@mail.com',
      'role': 'Petani',
      'lokasi': 'Bogor',
      'aktif': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _users.where((u) {
      final matchRole = _filterRole == 'Semua Role' || u['role'] == _filterRole;
      final matchSearch =
          _searchCtrl.text.isEmpty ||
          (u['nama'] as String).toLowerCase().contains(
            _searchCtrl.text.toLowerCase(),
          );
      return matchRole && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AgriColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            // Search + Filter bar
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari...',
                        hintStyle: const TextStyle(fontSize: 13),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AgriColors.textLight,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFDDDDDD),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterRole,
                      items: ['Semua Role', 'Petani', 'Pembeli']
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _filterRole = v!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Table
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 2, child: _TableHeader('Nama')),
                        Expanded(flex: 2, child: _TableHeader('Email')),
                        Expanded(child: _TableHeader('Role')),
                        Expanded(child: _TableHeader('Lokasi')),
                        Expanded(child: _TableHeader('Status')),
                        Expanded(child: _TableHeader('Aksi')),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Rows
                  ...filtered.asMap().entries.map((e) {
                    final u = e.value;
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  u['nama'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  u['email'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AgriColors.textLight,
                                  ),
                                ),
                              ),
                              Expanded(child: _RoleBadge(u['role'])),
                              Expanded(
                                child: Text(
                                  u['lokasi'],
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Expanded(child: _StatusBadge(u['aktif'])),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minWidth: 78,
                                      maxWidth: 112,
                                    ),
                                    child: _ActionButton(
                                      label: u['aktif'] ? 'Nonaktif' : 'Aktifkan',
                                      color: u['aktif']
                                          ? AgriColors.danger
                                          : AgriColors.success,
                                      onTap: () => setState(
                                        () => u['aktif'] = !u['aktif'],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (e.key < filtered.length - 1)
                          const Divider(height: 1),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;
  const _TableHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: AgriColors.textLight,
    ),
  );
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);
  @override
  Widget build(BuildContext context) {
    final color = role == 'Petani'
        ? AgriColors.primary
        : AgriColors.primaryLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool aktif;
  const _StatusBadge(this.aktif);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: aktif
            ? AgriColors.success.withValues(alpha: 0.12)
            : AgriColors.danger.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        aktif ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          color: aktif ? AgriColors.success : AgriColors.danger,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
