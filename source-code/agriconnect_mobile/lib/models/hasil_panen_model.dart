// lib/models/hasil_panen_model.dart

class HasilPanenModel {
  final int? id;
  final int? serverId;
  final int userId;
  final int? jadwalTanamId;
  final int komoditasId;
  final String tglPanen;
  final double jumlah;
  final String satuan;
  final String kualitas;
  final String? fotoPath;
  final String? fotoServerPath;
  final String? catatan;
  final int isDeleted;
  final String createdAt;
  final String updatedAt;
  final String? syncedAt;
  final int isDirty;

  HasilPanenModel({
    this.id,
    this.serverId,
    required this.userId,
    this.jadwalTanamId,
    required this.komoditasId,
    required this.tglPanen,
    required this.jumlah,
    this.satuan = "kg",
    this.kualitas = "standar",
    this.fotoPath,
    this.fotoServerPath,
    this.catatan,
    this.isDeleted = 0,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    this.isDirty = 1,
  });

  factory HasilPanenModel.fromMap(Map<String, dynamic> map) {
    return HasilPanenModel(
      id: map['id'],
      serverId: map['server_id'],
      userId: map['user_id'] ?? 0,
      jadwalTanamId: map['jadwal_tanam_id'],
      komoditasId: map['komoditas_id'] ?? 0,
      tglPanen: map['tgl_panen'] ?? '',
      jumlah: (map['jumlah'] as num?)?.toDouble() ?? 0.0,
      satuan: map['satuan'] ?? 'kg',
      kualitas: map['kualitas'] ?? 'standar',
      fotoPath: map['foto_path'],
      fotoServerPath: map['foto_server_path'],
      catatan: map['catatan'],
      isDeleted: map['is_deleted'] ?? 0,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      syncedAt: map['synced_at'],
      isDirty: map['is_dirty'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (serverId != null) 'server_id': serverId,
      'user_id': userId,
      'jadwal_tanam_id': jadwalTanamId,
      'komoditas_id': komoditasId,
      'tgl_panen': tglPanen,
      'jumlah': jumlah,
      'satuan': satuan,
      'kualitas': kualitas,
      'foto_path': fotoPath,
      'foto_server_path': fotoServerPath,
      'catatan': catatan,
      'is_deleted': isDeleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'synced_at': syncedAt,
      'is_dirty': isDirty,
    };
  }

  HasilPanenModel copyWith({
    int? id,
    int? serverId,
    int? userId,
    int? jadwalTanamId,
    int? komoditasId,
    String? tglPanen,
    double? jumlah,
    String? satuan,
    String? kualitas,
    String? fotoPath,
    String? fotoServerPath,
    String? catatan,
    int? isDeleted,
    String? createdAt,
    String? updatedAt,
    String? syncedAt,
    int? isDirty,
  }) {
    return HasilPanenModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      jadwalTanamId: jadwalTanamId ?? this.jadwalTanamId,
      komoditasId: komoditasId ?? this.komoditasId,
      tglPanen: tglPanen ?? this.tglPanen,
      jumlah: jumlah ?? this.jumlah,
      satuan: satuan ?? this.satuan,
      kualitas: kualitas ?? this.kualitas,
      fotoPath: fotoPath ?? this.fotoPath,
      fotoServerPath: fotoServerPath ?? this.fotoServerPath,
      catatan: catatan ?? this.catatan,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  String toString() => 'HasilPanenModel($id, $jumlah $satuan, $tglPanen, $kualitas)';
}
