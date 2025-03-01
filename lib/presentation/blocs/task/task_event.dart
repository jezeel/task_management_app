part of 'task_bloc.dart';

@freezed
class TaskEvent with _$TaskEvent {
  const factory TaskEvent.started(BuildContext context) = _Started;
  const factory TaskEvent.created({required BuildContext context, required Task task}) = _Created;
  const factory TaskEvent.updated({required BuildContext context, required Task task}) = _Updated;
  const factory TaskEvent.deleted({required BuildContext context, required int id}) = _Deleted;
  const factory TaskEvent.statusChanged({required BuildContext context, required Task task, required String status}) = _StatusChanged;
  const factory TaskEvent.priorityChanged({required BuildContext context, required Task task, required String priority}) = _PriorityChanged;
}