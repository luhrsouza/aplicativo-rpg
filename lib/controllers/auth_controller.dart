import 'dart:math';
import '../models/user.dart';

class AuthController {

  static final AuthController _instance = AuthController._internal();

  factory AuthController() {
    return _instance;
  }

  AuthController._internal();
  final List<User> _users = [];

  User? currentUser;

  Future<String?> register ({
    required String name,
    required String email,
    required String password,
}) async {
    await Future.delayed(const Duration(seconds: 1));

    if (_users.any((user) => user.email == email)) {
      return 'Uma conta já existe com este email.';
    }

    final newUser = User(
      id: Random().nextInt(9999).toString(),
      name: name,
      email: email,
      password: password,
    );

    _users.add(newUser);
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
}) async {
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = _users.firstWhere(
            (user) => user.email == email && user.password == password,
      );
      currentUser = user;
      return null;
    } catch(e) {
      return 'Email ou Senha inválidos';
    }
  }

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  void logout() {
    currentUser = null;
  }
}
