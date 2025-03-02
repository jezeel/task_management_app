import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/material.dart';
import 'package:task_mngmt/presentation/screens/login_screen.dart';
import 'package:task_mngmt/core/errors/api_error.dart';

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
    try {
      final options = Options();
      if (withToken) {
        final token = _tokenBox.get('token');
        if (token != null) {
          options.headers = {'Authorization': 'Bearer $token'};
        } else {
          throw ApiError(
            message: 'Authentication Required',
            action: 'GET $path',
            details: 'Token not found. Please login again.',
          );
        }
      }
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiError(
        message: _getDioErrorMessage(e),
        action: 'GET $path',
        details: e.response?.data?.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ApiError(
        message: e.toString(),
        action: 'GET $path',
        details: 'An unexpected error occurred',
      );
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    bool withToken = false,
    required BuildContext context,
    Map<String, String>? headers,
  }) async {
    try {
      final options = Options(headers: headers);
      if (withToken) {
        final token = _tokenBox.get('token');
        if (token != null) {
          options.headers = {
            ...options.headers ?? {},
            'Authorization': 'Bearer $token'
          };
        } else {
          throw ApiError(
            message: 'Authentication Required',
            action: 'POST $path',
            details: 'Token not found. Please login again.',
          );
        }
      }
      return await _dio.post(path, data: data, options: options);
    } on DioException catch (e) {
      throw ApiError(
        message: _getDioErrorMessage(e),
        action: 'POST $path',
        details: e.response?.data?.toString(),
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ApiError(
        message: e.toString(),
        action: 'POST $path',
        details: 'An unexpected error occurred',
      );
    }
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

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'Network error occurred. Please check your connection.';
    }
  }

  String _handleBadResponse(Response? response) {
    switch (response?.statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
