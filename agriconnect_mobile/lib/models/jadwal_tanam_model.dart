// lib/models/jadwal_tanam_model.dart

class JadwalTanamModel {
  final int? id;
  final int? serverId;
  final int userId;
  final int komoditasId;
  final String tglTanam;
  final double? luasLahanHa;
  final String tglPanenEstimasi;
  final String? tglPanenAktual;
  final String status;
  final String? catatan;
  final int isDeleted;
  final String createdAt;
  final String updatedAt;
  final String? syncedAt;
  final int isDirty;
  
  // Field tambahan dari JOIN dengan komoditas
  final String? namaKomoditas;
  final int? siklusHariDefault;

  JadwalTanamModel({
    this.id,
    this.serverId,
    required this.userId,
    required this.komoditasId,
    required this.tglTanam,
    this.luasLahanHa,
    required this.tglPanenEstimasi,
    this.tglPanenAktual,
    this.status = "aktif",
    this.catatan,
    this.isDeleted = 0,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    this.isDirty = 1,
    this.namaKomoditas,
    this.siklusHariDefault,
  });

  factory JadwalTanamModel.fromMap(Map<String, dynamic> map) {
    return JadwalTanamModel(
      id: map['id'],
      serverId: map['server_id'],
      userId: map['user_id'] ?? 0,
      komoditasId: map['komoditas_id'] ?? 0,
      tglTanam: map['tgl_tanam'] ?? '',
      luasLahanHa: map['luas_lahan_ha'],
      tglPanenEstimasi: map['tgl_panen_estimasi'] ?? '',
      tglPanenAktual: map['tgl_panen_aktual'],
      status: map['status'] ?? 'aktif',
      catatan: map['catatan'],
      isDeleted: map['is_deleted'] ?? 0,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      syncedAt: map['synced_at'],
      isDirty: map['is_dirty'] ?? 1,
      namaKomoditas: map['nama_komoditas'],
      siklusHariDefault: map['siklus_hari_default'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      'user_id': userId,
      'komoditas_id': komoditasId,
      'tgl_tanam': tglTanam,
      'luas_lahan_ha': luasLahanHa,
      'tgl_panen_estimasi': tglPanenEstimasi,
      'tgl_panen_aktual': tglPanenAktual,
      'status': status,
      'catatan': catatan,
      'is_deleted': isDeleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'synced_at': syncedAt,
      'is_dirty': isDirty,
    };
  }

  JadwalTanamModel copyWith({
    int? id,
    int? serverId,
    int? userId,
    int? komoditasId,
    String? tglTanam,
    double? luasLahanHa,
    String? tglPanenEstimasi,
    String? tglPanenAktual,
    String? status,
    String? catatan,
    int? isDeleted,
    String? createdAt,
    String? updatedAt,
    String? syncedAt,
    int? isDirty,
    String? namaKomoditas,
    int? siklusHariDefault,
  }) {
    return JadwalTanamModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      komoditasId: komoditasId ?? this.komoditasId,
      tglTanam: tglTanam ?? this.tglTanam,
      luasLahanHa: luasLahanHa ?? this.luasLahanHa,
      tglPanenEstimasi: tglPanenEstimasi ?? this.tglPanenEstimasi,
      tglPanenAktual: tglPanenAktual ?? this.tglPanenAktual,
      status: status ?? this.status,
      catatan: catatan ?? this.catatan,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
      namaKomoditas: namaKomoditas ?? this.namaKomoditas,
      siklusHariDefault: siklusHariDefault ?? this.siklusHariDefault,
    );
  }

  @override
  String toString() => 'JadwalTanamModel($id, $namaKomoditas, $tglTanam - $tglPanenEstimasi, $status)';
}
