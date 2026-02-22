class AppUser {
  final int id;
  final String name;
  final String email;
  final String avatar;
  final String role;
  final DateTime? creationAt;
  final DateTime? updatedAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
    this.creationAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      role: json['role'] as String? ?? '',
      creationAt: json['creationAt'] != null
          ? DateTime.tryParse(json['creationAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar': avatar,
        'role': role,
        'creationAt': creationAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
