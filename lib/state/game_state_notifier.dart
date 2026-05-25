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
    return _engine.getInitialState();
  }

  void resetGame() {
    state = _engine.getInitialState();
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

  void dropTile() {
    if (state.gameOver || state.activeTile == null || state.isAnimating) return;

    // Set animating flag so we don't process inputs during logic
    // We could add delays here for visual effect, but for now we settle instantly.
    // A more advanced version would use async/await and Future.delayed.
    state = _engine.settleActiveTile(state);
  }
}
