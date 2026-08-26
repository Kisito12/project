enum UserRole { superAdmin, companyAdmin, companyWorker }

UserRole userRoleFromString(String value) {
  return UserRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => UserRole.companyWorker,
  );
}

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  /// The company this user belongs to. Null for super admins, who sit above
  /// every company on the platform.
  final String? companyId;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.companyId,
  });

  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isCompanyAdmin => role == UserRole.companyAdmin;
  bool get isCompanyWorker => role == UserRole.companyWorker;

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: userRoleFromString(map['role'] as String? ?? 'companyWorker'),
      companyId: map['companyId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'companyId': companyId,
    };
  }
}
