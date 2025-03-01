import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_mngmt/domain/repositories/task_repository.dart';
import 'package:task_mngmt/domain/entities/task.dart';
import 'package:task_mngmt/domain/models/pending_operation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:injectable/injectable.dart';

part 'task_event.dart';
part 'task_state.dart';
part 'task_bloc.freezed.dart';
part 'task_bloc.g.dart';

@injectable
class TaskBloc extends HydratedBloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  final Connectivity _connectivity;
  final _uuid = const Uuid();

  TaskBloc(this._taskRepository)
      : _connectivity = Connectivity(),
        super(const TaskState()) {
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      // Skip sync if no context available yet
      if (state.pendingOperations.isEmpty) return;
      // Process pending operations without context
      _processPendingOperations();
    });

    on<TaskEvent>((event, emit) async {
      await event.map(
        started: (e) => _handleStarted(e, emit),
        created: (e) => _handleCreated(e, emit),
        updated: (e) => _handleUpdated(e, emit),
        deleted: (e) => _handleDeleted(e, emit),
        statusChanged: (e) => _handleStatusChanged(e, emit),
        priorityChanged: (e) => _handlePriorityChanged(e, emit),
      );
    });
  }

  Future<void> _handleStarted(_Started event, Emitter<TaskState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final tasks = await _taskRepository.getTasks(event.context);
      emit(state.copyWith(tasks: tasks, isLoading: false));
    } catch (error) {
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }

  Future<void> _handleCreated(_Created event, Emitter<TaskState> emit) async {
    final operation = PendingOperation(
      id: _uuid.v4(),
      type: OperationType.create,
      timestamp: DateTime.now(),
      task: event.task,
    );

    final updatedTasks = [...state.tasks, event.task];
    final updatedOperations = [...state.pendingOperations, operation];

    emit(state.copyWith(
      tasks: updatedTasks,
      pendingOperations: updatedOperations,
    ));

    await _syncOperation(operation, event.context);
  }

  Future<void> _handleUpdated(_Updated event, Emitter<TaskState> emit) async {
    final operation = PendingOperation(
      id: _uuid.v4(),
      type: OperationType.update,
      timestamp: DateTime.now(),
      task: event.task,
    );

    final updatedTasks = state.tasks.map((task) =>
        task.id == event.task.id ? event.task : task).toList();
    final updatedOperations = [...state.pendingOperations, operation];

    emit(state.copyWith(
      tasks: updatedTasks,
      pendingOperations: updatedOperations,
    ));

    await _syncOperation(operation, event.context);
  }

  Future<void> _handleDeleted(_Deleted event, Emitter<TaskState> emit) async {
    final operation = PendingOperation(
      id: _uuid.v4(),
      type: OperationType.delete,
      timestamp: DateTime.now(),
      taskId: event.id,
    );

    final updatedTasks = state.tasks.where((task) => task.id != event.id).toList();
    final updatedOperations = [...state.pendingOperations, operation];

    emit(state.copyWith(
      tasks: updatedTasks,
      pendingOperations: updatedOperations,
    ));

    await _syncOperation(operation, event.context);
  }

  Future<void> _syncOperation(PendingOperation operation, BuildContext? context) async {
    if (context == null) return; // Skip if no context available

    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return; // Store operation for later sync
    }

    try {
      switch (operation.type) {
        case OperationType.create:
          await _taskRepository.createTask(
            context: context,
            task: operation.task!,
          );
          break;
        case OperationType.update:
          await _taskRepository.updateTask(
            context: context,
            task: operation.task!,
          );
          break;
        case OperationType.delete:
          await _taskRepository.deleteTask(
            context: context,
            id: operation.taskId!,
          );
          break;
      }

      // Update state through bloc event
      add(TaskEvent.started(context));
    } catch (e) {
      // Keep operation in pending list if sync fails
    }
  }

  Future<void> _processPendingOperations() async {
    if (state.pendingOperations.isEmpty) return;
    
    // Sort operations by timestamp
    final sortedOperations = [...state.pendingOperations]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Process each operation in order
    for (final operation in sortedOperations) {
      await _syncOperation(operation, null);
    }
  }

  Future<void> _handleStatusChanged(_StatusChanged event, Emitter<TaskState> emit) async {
    final updatedTask = event.task.copyWith(status: event.status);
    add(TaskEvent.updated(context: event.context, task: updatedTask));
  }

  Future<void> _handlePriorityChanged(_PriorityChanged event, Emitter<TaskState> emit) async {
    final updatedTask = event.task.copyWith(priority: event.priority);
    add(TaskEvent.updated(context: event.context, task: updatedTask));
  }

  @override
  TaskState? fromJson(Map<String, dynamic> json) => TaskState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(TaskState state) => state.toJson();
}