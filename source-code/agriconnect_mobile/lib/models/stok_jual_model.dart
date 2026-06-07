// lib/models/stok_jual_model.dart

class StokJualModel {
  final int? id;
  final int? serverId;
  final int userId;
  final int komoditasId;
  final double jumlahTersedia;
  final String satuan;
  final double hargaTawarRp;
  final String? deskripsi;
  final String? lokasiJual;
  final String? fotoPath;
  final String? fotoServerPath;
  final int publik;
  final String tglTersedia;
  final int isDeleted;
  final String createdAt;
  final String updatedAt;
  final String? syncedAt;
  final int isDirty;

  StokJualModel({
    this.id,
    this.serverId,
    required this.userId,
    required this.komoditasId,
    required this.jumlahTersedia,
    this.satuan = "kg",
    required this.hargaTawarRp,
    this.deskripsi,
    this.lokasiJual,
    this.fotoPath,
    this.fotoServerPath,
    this.publik = 0,
    required this.tglTersedia,
    this.isDeleted = 0,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    this.isDirty = 1,
  });

  factory StokJualModel.fromMap(Map<String, dynamic> map) {
    return StokJualModel(
      id: map['id'],
      serverId: map['server_id'],
      userId: map['user_id'] ?? 0,
      komoditasId: map['komoditas_id'] ?? 0,
      jumlahTersedia: (map['jumlah_tersedia'] as num?)?.toDouble() ?? 0.0,
      satuan: map['satuan'] ?? 'kg',
      hargaTawarRp: (map['harga_tawar_rp'] as num?)?.toDouble() ?? 0.0,
      deskripsi: map['deskripsi'],
      lokasiJual: map['lokasi_jual'],
      fotoPath: map['foto_path'],
      fotoServerPath: map['foto_server_path'],
      publik: map['publik'] ?? 0,
      tglTersedia: map['tgl_tersedia'] ?? '',
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
      'komoditas_id': komoditasId,
      'jumlah_tersedia': jumlahTersedia,
      'satuan': satuan,
      'harga_tawar_rp': hargaTawarRp,
      'deskripsi': deskripsi,
      'lokasi_jual': lokasiJual,
      'foto_path': fotoPath,
      'foto_server_path': fotoServerPath,
      'publik': publik,
      'tgl_tersedia': tglTersedia,
      'is_deleted': isDeleted,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'synced_at': syncedAt,
      'is_dirty': isDirty,
    };
  }

  StokJualModel copyWith({
    int? id,
    int? serverId,
    int? userId,
    int? komoditasId,
    double? jumlahTersedia,
    String? satuan,
    double? hargaTawarRp,
    String? deskripsi,
    String? lokasiJual,
    String? fotoPath,
    String? fotoServerPath,
    int? publik,
    String? tglTersedia,
    int? isDeleted,
    String? createdAt,
    String? updatedAt,
    String? syncedAt,
    int? isDirty,
  }) {
    return StokJualModel(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      userId: userId ?? this.userId,
      komoditasId: komoditasId ?? this.komoditasId,
      jumlahTersedia: jumlahTersedia ?? this.jumlahTersedia,
      satuan: satuan ?? this.satuan,
      hargaTawarRp: hargaTawarRp ?? this.hargaTawarRp,
      deskripsi: deskripsi ?? this.deskripsi,
      lokasiJual: lokasiJual ?? this.lokasiJual,
      fotoPath: fotoPath ?? this.fotoPath,
      fotoServerPath: fotoServerPath ?? this.fotoServerPath,
      publik: publik ?? this.publik,
      tglTersedia: tglTersedia ?? this.tglTersedia,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  String toString() => 'StokJualModel($id, $jumlahTersedia $satuan @ Rp $hargaTawarRp, publik=$publik)';
}
