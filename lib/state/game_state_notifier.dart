import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board_state.dart';
import '../services/game_engine.dart';

final gameEngineProvider = Provider<GameEngine>((ref) => GameEngine());

final gameStateProvider = NotifierProvider<GameNotifier, BoardState>(() {
  return GameNotifier();
});

class GameNotifier extends Notifier<BoardState> {
  late GameEngine _engine;

  @override
  BoardState build() {
    _engine = ref.read(gameEngineProvider);
    return _engine.getInitialState(true);
  }

  void resetGame() {
    state = _engine.getInitialState(state.isGravityMode);
  }

  void toggleMode() {
    final nextMode = !state.isGravityMode;
    BoardState newState = state.copyWith(isGravityMode: nextMode);
    
    if (nextMode) {
      if (newState.activeTile == null && !newState.gameOver) {
        newState = _engine.spawnNextTile(newState);
      }
    } else {
      newState = newState.copyWithActiveTile(null);
    }
    
    state = newState;
  }

  void swipe(String direction) {
    if (state.gameOver || state.isGravityMode || state.isAnimating) return;
    state = _engine.swipe(state, direction);
  }

  void moveActiveTile(int delta) {
    if (state.gameOver || state.activeTile == null || state.isAnimating) return;

    final currentColumn = state.activeTile!.column;
    final newColumn = currentColumn + delta;

    if (newColumn >= 0 && newColumn < BoardState.columns) {
      state = state.copyWithActiveTile(
        state.activeTile!.copyWith(column: newColumn),
      );
    }
  }

  void setMoveColumn(int column) {
    if (state.gameOver || state.activeTile == null || state.isAnimating) return;
    if (column >= 0 && column < BoardState.columns) {
      state = state.copyWithActiveTile(
        state.activeTile!.copyWith(column: column),
      );
    }
  }

  Future<void> dropTile() async {
    if (state.gameOver || state.activeTile == null || state.isAnimating) return;

    state = state.copyWith(isAnimating: true);
    final active = state.activeTile!;
    final landingRow = _engine.calculateDropLanding(state, active.column);

    // Update state to animate the drop
    state = state.copyWithActiveTile(active.copyWith(row: landingRow));

    //
    await Future.delayed(const Duration(milliseconds: 100));

    state = _engine.settleActiveTile(state);
  }
}
