import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board_state.dart';
import '../services/game_engine.dart';

/// Provider that exposes a single cached instance of [GameEngine].
/// Since [GameEngine] is stateless and performs pure mathematical operations,
/// caching it in a provider avoids unnecessary re-allocations.
final gameEngineProvider = Provider<GameEngine>((ref) => GameEngine());

/// Provider that exposes the current [BoardState] and allows widgets to listen for updates.
/// It couples the UI rebuild triggers to changes inside the [GameNotifier] state.
final gameStateProvider = NotifierProvider<GameNotifier, BoardState>(() {
  return GameNotifier();
});

/// The State Notifier responsible for translating user interactions (gestures, drag/drop)
/// into game state modifications, orchestrating UI animations and engine calculations.
class GameNotifier extends Notifier<BoardState> {
  late GameEngine _engine;

  @override
  BoardState build() {
    // Read the shared GameEngine instance to perform drop and settle calculations.
    _engine = ref.read(gameEngineProvider);
    // Initialize the game with a starting active tile and a preview tile.
    return _engine.getInitialState();
  }

  /// Resets the game board and scores back to the initial state.
  void resetGame() {
    state = _engine.getInitialState();
  }

  /// Updates the horizontal (X) position of the currently active/falling tile
  /// while the player is dragging their finger across the screen.
  /// 
  /// **Why this is here:**
  /// We need to update the active tile's coordinate in real time to give visual feedback
  /// of horizontal movement before dropping. Drag input is constrained within the
  /// boundaries of the virtual bucket.
  void setMoveX(double x) {
    // Prevent tile movement if the game is over, the tile is dropping, or an animation is running.
    if (state.gameOver || state.activeTile == null || state.isAnimating) return;

    // Constrain the X position so the tile cannot go outside the left or right walls of the bucket.
    const double maxMoveX = BoardState.bucketWidth - BoardState.tileSize;
    final double constrainedX = x.clamp(0.0, maxMoveX);

    // Mutate state with the updated horizontal coordinate.
    state = state.copyWithActiveTile(
      state.activeTile!.copyWith(x: constrainedX),
    );
  }

  /// Triggers the tile drop sequence when the player releases their finger.
  /// 
  /// **Why this is here:**
  /// 1. It calculates the final destination Y-coordinate using the GameEngine.
  /// 2. It sets `isAnimating = true` to block further user input during the drop.
  /// 3. It simulates the falling time using a delayed Future, allowing the UI's
  ///    [AnimatedPositioned] to execute the drop transition.
  /// 4. Once settled, it delegates to the engine to evaluate merges and apply gravity.
  Future<void> dropTile() async {
    if (state.gameOver || state.activeTile == null || state.isAnimating) return;

    // Lock user interaction during the drop and merge animations.
    state = state.copyWith(isAnimating: true);
    final active = state.activeTile!;
    
    // Calculate where this tile will land based on currently settled tiles below it.
    final landingY = _engine.calculateDropLanding(state, active.x);

    // Update active tile's Y-coordinate to trigger the slide down animation in the UI.
    state = state.copyWithActiveTile(active.copyWith(y: landingY));

    // Wait for the drop animation to finish (matching the AnimatedPositioned duration).
    await Future.delayed(const Duration(milliseconds: 150));

    // Settle the tile into the board, run physics (gravity & merges), and spawn the next tile.
    state = _engine.settleActiveTile(state);
  }
}
