import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/material.dart';
import 'package:task_mngmt/presentation/screens/login_screen.dart';

@singleton
class ApiClient {
  late final Dio _dio;
  late final Box<String> _tokenBox;

  ApiClient() {
    _dio =
        Dio()
          ..options = BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
          )
          ..interceptors.add(
            LogInterceptor(
              request: true,
              responseBody: true,
              requestBody: true,
              requestHeader: true,
            ),
          );
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _tokenBox = await Hive.openBox<String>('tokens');
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool withToken = false,
    required BuildContext context,
  }) async {
    final options = Options();
    if (withToken) {
      final token = _tokenBox.get('token');
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      } else {
        _navigateToLogin(context);
        throw Exception('Token not found');
      }
    }
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    bool withToken = false,
    required BuildContext context,
    Map<String, String>? headers,
  }) async {
    final options = Options(headers: headers);
    if (withToken) {
      final token = _tokenBox.get('token');
      if (token != null) {
        options.headers = {
          ...options.headers ?? {},
          'Authorization': 'Bearer $token'
        };
      } else {
        _navigateToLogin(context);
        throw Exception('Token not found');
      }
    }
    return _dio.post(path, data: data, options: options);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    bool withToken = false,
    required BuildContext context,
    Map<String, String>? headers,
  }) async {
    final options = Options(headers: headers);
    if (withToken) {
      final token = _tokenBox.get('token');
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      } else {
        _navigateToLogin(context);
        throw Exception('Token not found');
      }
    }
    return _dio.put(path, data: data, options: options);
  }

  Future<Response> delete(
    String path, {
    bool withToken = false,
    required BuildContext context,
  }) async {
    log("TEST 2 -- DELETE == $path");
    final options = Options();
    if (withToken) {
      final token = _tokenBox.get('token');
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      } else {
        _navigateToLogin(context);
        throw Exception('Token not found');
      }
    }
    return _dio.delete(path, options: options);
  }

  void _navigateToLogin(BuildContext context) {
    // Implement navigation to login screen
    // This is just a placeholder, you need to implement the actual navigation logic
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}
