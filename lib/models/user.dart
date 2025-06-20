class getUser {
  final String? email;
  final String? username;
  final String? avatarUrl;

  getUser({this.email, this.username, this.avatarUrl});

  factory getUser.fromJson(Map<String, dynamic> json) {
    return getUser(
      email: json['email'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
