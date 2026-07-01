class UserModel {
  static const String roleAdmin = 'Admin';
  static const String rolePetani = 'Petani';
  static const String rolePembeli = 'Pembeli';

  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? address;
  final String? avatar;
  final bool isVerified;
  final bool isActive;
  final String? shopName;
  final String? shopDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.avatar,
    required this.isVerified,
    required this.isActive,
    this.shopName,
    this.shopDescription,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      avatar: json['avatar'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      shopName: json['shop_name'] as String?,
      shopDescription: json['shop_description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'address': address,
      'avatar': avatar,
      'is_verified': isVerified,
      'is_active': isActive,
      'shop_name': shopName,
      'shop_description': shopDescription,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? address,
    String? avatar,
    bool? isVerified,
    bool? isActive,
    String? shopName,
    String? shopDescription,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      shopName: shopName ?? this.shopName,
      shopDescription: shopDescription ?? this.shopDescription,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isAdmin => role == roleAdmin;
  bool get isPetani => role == rolePetani;
  bool get isPembeli => role == rolePembeli;
}
