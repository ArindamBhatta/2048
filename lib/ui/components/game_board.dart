import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/board_state.dart';
import '../../state/game_state_notifier.dart';
import 'tile_widget.dart';

class GameBoardWidget extends ConsumerWidget {
  const GameBoardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double colWidth = constraints.maxWidth / BoardState.columns;
        final double rowHeight = constraints.maxHeight / BoardState.rows;

        // Make tiles square or slightly rectangular based on available space
        final tileSize = colWidth < rowHeight ? colWidth : rowHeight;

        // Ensure the grid fits in the center
        final double boardWidth = tileSize * BoardState.columns;

        final double boardHeight = tileSize * BoardState.rows;

        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ---- Grid Background ----
                for (int r = 0; r < BoardState.rows; r++)
                  for (int c = 0; c < BoardState.columns; c++)
                    Positioned(
                      left: c * tileSize,
                      bottom: r * tileSize,
                      width: tileSize,
                      height: tileSize,
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),

                // ------ Highlight active column show to the user how it's drop-----
                if (state.activeTile != null)
                  Positioned(
                    left: state.activeTile!.column * tileSize,
                    top: 0,
                    bottom: 0,
                    width: tileSize,
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.03),
                    ),
                  ),

                // ---- Boundary Line show the game over line ---
                if (state.isGravityMode)
                  Positioned(
                    top: (BoardState.rows - BoardState.boundaryRow) * tileSize,
                    left: 0,
                    right: 0,
                    child: Row(
                      children: List.generate(
                        15,
                        (index) => Expanded(
                          child: Container(
                            height: 2,
                            color: index % 2 == 0
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),

                /// Static Tiles -> tiles that are already placed
                for (final tile in state.staticTiles)
                  AnimatedPositioned(
                    key: ValueKey(tile.id),
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    left: tile.column * tileSize,
                    bottom: tile.row * tileSize, // Row 0 is at the bottom
                    width: tileSize,
                    height: tileSize,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: TileWidget(
                        value: tile.value,
                        isStatic: true,
                      ),
                    ),
                  ),

                // Active Tile are those tile which come from top
                if (state.activeTile != null)
                  AnimatedPositioned(
                    key: ValueKey(state.activeTile!.id),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    left: state.activeTile!.column * tileSize,
                    bottom: state.activeTile!.row * tileSize,
                    width: tileSize,
                    height: tileSize,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: TileWidget(
                        value: state.activeTile!.value,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
