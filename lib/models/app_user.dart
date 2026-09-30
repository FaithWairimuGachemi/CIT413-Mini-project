class AppUser {
  final String admissionNumber; // primary key
  final String firstName;
  final String? middleName;
  final String lastName;
  final String passwordHash;
  final String salt;
  final String? profilePicturePath;

  const AppUser({
    required this.admissionNumber,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.passwordHash,
    required this.salt,
    this.profilePicturePath,
  });

  String get fullName => [firstName, middleName, lastName]
      .where((p) => p != null && p.trim().isNotEmpty)
      .join(' ');

  Map<String, Object?> toMap() => {
        'admission_number': admissionNumber,
        'first_name': firstName,
        'middle_name': middleName,
        'last_name': lastName,
        'password_hash': passwordHash,
        'salt': salt,
        'profile_picture_path': profilePicturePath,
      };

  factory AppUser.fromMap(Map<String, Object?> m) => AppUser(
        admissionNumber: m['admission_number'] as String,
        firstName: m['first_name'] as String,
        middleName: m['middle_name'] as String?,
        lastName: m['last_name'] as String,
        passwordHash: m['password_hash'] as String,
        salt: m['salt'] as String,
        profilePicturePath: m['profile_picture_path'] as String?,
      );
}
