import 'package:flutter/material.dart';
import 'package:task_mngmt/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required BuildContext context,
    required String email,
    required String password,
  });
  Future<User> register({
    required BuildContext context,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<User?> getCurrentUser();
}
