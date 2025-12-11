class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // "hr" atau "user"

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Dari JSON (response backend)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  // Ke JSON (untuk disimpan)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
    };
  }

  // Helper methods
  bool isHR() => role == 'hr';
  bool isUser() => role == 'user';
}