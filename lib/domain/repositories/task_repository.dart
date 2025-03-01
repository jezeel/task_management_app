import 'package:flutter/material.dart';
import 'package:task_mngmt/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasks(BuildContext context);
  Future<Task> createTask({required Task task, required BuildContext context});
  Future<Task> updateTask({required Task task, required BuildContext context});
  Future<void> deleteTask({required BuildContext context, required int id});
}
