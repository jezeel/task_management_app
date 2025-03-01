import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:task_mngmt/core/api/api_client.dart';
import 'package:task_mngmt/core/constants/api_constants.dart';
import 'package:task_mngmt/domain/entities/user.dart';
import 'package:task_mngmt/domain/repositories/user_repository.dart';

@Injectable(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final ApiClient _apiClient;

  UserRepositoryImpl(this._apiClient);

  @override
  Future<List<User>> getUsers(BuildContext context) async {
    final response = await _apiClient.get(
      '${ApiConstants.baseUrlAuth}${ApiConstants.users}',
      context: context,
      withToken: true,
    );
    return (response.data['data'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  @override
  Future<User> getUser({required BuildContext context, required int id}) async {
    final response = await _apiClient.get(
      '${ApiConstants.baseUrlAuth}${ApiConstants.users}/$id',
      context: context,
    );
    return User.fromJson(response.data['data']);
  }
}
