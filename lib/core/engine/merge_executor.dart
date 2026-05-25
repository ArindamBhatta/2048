import '../models/board_state.dart';
import '../models/tile.dart';
import '../models/merge_operation.dart';

class MergeResult {
  final BoardState state;
  final bool changed;
  MergeResult(this.state, this.changed);
}

class MergeExecutor {
  MergeResult execute(BoardState state, List<MergeOperation> merges) {
    if (merges.isEmpty) return MergeResult(state, false);

    final newColumns = state.columns.map((c) => List<Tile>.from(c)).toList();
    int additionalScore = 0;

    for (final merge in merges) {
      newColumns[merge.sourceA.column].removeWhere((t) => t.id == merge.sourceA.id);
      newColumns[merge.sourceB.column].removeWhere((t) => t.id == merge.sourceB.id);

      final newTile = Tile(
        value: merge.resultValue,
        column: merge.targetColumn,
        stackIndex: merge.targetStackIndex,
      );
      
      newColumns[merge.targetColumn].add(newTile);
      newColumns[merge.targetColumn].sort((a, b) => a.stackIndex.compareTo(b.stackIndex));

      additionalScore += merge.resultValue;
    }

    return MergeResult(
      state.copyWith(
        columns: newColumns,
        score: state.score + additionalScore,
      ),
      true,
    );
  }
}
