import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/product_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/planting_schedule_controller.dart';
import 'p3a_biaya_produksi_screen.dart';
import 'p3b_pemetaan_lahan_screen.dart';

// ── Data Models ──
enum ScheduleStatus {
  active('Aktif', 'Active'),
  planned('Rencana', 'Planned'),
  done('Selesai', 'Completed');

  final String labelId;
  final String labelEn;
  const ScheduleStatus(this.labelId, this.labelEn);

  String getLabel(bool isEnglish) => isEnglish ? labelEn : labelId;
}

class PlantingSchedule {
  int? id;
  String plant, land;
  DateTime startDate, harvestDate, harvestEndDate;
  ScheduleStatus status;
  bool isLocal;
  PlantingSchedule({
    this.id,
    required this.plant,
    required this.land,
    required this.startDate,
    required this.harvestDate,
    required this.harvestEndDate,
    required this.status,
    this.isLocal = false,
  });
}

// ── Constants ──
const _green = Color(0xFF2D832F);
const _greenLight = Color(0xFFE7F4E8);
const _bg = Color(0xFFEFF8EF);
const _title = Color(0xFF001A3D);
const _muted = Color(0xFF98A2B3);
const _plantOptions = ['Beras', 'Beras Premium', 'Jagung', 'Jagung Premium'];
const _landOptions = ['Sawah A', 'Sawah B', 'Kebun A', 'Kebun B'];

String _fmt(DateTime d, bool isEnglish) {
  final idMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  final enMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final m = isEnglish ? enMonths : idMonths;
  return '${d.day.toString().padLeft(2, '0')} ${m[d.month - 1]} ${d.year}';
}

// ── Main Screen ──
class P3JadwalTanamScreen extends StatefulWidget {
  final ValueChanged<String>? onScheduleDone;
  const P3JadwalTanamScreen({super.key, this.onScheduleDone});
  @override
  State<P3JadwalTanamScreen> createState() => _P3State();
}

class _P3State extends State<P3JadwalTanamScreen> {
  final List<PlantingSchedule> _local = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final id = auth.currentUser?.id;
      if (id != null) {
        context.read<ProductController>().loadSellerProducts(id);
      }
      context.read<PlantingScheduleController>().loadSchedules();
      context.read<PlantingScheduleController>().loadLands();
    });
  }

  List<PlantingSchedule> _allSchedules(ProductController ctrl, PlantingScheduleController scheduleCtrl) {
    final customSchedules = scheduleCtrl.schedules.map((s) {
      ScheduleStatus status = ScheduleStatus.planned;
      if (s.status == 'active') {
        status = ScheduleStatus.active;
      } else if (s.status == 'done') {
        status = ScheduleStatus.done;
      }
      return PlantingSchedule(
        id: s.id,
        plant: s.plant,
        land: s.land,
        startDate: s.startDate,
        harvestDate: s.harvestDate,
        harvestEndDate: s.harvestEndDate,
        status: status,
        isLocal: false,
      );
    }).toList();

    customSchedules.sort((a, b) => a.startDate.compareTo(b.startDate));
    return customSchedules;
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProductController>();
    final scheduleCtrl = context.watch<PlantingScheduleController>();
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final all = _allSchedules(ctrl, scheduleCtrl);

    final screenBg = isDark ? const Color(0xFF121212) : _bg;
    final headerBg = isDark ? const Color(0xFF1E1E1E) : _green;
    final titleColor = isDark ? Colors.white : _title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : _muted;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 56,
              color: headerBg,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEnglish ? 'Planting Schedule' : 'Jadwal Tanam',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: isEnglish ? 'Rice Field Map' : 'Peta Lahan',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const P3bPemetaanLahanScreen()),
                    ),
                    icon: const Icon(Icons.map_outlined, color: Colors.white, size: 28),
                  ),
                  IconButton(
                    tooltip: isEnglish ? 'Add' : 'Tambah',
                    onPressed: () => _showForm(isEnglish),
                    icon: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Timeline header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.timeline, color: _green, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    isEnglish ? 'Planting Timeline' : 'Timeline Aktivitas Tanam',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isEnglish ? '${all.length} schedules' : '${all.length} jadwal',
                    style: TextStyle(color: mutedColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Timeline list
            Expanded(
              child: RefreshIndicator(
                color: _green,
                onRefresh: () async {
                  final auth = context.read<AuthController>();
                  if (auth.currentUser?.id != null) {
                    await context.read<ProductController>().loadSellerProducts(auth.currentUser!.id!);
                  }
                  await context.read<PlantingScheduleController>().loadSchedules();
                },
                child: ctrl.isLoading && all.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : all.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 100),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_available,
                                  color: mutedColor.withValues(alpha: 0.4),
                                  size: 48,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isEnglish ? 'No planting schedules found' : 'Tidak ada jadwal tanam ditemukan',
                                  style: TextStyle(color: mutedColor, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(10, 4, 10, 20),
                        itemCount: all.length,
                        itemBuilder: (_, i) => _TimelineCard(
                          schedule: all[i],
                          isFirst: i == 0,
                          isLast: i == all.length - 1,
                        onEdit: (all[i].id != null || all[i].isLocal)
                            ? () => _showForm(isEnglish, edit: all[i])
                            : null,
                        onActivity: () => _openActivity(all[i]),
                    ),
                  ),
            )),
          ],
        ),
      ),
    );
  }

  void _openActivity(PlantingSchedule s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => P3aBiayaProduksiScreen(
          jadwalName: '${s.plant} - ${s.land}',
          startDate: s.startDate,
          harvestDate: s.harvestDate,
          harvestEndDate: s.harvestEndDate,
        ),
      ),
    );
  }

  void _showForm(bool isEnglish, {PlantingSchedule? edit}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final landsList = context.read<PlantingScheduleController>().lands;
    
    if (landsList.isEmpty && edit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEnglish ? 'Please add land in Land Mapping first.' : 'Harap tambahkan lahan di Pemetaan Lahan terlebih dahulu.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final landOptions = landsList.map((l) => l.name).toList();
    if (landOptions.isEmpty && edit != null && edit.land != null) {
      landOptions.add(edit.land!);
    }

    var plant = edit?.plant ?? 'Beras';
    var land = edit?.land ?? (landOptions.isNotEmpty ? landOptions.first : '');
    var start = edit?.startDate ?? DateTime.now();
    var days = plant.startsWith('Jagung') ? 90 : 120;
    var harvest = edit?.harvestDate ?? start.add(Duration(days: days));
    var harvestEnd =
        edit?.harvestEndDate ?? harvest.add(const Duration(days: 7));

    Future<void> pick(
      BuildContext ctx,
      DateTime init,
      ValueChanged<DateTime> cb,
    ) async {
      final p = await showDatePicker(
        context: ctx,
        initialDate: init,
        firstDate: DateTime(2020),
        lastDate: DateTime(2035),
      );
      if (p != null) cb(p);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.4,
        maxChildSize: 0.94,
        builder: (ctx, scroll) => StatefulBuilder(
          builder: (ctx, setSS) {
            void updatePlant(String p) {
              final d = p.startsWith('Jagung') ? 90 : 120;
              setSS(() {
                plant = p;
                harvest = start.add(Duration(days: d));
                harvestEnd = harvest.add(const Duration(days: 7));
              });
            }

            final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
            final labelColor = isDark ? Colors.white : _title;
            final chipUnselectedBg = isDark ? const Color(0xFF2A2A2A) : null;
            final chipUnselectedText = isDark ? Colors.white : _title;

            if (!landOptions.contains(land) && land.isNotEmpty) {
              landOptions.add(land);
            }

            return Container(
              padding: EdgeInsets.fromLTRB(
                22,
                20,
                22,
                MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scroll,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isEnglish 
                              ? (edit != null ? 'Edit Schedule' : 'Add Schedule') 
                              : (edit != null ? 'Edit Jadwal' : 'Tambah Jadwal'),
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        icon: const Icon(Icons.close, color: _muted, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _Label(isEnglish ? 'Plant' : 'Tanaman'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _plantOptions
                        .map(
                          (p) => ChoiceChip(
                            label: Text(p),
                            selected: plant == p,
                            selectedColor: _greenLight,
                            backgroundColor: chipUnselectedBg,
                            labelStyle: TextStyle(
                              color: plant == p ? _green : chipUnselectedText,
                              fontWeight: plant == p
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                            onSelected: (_) => updatePlant(p),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  _Label(isEnglish ? 'Land' : 'Lahan'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: landOptions
                        .map(
                          (l) => ChoiceChip(
                            label: Text(l),
                            selected: land == l,
                            selectedColor: _greenLight,
                            backgroundColor: chipUnselectedBg,
                            labelStyle: TextStyle(
                              color: land == l ? _green : chipUnselectedText,
                              fontWeight: land == l
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                            onSelected: (_) => setSS(() => land = l),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  _Label(isEnglish ? 'Date' : 'Tanggal'),
                  const SizedBox(height: 8),
                  _DateRow(
                    label: isEnglish ? 'Start Planting' : 'Mulai Tanam',
                    value: _fmt(start, isEnglish),
                    onTap: () => pick(ctx, start, (p) {
                      final d = plant.startsWith('Jagung') ? 90 : 120;
                      setSS(() {
                        start = p;
                        harvest = p.add(Duration(days: d));
                        harvestEnd = harvest.add(const Duration(days: 7));
                      });
                    }),
                  ),
                  const SizedBox(height: 8),
                  _DateRow(
                    label: isEnglish ? 'Start Harvesting' : 'Mulai Panen',
                    value: _fmt(harvest, isEnglish),
                    onTap: () => pick(ctx, harvest, (p) {
                      setSS(() {
                        harvest = p;
                        if (harvestEnd.isBefore(harvest)) {
                          harvestEnd = harvest.add(const Duration(days: 7));
                        }
                      });
                    }),
                  ),
                  const SizedBox(height: 8),
                  _DateRow(
                    label: isEnglish ? 'End Harvesting' : 'Selesai Panen',
                    value: _fmt(harvestEnd, isEnglish),
                    onTap: () => pick(
                      ctx,
                      harvestEnd,
                      (p) => setSS(() => harvestEnd = p),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final scheduleController = context.read<PlantingScheduleController>();
                        if (edit != null) {
                          if (edit.id != null) {
                            final success = await scheduleController.updateSchedule(
                              edit.id!,
                              plant: plant,
                              land: land,
                              startDate: start,
                              harvestDate: harvest,
                              harvestEndDate: harvestEnd,
                            );
                            if (!mounted) return;
                            if (success) {
                              scheduleController.loadSchedules();
                            }
                          } else {
                            setSS(() {
                              edit.plant = plant;
                              edit.land = land;
                              edit.startDate = start;
                              edit.harvestDate = harvest;
                              edit.harvestEndDate = harvestEnd;
                            });
                          }
                        } else {
                          final success = await scheduleController.createSchedule(
                            plant: plant,
                            land: land,
                            startDate: start,
                            harvestDate: harvest,
                            harvestEndDate: harvestEnd,
                            status: 'planned',
                          );
                          if (!mounted) return;
                          if (success) {
                            scheduleController.loadSchedules();
                          }
                        }
                        
                        Navigator.pop(sheetCtx);
                        final msg = isEnglish 
                            ? '$plant - $land ${edit != null ? "updated" : "added"}.'
                            : '$plant - $land ${edit != null ? "diperbarui" : "ditambahkan"}.';
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.onScheduleDone?.call(msg);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        edit != null 
                            ? (isEnglish ? 'Update' : 'Perbarui') 
                            : (isEnglish ? 'Save' : 'Simpan'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  if (edit != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () async {
                          final scheduleController = context.read<PlantingScheduleController>();
                          if (edit.id != null) {
                            final success = await scheduleController.deleteSchedule(edit.id!);
                            if (!mounted) return;
                            if (success) {
                              scheduleController.loadSchedules();
                            }
                          } else {
                            setState(() => _local.remove(edit));
                          }
                          if (!mounted) return;
                          Navigator.pop(sheetCtx);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isEnglish ? 'Delete Schedule' : 'Hapus Jadwal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Timeline Card ──
class _TimelineCard extends StatelessWidget {
  final PlantingSchedule schedule;
  final bool isFirst, isLast;
  final VoidCallback? onEdit, onActivity;
  const _TimelineCard({
    required this.schedule,
    required this.isFirst,
    required this.isLast,
    this.onEdit,
    this.onActivity,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = context.watch<LanguageController>().isEnglish;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sColor = schedule.status == ScheduleStatus.active
        ? const Color(0xFF079447)
        : schedule.status == ScheduleStatus.done
        ? (isDark ? const Color(0xFFB0B0B0) : _muted)
        : const Color(0xFFB77900);
    final sBg = schedule.status == ScheduleStatus.active
        ? (isDark ? const Color(0xFF1B3D2B) : const Color(0xFFD7FBE5))
        : schedule.status == ScheduleStatus.done
        ? (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F4F7))
        : (isDark ? const Color(0xFF3E2D1A) : const Color(0xFFFFF1B8));

    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : _title;
    final mutedColor = isDark ? const Color(0xFFB0B0B0) : _muted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Container(
                    width: 2,
                    height: 12,
                    color: _green.withValues(alpha: 0.3),
                  ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _green,
                    border: Border.all(color: _greenLight, width: 2.5),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : _green.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
          // Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black38 : Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1B3D2B) : const Color(0xFFD7FBE5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.eco_outlined,
                          color: Color(0xFF079447),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${schedule.plant} - ${schedule.land}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          schedule.status.getLabel(isEnglish),
                          style: TextStyle(
                            color: sColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildMilestoneTimeline(context, isEnglish, isDark),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      InkWell(
                        onTap: onActivity,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _greenLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.visibility, size: 13, color: _green),
                              const SizedBox(width: 4),
                              Text(
                                isEnglish ? 'View' : 'Lihat',
                                style: const TextStyle(
                                  color: _green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (onEdit != null) ...[
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: onEdit,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7E6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 13,
                                  color: Color(0xFFB77900),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: Color(0xFFB77900),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneTimeline(
    BuildContext context,
    bool isEnglish,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          _buildMilestoneRow(
            title: isEnglish ? 'Start Planting' : 'Mulai Tanam',
            dateStr: _fmt(schedule.startDate, isEnglish),
            color: const Color(0xFF2D832F), // Green
            isLast: false,
            isDark: isDark,
          ),
          _buildMilestoneRow(
            title: isEnglish ? 'Start Harvesting' : 'Mulai Panen',
            dateStr: _fmt(schedule.harvestDate, isEnglish),
            color: const Color(0xFFE65100), // Dark Orange
            isLast: false,
            isDark: isDark,
          ),
          _buildMilestoneRow(
            title: isEnglish ? 'End Harvesting' : 'Selesai Panen',
            dateStr: _fmt(schedule.harvestEndDate, isEnglish),
            color: const Color(0xFF1976D2), // Blue
            isLast: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow({
    required String title,
    required String dateStr,
    required Color color,
    required bool isLast,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 18,
                color: color.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF475467),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (!isLast) const SizedBox(height: 6),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Small Widgets ──
class _Label extends StatelessWidget {
  final String label;
  const _Label(this.label);
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF667085);
    return Text(
      label,
      style: TextStyle(
        color: labelColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label, value;
  final VoidCallback onTap;
  const _DateRow({
    required this.label,
    required this.value,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowBg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF2F4F7);
    final titleColor = isDark ? Colors.white : _title;

    return Material(
      color: rowBg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, color: _green, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: _green,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
