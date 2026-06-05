import 'dart:math';
import '../models/board_state.dart';
import '../models/tile.dart';

/// The core game solver that computes deterministic physics-inspired transformations,
/// including gravity adjustments, landing predictions, and recursive tile merges.
///
/// **Why this is here:**
/// Separating the math/physics engine from the UI widgets and State Notifiers
/// ensures that the core 2048 game rules can be tested in isolation and are
/// independent of the rendering framework.
class GameEngine {
  final Random _random = Random();
  
  // Possible values that can spawn for new tiles.
  final List<int> _possibleValues = [2, 4, 8, 16];

  /// Helper to pick a random value for newly generated tiles.
  int _getRandomValue() {
    return _possibleValues[_random.nextInt(_possibleValues.length)];
  }

  /// Initializes the board state at the start of a new session.
  /// 
  /// **Why this is here:**
  /// When a game starts, we need a spawning active tile at the top-center
  /// of the virtual bucket, and a preview value for the next tile that will spawn.
  BoardState getInitialState() {
    const double spawnX = (BoardState.bucketWidth - BoardState.tileSize) / 2;
    const double spawnY = BoardState.bucketHeight - BoardState.tileSize;
    
    return BoardState(
      activeTile: Tile(
        value: _getRandomValue(),
        x: spawnX,
        y: spawnY,
      ),
      nextTileValue: _getRandomValue(),
      score: 0,
      gameOver: false,
    );
  }

  /// Spawns a new active tile at the top-center of the bucket.
  /// 
  /// **Why this is here:**
  /// If the top-center entry point is blocked (i.e. settled tiles are stacked up 
  /// past the warning/limit line), the spawn fails and a game-over is triggered.
  BoardState spawnNextTile(BoardState state) {
    const double spawnX = (BoardState.bucketWidth - BoardState.tileSize) / 2;
    const double spawnY = BoardState.bucketHeight - BoardState.tileSize;

    // Verify if there are any settled static tiles near the spawning area.
    final bool isOccupied = state.staticTiles.any((t) =>
        t.y + BoardState.tileSize > BoardState.warningLineY &&
        (t.x - spawnX).abs() < BoardState.tileSize);

    if (isOccupied) {
      // Trigger Game Over and clear the active tile.
      return state.copyWithUpdates(gameOver: true, isAnimating: false);
    }

    // Spawn a new active tile with the pre-rolled value, and roll a new upcoming value.
    return state.copyWithUpdates(
      nextTileValue: _getRandomValue(),
      isAnimating: false,
    ).copyWithActiveTile(Tile(
      value: state.nextTileValue,
      x: spawnX,
      y: spawnY,
    ));
  }

  /// Calculates the final Y position where a falling tile will land.
  /// 
  /// **Why this is here:**
  /// Since the game bucket allows continuous horizontal movement, we need to
  /// check which static tiles overlap horizontally with the dropped tile's X coordinate,
  /// and stack the dropped tile directly on top of the highest overlapping tile.
  double calculateDropLanding(BoardState state, double x) {
    double maxY = 0.0;
    for (final tile in state.staticTiles) {
      // Check if the falling tile (positioned at 'x') overlaps horizontally with this static tile.
      if ((x < tile.x + BoardState.tileSize) && (x + BoardState.tileSize > tile.x)) {
        // Find the top edge of the highest overlapping tile.
        if (tile.y + BoardState.tileSize > maxY) {
          maxY = tile.y + BoardState.tileSize;
        }
      }
    }
    return maxY;
  }

  /// Core logic for settling a dropped tile, applying gravity, and performing merges.
  /// 
  /// **Why this is here:**
  /// Dropping a tile isn't just about placing it. It can cause a chain reaction:
  /// 1. The tile lands and joins the list of static tiles.
  /// 2. It might merge with an adjacent tile of the same value.
  /// 3. If a merge happens, the remaining tiles might be left suspended in the air.
  ///    We must pull them down under gravity.
  /// 4. Pulling tiles down can trigger new merges, which triggers more gravity.
  /// This loop runs recursively until the board settles.
  BoardState settleActiveTile(BoardState state) {
    if (state.activeTile == null) return state;

    final active = state.activeTile!;
    final landingY = calculateDropLanding(state, active.x);
    
    // Create the landed tile at its final Y position.
    final landedTile = active.copyWith(y: landingY);
    
    // Append the newly landed tile to the static list.
    List<Tile> currentTiles = List.from(state.staticTiles)..add(landedTile);

    bool boardChanged = true;
    while (boardChanged) {
      boardChanged = false;

      // 1. Apply gravity to pull down any floating tiles.
      final gravityResult = _applyGravity(currentTiles);
      if (gravityResult.changed) {
        currentTiles = gravityResult.tiles;
        boardChanged = true;
      }

      // 2. Perform merges for any adjacent tiles with matching values.
      final mergeResult = _evaluateMerges(currentTiles);
      if (mergeResult.changed) {
        currentTiles = mergeResult.tiles;
        boardChanged = true;
      }
    }

    // Check game over: check if any static tile exceeds the warning limit line.
    bool isGameOver = currentTiles.any((t) => t.y + BoardState.tileSize > BoardState.warningLineY);

    // Calculate score based on the highest-value tile currently on the board.
    int maxScore = 0;
    for (var t in currentTiles) {
      if (t.value > maxScore) maxScore = t.value;
    }

    final nextState = state.copyWithUpdates(
      staticTiles: currentTiles,
      score: maxScore,
      gameOver: isGameOver,
      isAnimating: false,
    ).copyWithActiveTile(null);

    // Spawn the next tile if the game is still active.
    if (!isGameOver) {
       return spawnNextTile(nextState);
    }
    return nextState;
  }

  /// Pulls down all floating tiles so they rest on the floor or on other tiles.
  /// 
  /// **Why this is here:**
  /// When tiles merge, a gap can form below the top tiles. Gravity must be resolved
  /// starting from the bottom-most tiles upwards, recalculating their landing heights.
  _GravityResult _applyGravity(List<Tile> tiles) {
    bool changed = false;
    
    // Sort from bottom to top (ascending Y coordinate) to process lower tiles first.
    List<Tile> sorted = List.from(tiles)..sort((a, b) => a.y.compareTo(b.y));
    List<Tile> settled = [];

    for (final t in sorted) {
      double landingY = 0.0;
      for (final s in settled) {
        // Horizontal overlap check with already settled tiles.
        if ((t.x < s.x + BoardState.tileSize) && (t.x + BoardState.tileSize > s.x)) {
          if (s.y + BoardState.tileSize > landingY) {
            landingY = s.y + BoardState.tileSize;
          }
        }
      }

      // If the tile's current Y is different from its calculated landing Y, update it.
      if ((landingY - t.y).abs() > 0.01) {
        changed = true;
        settled.add(t.copyWith(y: landingY));
      } else {
        settled.add(t);
      }
    }
    
    return _GravityResult(settled, changed);
  }

  /// Scans the board for adjacent tiles with matching values and merges them.
  /// 
  /// **Why this is here:**
  /// In 2048, two matching tiles merge when they touch. Since our game supports
  /// continuous physics coordinates, "touching" means their bounding boxes overlap or touch
  /// within a small threshold (epsilon).
  _MergeResult _evaluateMerges(List<Tile> tiles) {
    List<Tile> currentTiles = List.from(tiles);
    const double epsilon = 2.0; // Distance tolerance threshold for touching tiles
    const double size = BoardState.tileSize;

    // Checks if t1 and t2 are adjacent and touching horizontally or vertically.
    bool areTouching(Tile t1, Tile t2) {
      final double xDist = (t1.x - t2.x).abs();
      final double yDist = (t1.y - t2.y).abs();

      // Horizontally overlapping and vertically touching.
      bool verticalTouch = xDist < size - epsilon && yDist <= size + epsilon;
      // Vertically overlapping and horizontally touching.
      bool horizontalTouch = yDist < size - epsilon && xDist <= size + epsilon;

      return verticalTouch || horizontalTouch;
    }

    // Search for a matching pair to merge.
    for (int i = 0; i < currentTiles.length; i++) {
      for (int j = i + 1; j < currentTiles.length; j++) {
        final t1 = currentTiles[i];
        final t2 = currentTiles[j];

        if (t1.value == t2.value && areTouching(t1, t2)) {
          // Keep the lower tile's position/identity to preserve smooth animation paths.
          final lowerTile = t1.y <= t2.y ? t1 : t2;
          
          // Remove both merged tiles from the list.
          currentTiles.removeAt(j); // Remove higher index first to avoid index shifting.
          currentTiles.removeAt(i);

          // Add the newly combined double-value tile.
          currentTiles.add(lowerTile.copyWith(value: t1.value * 2));
          return _MergeResult(currentTiles, true);
        }
      }
    }
    
    return _MergeResult(currentTiles, false);
  }
}

class _GravityResult {
  final List<Tile> tiles;
  final bool changed;
  _GravityResult(this.tiles, this.changed);
}

class _MergeResult {
  final List<Tile> tiles;
  final bool changed;
  _MergeResult(this.tiles, this.changed);
}
