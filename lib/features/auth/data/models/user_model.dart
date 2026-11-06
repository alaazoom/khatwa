import 'package:ajyal/core/errors/app_errors.dart';

class UserModel {
  const UserModel({required this.id, required this.name, required this.email});

  final String id;
  final String name;
  final String email;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final UserModel user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final token = json['token'];
    final user = json['user'];
    if (token is! String || user is! Map<String, dynamic>) {
      throw const AppException(AppErrorType.server, 'err_server');
    }
    return AuthSession(token: token, user: UserModel.fromJson(user));
  }
}