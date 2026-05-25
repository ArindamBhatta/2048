import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Tile {
  final String id;
  final int value;
  final int column;
  final int row;

  Tile({
    String? id,
    required this.value,
    required this.column,
    required this.row,
  }) : id = id ?? _uuid.v4();

  Tile copyWith({
    String? id,
    int? value,
    int? column,
    int? row,
  }) {
    return Tile(
      id: id ?? this.id,
      value: value ?? this.value,
      column: column ?? this.column,
      row: row ?? this.row,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Tile(id: $id, value: $value, col: $column, row: $row)';
}
