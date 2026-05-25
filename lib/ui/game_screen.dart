import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/game_state_notifier.dart';
import 'components/game_board.dart';
import 'components/header.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ///watch - will rebuild the widget when the state changes
    final state = ref.watch(gameStateProvider);

    ///read - will not rebuild the widget when the state changes, used for callbacks
    final notifier = ref.read(gameStateProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF38353F),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            /// header widget which contains the score and other buttons
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
                  return GestureDetector(
                    ///drag event started
                    ///The moment finger first touches the widget.
                    onPanDown: (details) {
                      double width = constraints.maxWidth;

                      double colWidth = width / 5;
                      int col = (details.localPosition.dx / colWidth).floor();
                      if (col >= 0 && col < 5) {
                        notifier.setMoveColumn(col);
                      }
                    },

                    ///draggin joystick controls, updating positions, following finger, continuous column tracking
                    onPanUpdate: (details) {
                      double width = constraints.maxWidth;
                      double colWidth = width / 5;
                      int col = (details.localPosition.dx / colWidth).floor();
                      if (col >= 0 && col < 5) {
                        notifier.setMoveColumn(col);
                      }
                    },

                    ///dropping objects, finishing drag, inertia physics, snapping, confirming actions
                    onPanEnd: (details) {
                      notifier.dropTile();
                    },

                    ///Stack widget allows us to layer widgets on top of each other
                    child: Stack(
                      ///children are rendered in order, so the last widget in the list will be on top
                      children: [
                        const GameBoardWidget(),

                        /// game over overlay
                        if (state.gameOver)
                          Container(
                            color: Colors.black54,
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
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
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
