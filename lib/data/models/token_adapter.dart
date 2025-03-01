import 'package:hive/hive.dart';

class TokenAdapter extends TypeAdapter<String> {
  @override
  final int typeId = 2;

  @override
  String read(BinaryReader reader) {
    return reader.readString();
  }

  @override
  void write(BinaryWriter writer, String obj) {
    writer.writeString(obj);
  }

  Future<void> delete(String key) async {
    var tokenBox = await Hive.openBox<String>('tokens');
    await tokenBox.delete(key);
  }
}