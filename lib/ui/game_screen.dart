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
      backgroundColor: const Color(0xFF38353F), // Dark background matching image
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const HeaderWidget(),
            Container(
              height: 4,
              color: Colors.grey.withValues(alpha: 0.3), // Separator line under header
            ),
            Expanded(
              child: GestureDetector(
                onPanDown: (details) {
                   RenderBox box = context.findRenderObject() as RenderBox;
                   double width = box.size.width; 
                   double colWidth = width / 5;
                   int col = (details.localPosition.dx / colWidth).floor();
                   if (col >= 0 && col < 5) {
                     notifier.setMoveColumn(col);
                   }
                },
                onPanUpdate: (details) {
                   RenderBox box = context.findRenderObject() as RenderBox;
                   double width = box.size.width; 
                   double colWidth = width / 5;
                   int col = (details.localPosition.dx / colWidth).floor();
                   if (col >= 0 && col < 5) {
                     notifier.setMoveColumn(col);
                   }
                },
                onPanEnd: (details) {
                  notifier.dropTile();
                },
                onTap: () {
                  // We might not need onTap if onPanEnd handles all releases, 
                  // but keeping it ensures tap-to-drop works if pan isn't detected
                  notifier.dropTile();
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
          ],
        ),
      ),
    );
  }
}

