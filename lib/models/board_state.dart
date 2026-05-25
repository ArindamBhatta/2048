import 'tile.dart';

class BoardState {
  final List<Tile> staticTiles;
  final Tile? activeTile;
  final int nextTileValue;
  final bool gameOver;
  final int score;
  final bool isAnimating;

  static const int columns = 5;
  static const int rows = 8;
  static const int spawnRow = 7;
  static const int boundaryRow = 6;

  BoardState({
    this.staticTiles = const [],
    this.activeTile,
    this.nextTileValue = 2,
    this.gameOver = false,
    this.score = 0,
    this.isAnimating = false,
  });

  BoardState copyWith({
    List<Tile>? staticTiles,
    Tile? activeTile,
    int? nextTileValue,
    bool? gameOver,
    int? score,
    bool? isAnimating,
  }) {
    return BoardState(
      staticTiles: staticTiles ?? this.staticTiles,
      activeTile: activeTile ?? this.activeTile,
      nextTileValue: nextTileValue ?? this.nextTileValue,
      gameOver: gameOver ?? this.gameOver,
      score: score ?? this.score,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }

  BoardState copyWithActiveTile(Tile? newActiveTile) {
    return BoardState(
      staticTiles: staticTiles,
      activeTile: newActiveTile,
      nextTileValue: nextTileValue,
      gameOver: gameOver,
      score: score,
      isAnimating: isAnimating,
    );
  }

  BoardState copyWithUpdates({
    List<Tile>? staticTiles,
    int? nextTileValue,
    bool? gameOver,
    int? score,
    bool? isAnimating,
  }) {
     return BoardState(
      staticTiles: staticTiles ?? this.staticTiles,
      activeTile: activeTile,
      nextTileValue: nextTileValue ?? this.nextTileValue,
      gameOver: gameOver ?? this.gameOver,
      score: score ?? this.score,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}
