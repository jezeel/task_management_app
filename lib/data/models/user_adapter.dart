import 'package:hive/hive.dart';
import 'package:task_mngmt/domain/entities/user.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    return User.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.write(obj.toJson());
  }

  Future<void> delete(String key) async {
    var userBox = await Hive.openBox<User>('users');
    await userBox.delete(key);
  }
}
