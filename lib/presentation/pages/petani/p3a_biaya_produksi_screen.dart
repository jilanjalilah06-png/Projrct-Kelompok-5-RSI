import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constanst/api_constants.dart';
import '../../../core/constanst/agri_colors.dart';
import '../../../data/services/api_service.dart';

class P3aBiayaProduksiScreen extends StatefulWidget {
  final String jadwalName;
  final DateTime? startDate;
  final DateTime? harvestDate;
  final DateTime? harvestEndDate;

  const P3aBiayaProduksiScreen({
    super.key,
    required this.jadwalName,
    this.startDate,
    this.harvestDate,
    this.harvestEndDate,
  });

  @override
  State<P3aBiayaProduksiScreen> createState() => _P3aBiayaProduksiScreenState();
}

class _P3aBiayaProduksiScreenState extends State<P3aBiayaProduksiScreen> {
  static const _green = Color(0xFF159447);
  static const _darkGreen = Color(0xFF1F6B2A);
  static const _title = Color(0xFF001A3D);
  static const _muted = Color(0xFF98A2B3);
  static const _softGreen = Color(0xFFDDF2E7);

  late DateTime _visibleMonth;
  late DateTime _selectedDate;
  late final List<_PlantActivity> _activities;
  bool _hasUnsavedChanges = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final base = widget.startDate ?? DateTime(2026, 4, 9);
    _visibleMonth = DateTime(base.year, base.month);
    _selectedDate = DateTime(base.year, base.month, base.day);
    _activities = [];
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadActivities());
  }

  int get _total => _activities.fold(0, (sum, item) => sum + item.cost);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgriColors.background,
      appBar: AppBar(
        backgroundColor: _darkGreen,
        title: const Text(
          'Aktivitas Tanam',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Tambah aktivitas',
            onPressed: _showAddActivitySheet,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          _ScheduleBanner(
            name: widget.jadwalName,
            startDate: widget.startDate,
            harvestDate: widget.harvestDate,
            harvestEndDate: widget.harvestEndDate,
          ),
          const SizedBox(height: 14),
          _CalendarCard(
            visibleMonth: _visibleMonth,
            selectedDate: _selectedDate,
            activityDates: _activities.map((item) => item.date).toSet(),
            startDate: widget.startDate,
            harvestDate: widget.harvestDate,
            harvestEndDate: widget.harvestEndDate,
            onPrevious: () => setState(() {
              _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
            }),
            onNext: () => setState(() {
              _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
            }),
            onSelectDate: (date) => setState(() => _selectedDate = date),
          ),
          const SizedBox(height: 18),
          const Text(
            'Daftar Aktivitas',
            style: TextStyle(
              color: _title,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (_activities.isEmpty)
            const _EmptyActivities()
          else
            for (final activity in _sortedActivities) ...[
              _ActivityCard(activity: activity),
              const SizedBox(height: 12),
            ],
          _TotalCard(total: _total),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _showAddActivitySheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'Tambah Aktivitas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveActivities,
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkGreen,
                disabledBackgroundColor: _darkGreen.withValues(alpha: 0.65),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Icon(
                      _activities.isNotEmpty && !_hasUnsavedChanges
                          ? Icons.check_circle_outline
                          : Icons.save_outlined,
                    ),
              label: Text(
                _isSaving
                    ? 'Menyimpan...'
                    : _activities.isNotEmpty && !_hasUnsavedChanges
                    ? 'Tersimpan'
                    : 'Simpan',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_PlantActivity> get _sortedActivities {
    final copy = [..._activities];
    copy.sort((a, b) => a.date.compareTo(b.date));
    return copy;
  }

  Future<void> _loadActivities() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiService>();
      final scheduleName = Uri.encodeComponent(widget.jadwalName);
      final response = await api.getRequest(
        '${ApiConstants.plantingActivitiesEndpoint}?schedule_name=$scheduleName',
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        setState(() {
          _activities
            ..clear()
            ..addAll(
              data.map((item) => _PlantActivity.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  )),
            );
          _hasUnsavedChanges = false;
        });
      } else {
        _showMessage('Gagal memuat aktivitas tanam.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveActivities() async {
    if (_activities.isEmpty) {
      _showMessage('Tambahkan aktivitas dulu sebelum menyimpan.', isWarning: true);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final api = context.read<ApiService>();
      final response = await api.postRequest(
        ApiConstants.plantingActivitiesSyncEndpoint,
        {
          'schedule_name': widget.jadwalName,
          'activities': _activities.map((item) => item.toJson()).toList(),
        },
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as List<dynamic>? ?? [];
        setState(() {
          _activities
            ..clear()
            ..addAll(
              data.map((item) => _PlantActivity.fromJson(
                    Map<String, dynamic>.from(item as Map),
                  )),
            );
          _hasUnsavedChanges = false;
        });
        _showMessage(
          'Aktivitas tanam tersimpan. Total biaya Rp ${_formatRupiah(_total)}.',
        );
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        _showMessage(
          body['message']?.toString() ?? 'Gagal menyimpan aktivitas tanam.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
    bool isWarning = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red.shade700
            : isWarning
                ? Colors.orange.shade700
                : _green,
      ),
    );
  }

  void _showAddActivitySheet() {
    final titleCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var activityDate = _selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickActivityDate() async {
              final picked = await showDatePicker(
                context: context,
                initialDate: activityDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                setSheetState(() => activityDate = picked);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Tambah Aktivitas',
                              style: TextStyle(
                                color: _title,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Tutup',
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close, color: _muted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SheetField(
                        controller: titleCtrl,
                        label: 'Isi Kegiatan',
                        hint: 'Contoh: Pemupukan, Penyiraman...',
                      ),
                      const SizedBox(height: 14),
                      _SheetField(
                        controller: costCtrl,
                        label: 'Total Biaya',
                        hint: 'Rp',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      _SheetDateButton(
                        value: _formatDate(activityDate),
                        onTap: pickActivityDate,
                      ),
                      const SizedBox(height: 14),
                      _SheetField(
                        controller: noteCtrl,
                        label: 'Keterangan',
                        hint: 'Bibit, pekerja, pupuk...',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () async {
                            final title = titleCtrl.text.trim();
                            final cost = _parseMoney(costCtrl.text);
                            if (title.isEmpty || cost <= 0) return;

                            setState(() {
                              _hasUnsavedChanges = true;
                              _selectedDate = activityDate;
                              _visibleMonth = DateTime(
                                activityDate.year,
                                activityDate.month,
                              );
                              _activities.add(
                                _PlantActivity(
                                  date: activityDate,
                                  title: title,
                                  note: noteCtrl.text.trim().isEmpty
                                      ? 'Aktivitas tanam'
                                      : noteCtrl.text.trim(),
                                  cost: cost,
                                ),
                              );
                            });
                            Navigator.pop(sheetContext);
                            await _saveActivities();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      titleCtrl.dispose();
      costCtrl.dispose();
      noteCtrl.dispose();
    });
  }
}

class _ScheduleBanner extends StatelessWidget {
  final String name;
  final DateTime? startDate;
  final DateTime? harvestDate;
  final DateTime? harvestEndDate;

  const _ScheduleBanner({
    required this.name,
    this.startDate,
    this.harvestDate,
    this.harvestEndDate,
  });

  @override
  Widget build(BuildContext context) {
    final dates = [
      if (startDate != null) 'Mulai ${_formatDate(startDate!)}',
      if (harvestDate != null) 'Panen ${_formatDate(harvestDate!)}',
      if (harvestEndDate != null) 'Selesai ${_formatDate(harvestEndDate!)}',
    ].join(' - ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF159447).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.calendar_month, color: Color(0xFF159447), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadwal: $name',
                  style: const TextStyle(
                    color: Color(0xFF159447),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (dates.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    dates,
                    style: const TextStyle(color: Color(0xFF4E7C5D), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final Set<DateTime> activityDates;
  final DateTime? startDate;
  final DateTime? harvestDate;
  final DateTime? harvestEndDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectDate;

  const _CalendarCard({
    required this.visibleMonth,
    required this.selectedDate,
    required this.activityDates,
    this.startDate,
    this.harvestDate,
    this.harvestEndDate,
    required this.onPrevious,
    required this.onNext,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );
    final leadingEmpty = firstDay.weekday % 7;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Bulan sebelumnya',
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left, color: _P3aBiayaProduksiScreenState._muted),
              ),
              Expanded(
                child: Text(
                  '${_monthName(visibleMonth.month)} ${visibleMonth.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _P3aBiayaProduksiScreenState._title,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Bulan berikutnya',
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right, color: _P3aBiayaProduksiScreenState._muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: const [
              _WeekdayLabel('Min'),
              _WeekdayLabel('Sen'),
              _WeekdayLabel('Sel'),
              _WeekdayLabel('Rab'),
              _WeekdayLabel('Kam'),
              _WeekdayLabel('Jum'),
              _WeekdayLabel('Sab'),
            ],
          ),
          GridView.builder(
            itemCount: leadingEmpty + daysInMonth,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmpty) return const SizedBox.shrink();
              final day = index - leadingEmpty + 1;
              final date = DateTime(visibleMonth.year, visibleMonth.month, day);
              final selected = _sameDay(date, selectedDate);
              final hasActivity = activityDates.any((item) => _sameDay(item, date));

              final isStartDate = startDate != null && _sameDay(date, startDate!);
              final isHarvestDate = harvestDate != null && _sameDay(date, harvestDate!);
              final isHarvestEndDate = harvestEndDate != null && _sameDay(date, harvestEndDate!);

              Color? cellBg;
              Color cellTextColor = _P3aBiayaProduksiScreenState._title;
              FontWeight cellFontWeight = FontWeight.w500;
              String? labelText;
              Color? labelColor;

              if (selected) {
                cellBg = _P3aBiayaProduksiScreenState._darkGreen;
                cellTextColor = Colors.white;
                cellFontWeight = FontWeight.w900;
              } else if (isStartDate) {
                cellBg = const Color(0xFFE7F4E8);
                cellTextColor = const Color(0xFF2D832F);
                cellFontWeight = FontWeight.w900;
              } else if (isHarvestDate) {
                cellBg = const Color(0xFFFFF3E0);
                cellTextColor = const Color(0xFFE65100);
                cellFontWeight = FontWeight.w900;
              } else if (isHarvestEndDate) {
                cellBg = const Color(0xFFE3F2FD);
                cellTextColor = const Color(0xFF1976D2);
                cellFontWeight = FontWeight.w900;
              } else if (hasActivity) {
                cellBg = _P3aBiayaProduksiScreenState._softGreen;
                cellTextColor = _P3aBiayaProduksiScreenState._green;
                cellFontWeight = FontWeight.w900;
              }

              if (isStartDate) {
                labelText = 'Mulai';
                labelColor = const Color(0xFF2D832F);
              } else if (isHarvestDate) {
                labelText = 'Panen';
                labelColor = const Color(0xFFE65100);
              } else if (isHarvestEndDate) {
                labelText = 'Selesai';
                labelColor = const Color(0xFF1976D2);
              }

              Widget bottomWidget = const SizedBox(height: 10);
              if (labelText != null) {
                bottomWidget = Text(
                  labelText,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                );
              } else if (hasActivity) {
                bottomWidget = Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: _P3aBiayaProduksiScreenState._green,
                    shape: BoxShape.circle,
                  ),
                );
              }

              return Center(
                child: InkWell(
                  onTap: () => onSelectDate(date),
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: cellBg ?? Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: cellTextColor,
                            fontSize: 13,
                            fontWeight: cellFontWeight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 10,
                        child: Center(child: bottomWidget),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: const TextStyle(
          color: _P3aBiayaProduksiScreenState._muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final _PlantActivity activity;

  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _P3aBiayaProduksiScreenState._softGreen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              activity.date.day.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: _P3aBiayaProduksiScreenState._green,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _P3aBiayaProduksiScreenState._title,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  activity.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _P3aBiayaProduksiScreenState._muted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Rp ${_formatRupiah(activity.cost)}',
            style: const TextStyle(
              color: _P3aBiayaProduksiScreenState._darkGreen,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyActivities extends StatelessWidget {
  const _EmptyActivities();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Text(
        'Belum ada aktivitas. Tekan tambah untuk mencatat biaya tanam.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _P3aBiayaProduksiScreenState._muted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final int total;

  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _P3aBiayaProduksiScreenState._darkGreen,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Total Biaya',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            'Rp ${_formatRupiah(total)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _P3aBiayaProduksiScreenState._muted,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF6F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetDateButton extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _SheetDateButton({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: _P3aBiayaProduksiScreenState._green),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tanggal Aktivitas',
                style: TextStyle(
                  color: _P3aBiayaProduksiScreenState._title,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: _P3aBiayaProduksiScreenState._green,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlantActivity {
  final DateTime date;
  final String title;
  final String note;
  final int cost;

  const _PlantActivity({
    required this.date,
    required this.title,
    required this.note,
    required this.cost,
  });

  factory _PlantActivity.fromJson(Map<String, dynamic> json) {
    return _PlantActivity(
      date: DateTime.parse(json['activity_date'].toString()),
      title: json['title']?.toString() ?? '',
      note: json['note']?.toString() ?? 'Aktivitas tanam',
      cost: int.tryParse(json['cost'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_date': _dateOnly(date),
      'title': title,
      'note': note,
      'cost': cost,
    };
  }
}

int _parseMoney(String value) {
  return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
}

String _formatRupiah(int value) {
  final raw = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final remaining = raw.length - i;
    buffer.write(raw[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return buffer.toString();
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} ${_monthName(date.month)} ${date.year}';
}

String _monthName(int month) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return months[month - 1];
}

bool _sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _dateOnly(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}
