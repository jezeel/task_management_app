import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:task_mngmt/domain/entities/task.dart';

part 'pending_operation.freezed.dart';
part 'pending_operation.g.dart';

enum OperationType { create, update, delete }

@freezed
class PendingOperation with _$PendingOperation {
  const factory PendingOperation({
    required String id,
    required OperationType type,
    required DateTime timestamp,
    Task? task,
    int? taskId,
  }) = _PendingOperation;

  factory PendingOperation.fromJson(Map<String, dynamic> json) =>
      _$PendingOperationFromJson(json);
} 