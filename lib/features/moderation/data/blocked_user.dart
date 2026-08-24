/// A blocked-user summary, as returned by `GET /v1/users/me/blocks`.
class BlockedUser {
  const BlockedUser({
    required this.userId,
    required this.displayName,
    this.avatarPath,
  });

  final String userId;
  final String displayName;
  final String? avatarPath;

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      userId: json['userId'] as String? ?? json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ??
          json['name'] as String? ??
          '',
      avatarPath: json['avatarPath'] as String?,
    );
  }
}
