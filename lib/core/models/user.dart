class AppUser {
  final int? id;
  final String fullName;
  final String username;
  final String email;
  final String passwordHash;

  AppUser({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'username': username,
        'email': email,
        'password_hash': passwordHash,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as int?,
        fullName: map['full_name'] as String,
        username: map['username'] as String,
        email: map['email'] as String,
        passwordHash: map['password_hash'] as String,
      );
}
