import 'dart:math';
import '../models/board_state.dart';
import '../models/tile.dart';

class GameEngine {
  final Random _random = Random();
  final List<int> _possibleValues = [2, 4, 8, 16];

  int _getRandomValue() {
    return _possibleValues[_random.nextInt(_possibleValues.length)];
  }

  /// Initialize the board with a fresh active tile and next tile preview.
  BoardState getInitialState() {
    return BoardState(
      activeTile: _createSpawnTile(BoardState.columns ~/ 2, _getRandomValue()),
      nextTileValue: _getRandomValue(),
      score: 0,
      gameOver: false,
    );
  }

  Tile _createSpawnTile(int column, int value) {
    return Tile(
      value: value,
      column: column,
      row: BoardState.spawnRow,
    );
  }

  /// Spawns a new active tile. If the spawn column is full, it's game over.
  BoardState spawnNextTile(BoardState state) {
    const spawnColumn = BoardState.columns ~/ 2;
    // Check if spawn column is already occupied at boundary
    if (state.staticTiles.any((t) => t.column == spawnColumn && t.row >= BoardState.boundaryRow)) {
      return state.copyWithUpdates(gameOver: true, isAnimating: false);
    }

    return state.copyWithUpdates(
      nextTileValue: _getRandomValue(),
      isAnimating: false,
    ).copyWithActiveTile(_createSpawnTile(spawnColumn, state.nextTileValue));
  }

  /// Calculates the landing row for a tile in a specific column.
  int calculateDropLanding(BoardState state, int column) {
    int maxRow = -1;
    for (final tile in state.staticTiles) {
      if (tile.column == column && tile.row > maxRow) {
        maxRow = tile.row;
      }
    }
    return maxRow + 1;
  }

  /// Core logic for settling a dropped tile. It calculates its landing spot,
  /// adds it to static tiles, and processes all chain reactions.
  BoardState settleActiveTile(BoardState state) {
    if (state.activeTile == null) return state;

    final active = state.activeTile!;
    final landingRow = calculateDropLanding(state, active.column);
    
    // Create the landed tile
    final landedTile = active.copyWith(row: landingRow);
    
    // Add to static tiles
    List<Tile> currentTiles = List.from(state.staticTiles)..add(landedTile);
    int currentScore = state.score;

    bool boardChanged = true;
    while (boardChanged) {
      boardChanged = false;

      // 1. Apply gravity to all tiles
      final gravityResult = _applyGravity(currentTiles);
      if (gravityResult.changed) {
        currentTiles = gravityResult.tiles;
        boardChanged = true;
      }

      // 2. Evaluate merges
      final mergeResult = _evaluateMerges(currentTiles, currentScore);
      if (mergeResult.changed) {
        currentTiles = mergeResult.tiles;
        currentScore = mergeResult.score;
        boardChanged = true;
      }
    }

    // Check game over
    bool isGameOver = currentTiles.any((t) => t.row >= BoardState.boundaryRow);

    final nextState = state.copyWithUpdates(
      staticTiles: currentTiles,
      score: currentScore,
      gameOver: isGameOver,
      isAnimating: false,
    ).copyWithActiveTile(null);

    if (!isGameOver) {
       // We'll let the GameStateNotifier spawn the next tile after animations,
       // but for purely logical flow, we could spawn it here.
       // Let's spawn it.
       return spawnNextTile(nextState);
    }
    return nextState;
  }

  _GravityResult _applyGravity(List<Tile> tiles) {
    bool changed = false;
    List<Tile> newTiles = [];
    
    // Group by column
    Map<int, List<Tile>> cols = {};
    for (int c = 0; c < BoardState.columns; c++) {
      cols[c] = [];
    }
    for (final t in tiles) {
      cols[t.column]!.add(t);
    }

    for (int c = 0; c < BoardState.columns; c++) {
      // Sort by row ascending (bottom to top)
      cols[c]!.sort((a, b) => a.row.compareTo(b.row));
      
      int expectedRow = 0;
      for (int i = 0; i < cols[c]!.length; i++) {
        final t = cols[c]![i];
        if (t.row != expectedRow) {
          changed = true;
          newTiles.add(t.copyWith(row: expectedRow));
        } else {
          newTiles.add(t);
        }
        expectedRow++;
      }
    }
    
    return _GravityResult(newTiles, changed);
  }

  _MergeResult _evaluateMerges(List<Tile> tiles, int score) {
    List<Tile> currentTiles = List.from(tiles);
    
    // Group by col and row for easy lookup
    Tile? getTileAt(int col, int row) {
      for (final t in currentTiles) {
        if (t.column == col && t.row == row) return t;
      }
      return null;
    }

    // We'll find ONE merge, do it, and return. The while loop in settleActiveTile will catch the rest.
    // This simplifies chain reaction logic.
    // Order of precedence: We should probably evaluate from bottom to top.
    for (int r = 0; r < BoardState.rows; r++) {
      for (int c = 0; c < BoardState.columns; c++) {
        final t = getTileAt(c, r);
        if (t == null) continue;

        // Check vertical merge (tile above this one)
        final tAbove = getTileAt(c, r + 1);
        if (tAbove != null && tAbove.value == t.value) {
          // Merge tAbove INTO t
          currentTiles.removeWhere((tile) => tile.id == t.id || tile.id == tAbove.id);
          currentTiles.add(t.copyWith(value: t.value * 2)); // keeps t's position
          return _MergeResult(currentTiles, score + (t.value * 2), true);
        }

        // Check horizontal merge (tile to the right)
        final tRight = getTileAt(c + 1, r);
        if (tRight != null && tRight.value == t.value) {
          // Merge tRight INTO t
          currentTiles.removeWhere((tile) => tile.id == t.id || tile.id == tRight.id);
          currentTiles.add(t.copyWith(value: t.value * 2));
          return _MergeResult(currentTiles, score + (t.value * 2), true);
        }
      }
    }
    
    return _MergeResult(currentTiles, score, false);
  }
}

class _GravityResult {
  final List<Tile> tiles;
  final bool changed;
  _GravityResult(this.tiles, this.changed);
}

class _MergeResult {
  final List<Tile> tiles;
  final int score;
  final bool changed;
  _MergeResult(this.tiles, this.score, this.changed);
}
