class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role; // 'student' or 'startup'
  final List<String> skills;
  final String bio;
  final String? photoUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.skills = const [],
    this.bio = '',
    this.photoUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'student',
      skills: List<String>.from(map['skills'] ?? []),
      bio: map['bio'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'skills': skills,
      'bio': bio,
      'photoUrl': photoUrl,
    };
  }
}