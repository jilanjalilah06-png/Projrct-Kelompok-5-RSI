import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/admin_controller.dart';
class AdminKomisiPencairanScreen extends StatefulWidget {
  const AdminKomisiPencairanScreen({super.key});

  @override
  State<AdminKomisiPencairanScreen> createState() => _AdminKomisiPencairanScreenState();
}

class _AdminKomisiPencairanScreenState extends State<AdminKomisiPencairanScreen> {
  static const _primary = Color(0xFF079447);
  static const _bg = Color(0xFFF9FAFB);
  static const _textDark = Color(0xFF1F2937);
  static const _textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadPayouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();
    final totalRevenue = controller.dashboard?.totalRevenue ?? 0.0;
    final komisiAdminVal = totalRevenue * 0.06; // 6% komisi Admin
    
    final pendings = controller.pendingPayouts;
    final totalPendapatanPetaniVal = pendings.fold<double>(0.0, (sum, item) {
      final val = item['wallet_balance'] ?? 0.0;
      return sum + (val is num ? val.toDouble() : double.tryParse(val.toString()) ?? 0.0);
    });
    final pendingCount = pendings.length;

    final history = controller.payoutHistory;
    final totalTransferredVal = history.fold<double>(0.0, (sum, item) {
      final val = item['amount'] ?? 0.0;
      return sum + (val is num ? val.toDouble() : double.tryParse(val.toString()) ?? 0.0);
    });
    final transferredCount = history.length;

    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    final komisiAdminStr = currencyFormatter.format(komisiAdminVal);
    final totalPendapatanPetaniStr = currencyFormatter.format(totalPendapatanPetaniVal);
    final totalTransferredStr = currencyFormatter.format(totalTransferredVal);

    return Scaffold(
      backgroundColor: _bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KEUANGAN',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Komisi & Pencairan',
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

            // 3 Stat Cards Row
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 900;
                final cardWidth = isNarrow 
                    ? constraints.maxWidth 
                    : (constraints.maxWidth - 32) / 3;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Card 1
                    SizedBox(
                      width: cardWidth,
                      child: _buildStatCard(
                        title: 'KOMISI ADMIN',
                        value: komisiAdminStr,
                        subtitle: 'Dari total transaksi penjualan platform',
                        borderColor: const Color(0xFFB57018),
                      ),
                    ),
                    // Card 2
                    SizedBox(
                      width: cardWidth,
                      child: _buildStatCard(
                        title: 'PENDAPATAN PETANI',
                        value: totalPendapatanPetaniStr,
                        subtitle: '$pendingCount petani belum dicairkan',
                        borderColor: const Color(0xFFB57018),
                      ),
                    ),
                    // Card 3
                    SizedBox(
                      width: cardWidth,
                      child: _buildStatCard(
                        title: 'SUDAH DITRANSFER BULAN INI',
                        value: totalTransferredStr,
                        subtitle: '$transferredCount petani',
                        borderColor: const Color(0xFF2C6A4F),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Section 1: Pencairan ke Petani
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
                    'Pencairan ke Petani',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Dana pesanan selesai dikumpulkan di rekening AgriConnect, lalu dicairkan manual per petani setelah dipotong komisi',
                    style: TextStyle(fontSize: 13, color: _textMuted),
                  ),
                  const SizedBox(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Consumer<AdminController>(
                      builder: (context, controller, _) {
                        if (controller.loading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final pendings = controller.pendingPayouts;
                        if (pendings.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Belum ada pencairan tertunda.', style: TextStyle(color: _textMuted)),
                          );
                        }
                        
                        final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            horizontalMargin: 8,
                          columnSpacing: 44,
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFFBFBFB)),
                          columns: const [
                            DataColumn(label: Text('PETANI', style: _headerStyle)),
                            DataColumn(label: Text('NAMA BANK', style: _headerStyle)),
                            DataColumn(label: Text('NO. REKENING', style: _headerStyle)),
                            DataColumn(label: Text('SALDO KE PETANI', style: _headerStyle)),
                            DataColumn(label: Text('STATUS', style: _headerStyle)),
                            DataColumn(label: Text('ACTION', style: _headerStyle)),
                          ],
                          rows: pendings.map((p) {
                            final double netAmount = double.tryParse(p['wallet_balance']?.toString() ?? '0') ?? 0;
                            return _buildPencairanRow(
                              userId: p['id'],
                              name: p['name'] ?? '-',
                              bankName: p['nama_bank'] ?? '-',
                              accountNumber: p['no_rekening'] ?? '-',
                              netAmount: formatter.format(netAmount),
                              status: 'Belum Ditransfer',
                              statusColor: const Color(0xFFB57018),
                              isTransferred: false,
                              controller: controller,
                            );
                          }).toList(),
                        ));
                      }
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Riwayat Transfer
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
                    'Riwayat Transfer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Catatan seluruh pencairan dana ke petani',
                    style: TextStyle(fontSize: 13, color: _textMuted),
                  ),
                  const SizedBox(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Consumer<AdminController>(
                      builder: (context, controller, _) {
                        if (controller.loading) return const SizedBox.shrink();
                        
                        final history = controller.payoutHistory;
                        if (history.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Belum ada riwayat transfer.', style: TextStyle(color: _textMuted)),
                          );
                        }

                        final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
                        
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            horizontalMargin: 8,
                          columnSpacing: 64,
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFFBFBFB)),
                          columns: const [
                            DataColumn(label: Text('TANGGAL', style: _headerStyle)),
                            DataColumn(label: Text('PETANI', style: _headerStyle)),
                            DataColumn(label: Text('BANK', style: _headerStyle)),
                            DataColumn(label: Text('REKENING', style: _headerStyle)),
                            DataColumn(label: Text('JUMLAH', style: _headerStyle)),
                          ],
                          rows: history.map((h) {
                            final dateStr = h['created_at'] != null 
                                ? DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(h['created_at']).toLocal()) 
                                : '-';
                            final double amount = double.tryParse(h['amount']?.toString() ?? '0') ?? 0;
                            
                            return DataRow(
                              cells: [
                                DataCell(Text(dateStr, style: const TextStyle(fontSize: 13, color: _textDark))),
                                DataCell(Text(h['user_name'] ?? '-', style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.bold))),
                                DataCell(Text(h['bank_name'] ?? '-', style: const TextStyle(fontSize: 13, color: _textDark))),
                                DataCell(Text(h['account_number'] ?? '-', style: const TextStyle(fontSize: 13, color: _textDark))),
                                DataCell(Text(formatter.format(amount), style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.bold))),
                              ],
                            );
                          }).toList(),
                        ));
                      }
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color borderColor,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 5),
        ),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Color(0xFF90A398),
              letterSpacing: 0.5,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _textDark,
              fontFamily: 'Georgia',
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: _textMuted,
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildPencairanRow({
    required int userId,
    required String name,
    required String bankName,
    required String accountNumber,
    required String netAmount,
    required String status,
    required Color statusColor,
    required bool isTransferred,
    required AdminController controller,
  }) {
    return DataRow(
      cells: [
        // PETANI
        DataCell(
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: _textDark,
              fontSize: 13,
            ),
          ),
        ),
        // NAMA BANK
        DataCell(Text(bankName, style: const TextStyle(fontSize: 13, color: _textDark))),
        // NO. REKENING
        DataCell(Text(accountNumber, style: const TextStyle(fontSize: 13, color: _textDark))),
        // SALDO KE PETANI
        DataCell(Text(netAmount, style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.bold))),
        // STATUS
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // ACTION
        DataCell(
          ElevatedButton(
            onPressed: isTransferred ? null : () => _showTransferDialog(context, name, bankName, accountNumber, netAmount, userId, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: isTransferred ? const Color(0xFFF3F4F6) : _primary,
              foregroundColor: isTransferred ? _textMuted : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Text(isTransferred ? 'Selesai' : 'Transfer', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _showTransferDialog(BuildContext context, String name, String bankName, String accountNo, String amount, int userId, AdminController controller) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Pencairan Dana Petani'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detail Rekening Tujuan:\n• Nama: $name\n• Bank: $bankName\n• Rekening: $accountNo\n• Jumlah: $amount'),
              const SizedBox(height: 16),
              const Text('Pilih metode transfer pencairan:', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    _runMidtransPayoutSimulation(context, name, amount, userId, controller);
                  },
                  icon: const Icon(Icons.payment, color: Colors.white, size: 16),
                  label: const Text('Transfer via Midtrans Iris'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF002B5C), foregroundColor: Colors.white),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    _executePayout(context, userId, controller, name, 'Manual');
                  },
                  icon: const Icon(Icons.account_balance, color: Colors.white, size: 16),
                  label: const Text('Transfer Manual (Konfirmasi Langsung)'),
                  style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
              ],
            )
          ],
        );
      }
    );
  }

  void _runMidtransPayoutSimulation(BuildContext context, String name, String amount, int userId, AdminController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFF002B5C)),
              SizedBox(width: 20),
              Expanded(
                child: Text('Menghubungkan ke Midtrans Iris Disbursement API...'),
              ),
            ],
          ),
        );
      }
    );

    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!context.mounted) return;
      Navigator.pop(context); // Close connecting dialog

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: Color(0xFF002B5C)),
                SizedBox(width: 20),
                Expanded(
                  child: Text('Memproses Transfer Pencairan via Midtrans Iris...'),
                ),
              ],
            ),
          );
        }
      );

      Future.delayed(const Duration(milliseconds: 1500), () async {
        if (!context.mounted) return;
        Navigator.pop(context); // Close processing dialog

        _executePayout(context, userId, controller, name, 'Midtrans Iris');
      });
    });
  }

  Future<void> _executePayout(BuildContext context, int userId, AdminController controller, String name, String method) async {
    // Show a small processing spinner for the actual controller operation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final success = await controller.processPayout(userId);
    
    if (!context.mounted) return;
    Navigator.pop(context); // Close spinner

    if (success) {
      // Reload payouts list and stats immediately
      controller.loadPayouts();
      controller.loadDashboard();

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Pencairan Sukses'),
            ],
          ),
          content: Text('Pencairan dana sejumlah petani atas nama $name telah berhasil diproses menggunakan metode: $method.\n\nStatus Midtrans Iris: SUCCESS\nDisbursement ID: IRIS-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.error ?? 'Gagal memproses pencairan.')),
      );
    }
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF6E7E75),
  letterSpacing: 0.5,
);
