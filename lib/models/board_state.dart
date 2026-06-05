import 'tile.dart';

class BoardState {
  final List<Tile> staticTiles;
  final Tile? activeTile;
  final int nextTileValue;
  final bool gameOver;
  final int score;
  final bool isAnimating;

  // Virtual Coordinate Constants
  static const double bucketWidth = 400.0;
  static const double bucketHeight = 600.0;
  static const double tileSize = 50.0;
  static const double warningLineY = 500.0;

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
