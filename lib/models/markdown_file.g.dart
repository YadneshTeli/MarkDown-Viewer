// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'markdown_file.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarkdownFileAdapter extends TypeAdapter<MarkdownFile> {
  @override
  final int typeId = 0;

  @override
  MarkdownFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarkdownFile(
      name: fields[0] as String,
      path: fields[1] as String,
      size: fields[2] as int,
      content: fields[3] as String,
      lastOpened: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MarkdownFile obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.lastOpened);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkdownFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
