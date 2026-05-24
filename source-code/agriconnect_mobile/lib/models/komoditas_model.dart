// lib/models/komoditas_model.dart

class KomoditasModel {
  final int? id;
  final String namaKomoditas;
  final int siklusHariDefault;
  final String satuan;
  final String? deskripsi;
  final int active;
  final String updatedAt;
  final String? syncedAt;

  KomoditasModel({
    this.id,
    required this.namaKomoditas,
    this.siklusHariDefault = 90,
    this.satuan = "kg",
    this.deskripsi,
    this.active = 1,
    required this.updatedAt,
    this.syncedAt,
  });

  factory KomoditasModel.fromMap(Map<String, dynamic> map) {
    return KomoditasModel(
      id: map['id'],
      namaKomoditas: map['nama_komoditas'] ?? '',
      siklusHariDefault: map['siklus_hari_default'] ?? 90,
      satuan: map['satuan'] ?? 'kg',
      deskripsi: map['deskripsi'],
      active: map['active'] ?? 1,
      updatedAt: map['updated_at'] ?? '',
      syncedAt: map['synced_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama_komoditas': namaKomoditas,
      'siklus_hari_default': siklusHariDefault,
      'satuan': satuan,
      'deskripsi': deskripsi,
      'active': active,
      'updated_at': updatedAt,
      'synced_at': syncedAt,
    };
  }

  KomoditasModel copyWith({
    int? id,
    String? namaKomoditas,
    int? siklusHariDefault,
    String? satuan,
    String? deskripsi,
    int? active,
    String? updatedAt,
    String? syncedAt,
  }) {
    return KomoditasModel(
      id: id ?? this.id,
      namaKomoditas: namaKomoditas ?? this.namaKomoditas,
      siklusHariDefault: siklusHariDefault ?? this.siklusHariDefault,
      satuan: satuan ?? this.satuan,
      deskripsi: deskripsi ?? this.deskripsi,
      active: active ?? this.active,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  String toString() => 'KomoditasModel($id, $namaKomoditas, $siklusHariDefault hari)';
}
