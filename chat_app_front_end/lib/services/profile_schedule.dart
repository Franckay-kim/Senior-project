class ProfileSchedule {
  ProfileSchedule({
    required this.id,
    required this.username,
  });

  /// User ID of the profile
  final String id;

  /// Username of the profile
  final String username;

  ProfileSchedule.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        username = map['username'];
}
