import 'package:flutter/material.dart';

import 'p3a_biaya_produksi_screen.dart';

class P3JadwalTanamScreen extends StatefulWidget {
  final ValueChanged<String>? onScheduleDone;

  const P3JadwalTanamScreen({super.key, this.onScheduleDone});

  @override
  State<P3JadwalTanamScreen> createState() => _P3JadwalTanamScreenState();
}

class _P3JadwalTanamScreenState extends State<P3JadwalTanamScreen> {
  final List<_PlantingSchedule> _schedules = [
    _PlantingSchedule(
      plant: 'Padi',
      land: 'Sawah A',
      startDate: DateTime(2026, 3, 1),
      harvestDate: DateTime(2026, 6, 30),
      status: _ScheduleStatus.active,
    ),
    _PlantingSchedule(
      plant: 'Padi Premium',
      land: 'Sawah B',
      startDate: DateTime(2026, 3, 15),
      harvestDate: DateTime(2026, 7, 14),
      status: _ScheduleStatus.active,
    ),
    _PlantingSchedule(
      plant: 'Jagung',
      land: 'Kebun A',
      startDate: DateTime(2026, 4, 1),
      harvestDate: DateTime(2026, 7, 1),
      status: _ScheduleStatus.active,
    ),
    _PlantingSchedule(
      plant: 'Jagung Premium',
      land: 'Kebun B',
      startDate: DateTime(2026, 4, 10),
      harvestDate: DateTime(2026, 7, 10),
      status: _ScheduleStatus.active,
    ),
  ];

  static const _green = Color(0xFF2D832F);
  static const _background = Color(0xFFEFF8EF);
  static const _title = Color(0xFF001A3D);
  static const _muted = Color(0xFF98A2B3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onAdd: _showAddScheduleSheet),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(10, 18, 10, 28),
                itemCount: _schedules.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _ScheduleCard(
                    schedule: _schedules[index],
                    onActivity: () => _openActivities(_schedules[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openActivities(_PlantingSchedule schedule) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => P3aBiayaProduksiScreen(
          jadwalName: '${schedule.plant} - ${schedule.land}',
        ),
      ),
    );
  }

  void _showAddScheduleSheet() {
    var selectedPlant = 'Padi';
    var selectedLand = 'Sawah A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                34,
                30,
                22,
                MediaQuery.of(context).viewInsets.bottom + 28,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Pilih Tanaman',
                          style: TextStyle(
                            color: _title,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tutup',
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(
                          Icons.close,
                          color: _muted,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const _SheetLabel('Tanaman'),
                  const SizedBox(height: 10),
                  for (final plant in _plantOptions) ...[
                    _ChoiceTile(
                      label: plant,
                      selected: selectedPlant == plant,
                      onTap: () => setSheetState(() => selectedPlant = plant),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 12),
                  const _SheetLabel('Lahan'),
                  const SizedBox(height: 10),
                  for (final land in _landOptions) ...[
                    _ChoiceTile(
                      label: land,
                      selected: selectedLand == land,
                      onTap: () => setSheetState(() => selectedLand = land),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 72,
                    child: ElevatedButton(
                      onPressed: () {
                        final startDate = DateTime(2026, 7, 20);
                        final harvestDate = startDate.add(
                          Duration(
                            days: selectedPlant.startsWith('Jagung') ? 90 : 120,
                          ),
                        );

                        setState(() {
                          _schedules.add(
                            _PlantingSchedule(
                              plant: selectedPlant,
                              land: selectedLand,
                              startDate: startDate,
                              harvestDate: harvestDate,
                              status: _ScheduleStatus.planned,
                            ),
                          );
                        });

                        widget.onScheduleDone?.call(
                          '$selectedPlant - $selectedLand ditambahkan ke jadwal tanam.',
                        );
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

const _plantOptions = ['Padi', 'Padi Premium', 'Jagung', 'Jagung Premium'];
const _landOptions = ['Sawah A', 'Sawah B', 'Kebun A', 'Kebun B'];

class _Header extends StatelessWidget {
  final VoidCallback onAdd;

  const _Header({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: _P3JadwalTanamScreenState._green,
      padding: const EdgeInsets.only(left: 10, right: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Jadwal Tanam',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Tambah jadwal',
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final _PlantingSchedule schedule;
  final VoidCallback onActivity;

  const _ScheduleCard({required this.schedule, required this.onActivity});

  @override
  Widget build(BuildContext context) {
    final statusColor = schedule.status == _ScheduleStatus.active
        ? const Color(0xFFD7FBE5)
        : const Color(0xFFFFF1B8);
    final textColor = schedule.status == _ScheduleStatus.active
        ? const Color(0xFF079447)
        : const Color(0xFFB77900);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFD7FBE5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.eco_outlined,
              color: Color(0xFF079447),
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.plant} - ${schedule.land}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _P3JadwalTanamScreenState._title,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mulai: ${_formatDate(schedule.startDate)}',
                  style: const TextStyle(
                    color: _P3JadwalTanamScreenState._muted,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Panen: ${_formatDate(schedule.harvestDate)}',
                  style: const TextStyle(
                    color: _P3JadwalTanamScreenState._muted,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  schedule.status.label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: onActivity,
                borderRadius: BorderRadius.circular(14),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: Text(
                    'Aktivitas ->',
                    style: TextStyle(
                      color: Color(0xFFD0D5DD),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE7F4E8) : const Color(0xFFF2F4F7),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? _P3JadwalTanamScreenState._green
                  : _P3JadwalTanamScreenState._title,
              fontSize: 22,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String label;

  const _SheetLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF667085),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

enum _ScheduleStatus {
  active('Aktif'),
  planned('Rencana');

  final String label;

  const _ScheduleStatus(this.label);
}

class _PlantingSchedule {
  final String plant;
  final String land;
  final DateTime startDate;
  final DateTime harvestDate;
  final _ScheduleStatus status;

  const _PlantingSchedule({
    required this.plant,
    required this.land,
    required this.startDate,
    required this.harvestDate,
    required this.status,
  });
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
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}
