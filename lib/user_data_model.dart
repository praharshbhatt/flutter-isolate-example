class UserDataModel {
  final int userId, id;

  final String title, body;

  UserDataModel({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'id': id,
      'title': title,
      'body': body,
    };
  }
}
