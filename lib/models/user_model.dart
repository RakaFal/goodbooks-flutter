class User {
  final String name;
  final String email;
  final String phone;
  final String profileImageUrl;

  User({
    required this.name,
    required this.email,
    required this.phone,
    this.profileImageUrl = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? 'John Doe',
      email: json['email'] ?? 'johndoe@example.com',
      phone: json['phone'] ?? '+6281234567890',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'profileImageUrl': profileImageUrl,
      };
}