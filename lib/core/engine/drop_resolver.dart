import '../models/board_state.dart';
import '../models/tile.dart';

class DropResolver {
  BoardState resolveDrop(BoardState state) {
    if (state.activeTile == null) return state;

    final active = state.activeTile!;
    final column = active.column;
    
    // Add to the top of the column stack
    final stackIndex = state.columns[column].length;
    
    final landedTile = active.copyWith(stackIndex: stackIndex);
    
    final newColumns = List<List<Tile>>.from(state.columns);
    newColumns[column] = List<Tile>.from(newColumns[column])..add(landedTile);
    
    return state.clearActiveTile().copyWith(
      columns: newColumns,
      phase: GamePhase.resolving,
    );
  }
}
