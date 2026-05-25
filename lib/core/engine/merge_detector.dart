import '../models/board_state.dart';
import '../models/merge_operation.dart';

class MergeDetector {
  List<MergeOperation> detect(BoardState state) {
    List<MergeOperation> merges = [];
    final columns = state.columns;
    
    Set<String> mergedTileIds = {};

    for (int col = 0; col < BoardState.numColumns; col++) {
      for (int i = 0; i < columns[col].length; i++) {
        final currentTile = columns[col][i];
        if (mergedTileIds.contains(currentTile.id)) continue;

        // Check vertical merge
        if (i + 1 < columns[col].length) {
          final topTile = columns[col][i + 1];
          if (!mergedTileIds.contains(topTile.id) && currentTile.value == topTile.value) {
            merges.add(MergeOperation(
              sourceA: currentTile,
              sourceB: topTile,
              resultValue: currentTile.value * 2,
              targetColumn: col,
              targetStackIndex: i,
            ));
            mergedTileIds.add(currentTile.id);
            mergedTileIds.add(topTile.id);
            continue; 
          }
        }

        // Check horizontal merge
        if (col + 1 < BoardState.numColumns && i < columns[col + 1].length) {
          final rightTile = columns[col + 1][i];
          if (!mergedTileIds.contains(rightTile.id) && currentTile.value == rightTile.value) {
            merges.add(MergeOperation(
              sourceA: currentTile,
              sourceB: rightTile,
              resultValue: currentTile.value * 2,
              targetColumn: col,
              targetStackIndex: i,
            ));
            mergedTileIds.add(currentTile.id);
            mergedTileIds.add(rightTile.id);
          }
        }
      }
    }
    return merges;
  }
}
