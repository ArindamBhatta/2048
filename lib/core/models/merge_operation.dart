import 'tile.dart';

class MergeOperation {
  final Tile sourceA;
  final Tile sourceB;
  final int resultValue;
  final int targetColumn;
  final int targetStackIndex;

  MergeOperation({
    required this.sourceA,
    required this.sourceB,
    required this.resultValue,
    required this.targetColumn,
    required this.targetStackIndex,
  });
}
