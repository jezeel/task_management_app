import 'package:flutter/material.dart';
import 'package:task_mngmt/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers(BuildContext context);
  Future<User> getUser({required BuildContext context, required int id});
}
