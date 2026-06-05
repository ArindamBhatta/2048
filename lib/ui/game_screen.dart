import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/board_state.dart';
import '../state/game_state_notifier.dart';
import 'components/game_board.dart';
import 'components/header.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final notifier = ref.read(gameStateProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF38353F),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// header widget which contains the score and reset button
            const HeaderWidget(),

            /// Separator line under header
            Container(
              height: 4,
              color: Colors.grey.withValues(alpha: 0.3),
            ),

            /// game board widget
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate the scale and positioning of the board
                  final double scaleX = constraints.maxWidth / BoardState.bucketWidth;
                  final double scaleY = constraints.maxHeight / BoardState.bucketHeight;
                  final double scale = scaleX < scaleY ? scaleX : scaleY;

                  final double boardWidth = BoardState.bucketWidth * scale;
                  final double boardLeft = (constraints.maxWidth - boardWidth) / 2;

                  void handleDragUpdate(Offset localPosition) {
                    final double touchXOnBoard = localPosition.dx - boardLeft;
                    final double virtualX = (touchXOnBoard / boardWidth) * BoardState.bucketWidth;
                    // Center the tile under the user's finger
                    final double centeredX = virtualX - BoardState.tileSize / 2;
                    notifier.setMoveX(centeredX);
                  }

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: (details) {
                      handleDragUpdate(details.localPosition);
                    },
                    onPanUpdate: (details) {
                      handleDragUpdate(details.localPosition);
                    },
                    onPanEnd: (details) {
                      notifier.dropTile();
                    },
                    child: Stack(
                      children: [
                        const GameBoardWidget(),

                        /// game over overlay
                        if (state.gameOver)
                          Container(
                            color: Colors.black.withValues(alpha: 0.75),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'GAME OVER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Max Score Achieved: ${state.score}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF65D2E9),
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () => notifier.resetGame(),
                                    child: const Text('Play Again'),
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
