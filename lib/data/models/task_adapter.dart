import 'package:hive/hive.dart';
import 'package:task_mngmt/domain/entities/task.dart';

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    return Task.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.write(obj.toJson());
  }
}