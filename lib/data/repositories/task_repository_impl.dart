import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:task_mngmt/core/api/api_client.dart';
import 'package:task_mngmt/core/constants/api_constants.dart';
import 'package:task_mngmt/domain/entities/task.dart';
import 'package:task_mngmt/domain/repositories/task_repository.dart';

@Injectable(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final ApiClient _apiClient;

  TaskRepositoryImpl(this._apiClient);

  @override
  Future<List<Task>> getTasks(BuildContext context, {int? userId}) async {
    final response = await _apiClient.get(
      '${ApiConstants.baseUrlTasks}${ApiConstants.todos}',
      context: context,
      queryParameters: userId != null ? {'userId': userId} : null,
    );
    // log('Tasks Response: ${response.data}');
    return (response.data as List).map((json) => Task.fromJson(json)).toList();
  }

  @override
  Future<Task> createTask({
    required Task task,
    required BuildContext context,
  }) async {
    log("CREATE TASK == ${task.toJson()}");
    final response = await _apiClient.post(
      '${ApiConstants.baseUrlTasks}${ApiConstants.todos}',
      context: context,
      data: task.toJson(),
      headers: {'Content-type': 'application/json; charset=UTF-8'},
    );
    log('Create Task Response Status: ${response.statusCode}');
    log('Create Task Response Body: ${response.data}');
    return Task.fromJson(response.data);
  }

  @override
  Future<Task> updateTask({
    required Task task,
    required BuildContext context,
  }) async {
    final response = await _apiClient.put(
      '${ApiConstants.baseUrlTasks}${ApiConstants.todos}/${task.id}',
      context: context,
      data: task.toJson(),
      headers: {'Content-type': 'application/json; charset=UTF-8'},
    );
    log('Update Task Response: ${response.data}');
    return Task.fromJson(response.data);
  }

  @override
  Future<void> deleteTask({
    required BuildContext context,
    required int id,
  }) async {
    log("Initiating delete for task ID: $id");
    final response = await _apiClient.delete(
      '${ApiConstants.baseUrlTasks}${ApiConstants.todos}/$id',
      context: context,
    );
    log('Delete Task Response Status: ${response.statusCode}');
    log('Delete Task Response Body: ${response.data}');
  }
}
