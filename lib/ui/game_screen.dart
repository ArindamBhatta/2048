import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            const HeaderWidget(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                     // Calculate which column was dragged over based on width
                     RenderBox box = context.findRenderObject() as RenderBox;
                     double width = box.size.width - 32; // minus padding
                     double colWidth = width / 5;
                     int col = (details.localPosition.dx / colWidth).floor();
                     notifier.setMoveColumn(col);
                  },
                  onTap: () {
                    notifier.dropTile();
                  },
                  onVerticalDragEnd: (details) {
                    if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                      notifier.dropTile();
                    }
                  },
                  child: Stack(
                    children: [
                      const GameBoardWidget(),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
