import 'tile.dart';

enum GamePhase {
  control,
  resolving,
  gameOver
}

class BoardState {
  final List<List<Tile>> columns;
  final Tile? activeTile;
  final int nextTileValue;
  final int score;
  final GamePhase phase;

  static const int numColumns = 5;
  static const int numRows = 8;
  static const int spawnRow = 7;
  static const int boundaryRow = 6;

  BoardState({
    required this.columns,
    this.activeTile,
    this.nextTileValue = 2,
    this.score = 0,
    this.phase = GamePhase.control,
  });

  BoardState copyWith({
    List<List<Tile>>? columns,
    Tile? activeTile,
    int? nextTileValue,
    int? score,
    GamePhase? phase,
  }) {
    // If activeTile needs to be explicitly set to null, copyWith can't do it easily without a wrapper.
    // Instead, we use clearActiveTile for that.
    return BoardState(
      columns: columns ?? this.columns,
      activeTile: activeTile ?? this.activeTile,
      nextTileValue: nextTileValue ?? this.nextTileValue,
      score: score ?? this.score,
      phase: phase ?? this.phase,
    );
  }

  BoardState clearActiveTile() {
    return BoardState(
      columns: columns,
      activeTile: null,
      nextTileValue: nextTileValue,
      score: score,
      phase: phase,
    );
  }
}
