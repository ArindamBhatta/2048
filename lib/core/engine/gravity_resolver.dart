import '../models/board_state.dart';
import '../models/tile.dart';

class GravityResult {
  final BoardState state;
  final bool changed;
  GravityResult(this.state, this.changed);
}

class GravityResolver {
  GravityResult resolve(BoardState state) {
    bool changed = false;
    final newColumns = List<List<Tile>>.generate(BoardState.numColumns, (_) => []);

    for (int col = 0; col < BoardState.numColumns; col++) {
      final currentStack = state.columns[col];
      final newStack = <Tile>[];
      
      final sortedStack = List<Tile>.from(currentStack)..sort((a, b) => a.stackIndex.compareTo(b.stackIndex));
      
      for (int i = 0; i < sortedStack.length; i++) {
        final tile = sortedStack[i];
        if (tile.stackIndex != i) {
          newStack.add(tile.copyWith(stackIndex: i));
          changed = true;
        } else {
          newStack.add(tile);
        }
      }
      newColumns[col] = newStack;
    }

    if (changed) {
      return GravityResult(state.copyWith(columns: newColumns), true);
    }
    return GravityResult(state, false);
  }
}
