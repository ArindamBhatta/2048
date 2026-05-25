import 'dart:math';
import '../models/board_state.dart';
import '../models/tile.dart';
import 'drop_resolver.dart';
import 'merge_detector.dart';
import 'merge_executor.dart';
import 'gravity_resolver.dart';
import 'game_over_resolver.dart';

class GameEngine {
  final Random _random = Random();
  final List<int> _possibleValues = [2, 4, 8, 16];

  final DropResolver _dropResolver = DropResolver();
  final MergeDetector _mergeDetector = MergeDetector();
  final MergeExecutor _mergeExecutor = MergeExecutor();
  final GravityResolver _gravityResolver = GravityResolver();
  final GameOverResolver _gameOverResolver = GameOverResolver();

  int _getRandomValue() {
    return _possibleValues[_random.nextInt(_possibleValues.length)];
  }

  BoardState getInitialState() {
    final state = BoardState(
      columns: List.generate(BoardState.numColumns, (_) => []),
      nextTileValue: _getRandomValue(),
      score: 0,
      phase: GamePhase.control,
    );
    return spawnNextTile(state);
  }

  Tile _createSpawnTile(int column, int value) {
    return Tile(
      value: value,
      column: column,
      stackIndex: BoardState.spawnRow,
    );
  }

  BoardState spawnNextTile(BoardState state) {
    const spawnColumn = BoardState.numColumns ~/ 2;
    if (state.columns[spawnColumn].length >= BoardState.boundaryRow) {
      return state.copyWith(phase: GamePhase.gameOver);
    }

    return state.copyWith(
      activeTile: _createSpawnTile(spawnColumn, state.nextTileValue),
      nextTileValue: _getRandomValue(),
      phase: GamePhase.control,
    );
  }

  BoardState processDrop(BoardState state) {
    if (state.phase != GamePhase.control || state.activeTile == null) {
      return state;
    }

    BoardState currentState = _dropResolver.resolveDrop(state);

    bool stabilized = false;
    while (!stabilized) {
      final merges = _mergeDetector.detect(currentState);
      if (merges.isEmpty) {
        stabilized = true;
      } else {
        final mergeResult = _mergeExecutor.execute(currentState, merges);
        currentState = mergeResult.state;
        
        final gravityResult = _gravityResolver.resolve(currentState);
        currentState = gravityResult.state;
      }
    }

    currentState = _gameOverResolver.resolve(currentState);

    if (currentState.phase != GamePhase.gameOver) {
      currentState = spawnNextTile(currentState);
    }

    return currentState;
  }
}
