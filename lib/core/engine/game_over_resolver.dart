import '../models/board_state.dart';

class GameOverResolver {
  BoardState resolve(BoardState state) {
    bool isGameOver = false;
    for (int col = 0; col < BoardState.numColumns; col++) {
      if (state.columns[col].length > BoardState.boundaryRow) {
        isGameOver = true;
        break;
      }
    }
    
    if (isGameOver) {
      return state.copyWith(phase: GamePhase.gameOver);
    }
    return state;
  }
}
