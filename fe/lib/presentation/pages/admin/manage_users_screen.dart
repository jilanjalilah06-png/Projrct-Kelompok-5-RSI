import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
import '../../../data/models/user_model.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});
  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _filterRole = 'Semua Role';
  final _searchCtrl = TextEditingController();

  // Green themed colors
  static const Color _bg = Color(0xFFF8FAF8);
  static const Color _textDark = Color(0xFF1D2939);
  static const Color _textMuted = Color(0xFF667085);
  static const Color _greenAccent = Color(0xFF2D6A4F);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUsers());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() {
    return context.read<AdminController>().loadUsers(
      role: _filterRole,
      search: _searchCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminController>();
    final users = admin.users;

    return Scaffold(
      backgroundColor: _bg,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            const Text(
              'MANAJEMEN',
              style: TextStyle(
                color: _greenAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Daftar User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _textDark,
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
                      onChanged: (_) => _loadUsers(),
                      decoration: InputDecoration(
                        hintText: 'Cari user...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF98A2B3)),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: Color(0xFF98A2B3),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D5DD),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFD0D5DD),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: _greenAccent,
                            width: 1.5,
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
                    border: Border.all(color: const Color(0xFFD0D5DD)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterRole,
                      style: const TextStyle(fontSize: 13, color: _textDark),
                      items: ['Semua Role', 'Admin', 'Petani', 'Pembeli']
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _filterRole = v);
                        _loadUsers();
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (admin.loading && users.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (admin.error != null && users.isEmpty)
              Expanded(
                child: _StatePanel(message: admin.error!, onRetry: _loadUsers),
              )
            else
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE4E7EC)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
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
                              top: Radius.circular(16),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 2, child: _TableHeader('NAMA')),
                              Expanded(flex: 2, child: _TableHeader('EMAIL')),
                              Expanded(child: _TableHeader('ROLE')),
                              Expanded(child: _TableHeader('LOKASI')),
                              Expanded(child: _TableHeader('STATUS')),
                              Expanded(child: _TableHeader('AKSI')),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // Rows
                        if (users.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Tidak ada user yang cocok.',
                              style: TextStyle(color: _textMuted),
                            ),
                          ),
                        ...users.asMap().entries.map((e) {
                          final u = e.value;
                          return Column(
                            children: [
                              InkWell(
                                onTap: () => _showUserDetails(context, u),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          u.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          u.email,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: _textMuted,
                                          ),
                                        ),
                                      ),
                                      Expanded(child: _RoleBadge(u.role)),
                                      Expanded(
                                        child: Text(
                                          u.address ?? '-',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                      Expanded(child: _StatusBadge(u.isActive)),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              minWidth: 78,
                                              maxWidth: 112,
                                            ),
                                            child: _ActionButton(
                                              label: u.isActive
                                                  ? 'Nonaktif'
                                                  : 'Aktifkan',
                                              color: u.isActive
                                                  ? const Color(0xFFF04438)
                                                  : const Color(0xFF12B76A),
                                              onTap: () => context
                                                  .read<AdminController>()
                                                  .toggleUserStatus(u.id),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (e.key < users.length - 1)
                                const Divider(height: 1),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(BuildContext context, UserModel u) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                u.role == 'Petani' ? Icons.agriculture_rounded : Icons.shopping_basket_rounded,
                color: u.role == 'Petani' ? const Color(0xFF2D6A4F) : const Color(0xFF1565C0),
              ),
              const SizedBox(width: 8),
              const Text(
                'Detail Pengguna',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow('Nama', u.name),
                _detailRow('Username', u.username ?? '-'),
                _detailRow('Email', u.email),
                _detailRow('Role', u.role),
                _detailRow('Alamat', u.address ?? '-'),
                if (u.role == 'Petani') ...[
                  _detailRow('NIK', u.nik ?? '-'),
                  _detailRow('No Rekening', u.noRekening ?? '-'),
                  _detailRow('Nama Bank', u.namaBank ?? '-'),
                ],
                _detailRow('Status', u.isActive ? 'Aktif' : 'Nonaktif'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup', style: TextStyle(color: _greenAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: _textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _StatePanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(color: Color(0xFFF04438)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
              ),
              onPressed: onRetry,
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
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
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF667085),
      letterSpacing: 0.5,
    ),
  );
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);
  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (role) {
      case 'Admin':
        bgColor = const Color(0xFF2D6A4F);
        textColor = Colors.white;
        break;
      case 'Petani':
        bgColor = const Color(0xFFD4EDDA);
        textColor = const Color(0xFF2D6A4F);
        break;
      default:
        bgColor = const Color(0xFFF2F4F7);
        textColor = const Color(0xFF344054);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          role,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
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
    final color = aktif ? const Color(0xFF12B76A) : const Color(0xFFF04438);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              aktif ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 14,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              aktif ? 'Aktif' : 'Nonaktif',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
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
      ),
    );
  }
}
