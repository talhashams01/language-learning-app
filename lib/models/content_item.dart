
import 'package:hive/hive.dart';

class ContentItem {
  final String id;
  final String pair;
  final String type; 
  final String text; 
  final String translation;
  final String example;
  bool seen;
  bool learned;

  ContentItem({
    required this.id,
    required this.pair,
    required this.type,
    required this.text,
    required this.translation,
    this.example = '',
    this.seen = false,
    this.learned = false,
  });
}

class ContentItemAdapter extends TypeAdapter<ContentItem> {
  @override
  final int typeId = 2;

  @override
  ContentItem read(BinaryReader reader) {
    return ContentItem(
      id: reader.readString(),
      pair: reader.readString(),
      type: reader.readString(),
      text: reader.readString(),
      translation: reader.readString(),
      example: reader.readString(),
      seen: reader.readBool(),
      learned: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, ContentItem obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.pair);
    writer.writeString(obj.type);
    writer.writeString(obj.text);
    writer.writeString(obj.translation);
    writer.writeString(obj.example);
    writer.writeBool(obj.seen);
    writer.writeBool(obj.learned);
  }
}