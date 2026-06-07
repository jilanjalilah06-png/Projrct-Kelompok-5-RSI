// lib/models/user_model.dart

class UserModel {
  final int? id;
  final String nama;
  final String email;
  final String noHp;
  final String? lokasi;
  final String role;
  final int active;
  final String createdAt;
  final String updatedAt;
  final String? syncedAt;

  UserModel({
    this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    this.lokasi,
    this.role = "user",
    this.active = 1,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      noHp: map['no_hp'] ?? '',
      lokasi: map['lokasi'],
      role: map['role'] ?? 'user',
      active: map['active'] ?? 1,
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
      syncedAt: map['synced_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'email': email,
      'no_hp': noHp,
      'lokasi': lokasi,
      'role': role,
      'active': active,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'synced_at': syncedAt,
    };
  }

  UserModel copyWith({
    int? id,
    String? nama,
    String? email,
    String? noHp,
    String? lokasi,
    String? role,
    int? active,
    String? createdAt,
    String? updatedAt,
    String? syncedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      lokasi: lokasi ?? this.lokasi,
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  String toString() => 'UserModel($id, $nama, $email)';
}
