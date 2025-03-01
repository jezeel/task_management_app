import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:task_mngmt/core/api/api_client.dart';
import 'package:task_mngmt/core/constants/api_constants.dart';
import 'package:task_mngmt/domain/entities/user.dart';
import 'package:task_mngmt/domain/repositories/auth_repository.dart';
import 'package:hive/hive.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  late final Box<String> _tokenBox;
  late final Box<User> _userBox;
  final Completer<void> _hiveInitialized = Completer<void>();

  AuthRepositoryImpl(this._apiClient) {
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _tokenBox = await Hive.openBox<String>('tokens');
    _userBox = await Hive.openBox<User>('users');
    _hiveInitialized.complete();
  }

  Future<void> _ensureHiveInitialized() async {
    if (!_hiveInitialized.isCompleted) {
      await _hiveInitialized.future;
    }
  }

  @override
  Future<User> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    await _ensureHiveInitialized();

    final loginResponse = await _apiClient.post(
      '${ApiConstants.baseUrlAuth}${ApiConstants.register}',
      context: context,
      withToken: false,
      data: {'email': email, 'password': password},
    );
    log("Login response: ${loginResponse.data}");

    final userId = loginResponse.data['id'];
    final token = loginResponse.data['token'];

    // Save token to Hive
    await _tokenBox.put('token', token);

    final userResponse = await _apiClient.get(
      '${ApiConstants.baseUrlAuth}${ApiConstants.users}/$userId',
      context: context,
      withToken: true,
    );
    log("User details response: ${userResponse.data}");

    final user = User.fromJson(userResponse.data['data']);
    await _userBox.put('user', user);

    return user;
  }

  @override
  Future<User> register({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    await _ensureHiveInitialized();

    final response = await _apiClient.post(
      '${ApiConstants.baseUrlAuth}${ApiConstants.register}',
      context: context,
      data: {'email': email, 'password': password},
    );
    log("Register response: ${response.data}");

    final userId = response.data['id'];
    final token = response.data['token'];

    // Save token to Hive
    await _tokenBox.put('token', token);

    final userResponse = await _apiClient.get(
      '${ApiConstants.baseUrlAuth}${ApiConstants.users}/$userId',
      context: context,
      withToken: true,
    );
    log("User details response: ${userResponse.data}");

    final user = User.fromJson(userResponse.data['data']);
    await _userBox.put('user', user);

    return user;
  }

  @override
  Future<void> logout() async {
    await _ensureHiveInitialized();

    // Implement local logout logic
    await _tokenBox.delete('token');
    await _userBox.delete('user');
  }

  @override
  Future<User?> getCurrentUser() async {
    await _ensureHiveInitialized();

    final user = _userBox.get('user');
    return user;
  }
}
