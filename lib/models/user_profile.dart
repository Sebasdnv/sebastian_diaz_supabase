class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime birthdate;

  UserProfile({
    required this.id,
    required this.username,
    required this.birthdate,
    this.avatarUrl,
  });

  int get age {
    final today = DateTime.now();
    int age = today.year - birthdate.year;

    if (today.month < birthdate.month ||
        (today.month == birthdate.month && today.day < birthdate.day)) {
      age--;
    }
    return age;
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      username: map['username'],
      birthdate: DateTime.parse(map['birthdate']),
      avatarUrl: map['avatar_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'birthdate': birthdate.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }
}
