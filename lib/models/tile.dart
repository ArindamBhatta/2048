import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Tile {
  final String id;
  final int value;
  // Horizontal position in virtual bucket coordinates
  final double x;
  // Vertical position in virtual bucket coordinates (0.0 is bottom)
  final double y;

  Tile({
    String? id,
    required this.value,
    required this.x,
    required this.y,
  }) : id = id ?? _uuid.v4();

  Tile copyWith({
    String? id,
    int? value,
    double? x,
    double? y,
  }) {
    return Tile(
      id: id ?? this.id,
      value: value ?? this.value,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
