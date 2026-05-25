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
        final colWidth = constraints.maxWidth / BoardState.columns;
        final rowHeight = constraints.maxHeight / BoardState.rows;
        // Make tiles square or slightly rectangular based on available space
        final tileSize = colWidth < rowHeight ? colWidth : rowHeight;
        
        // Ensure the grid fits in the center
        final boardWidth = tileSize * BoardState.columns;
        final boardHeight = tileSize * BoardState.rows;

        return Center(
          child: SizedBox(
            width: boardWidth,
            height: boardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Grid
                _buildGridBackground(tileSize),
                
                // Boundary Line
                Positioned(
                  top: (BoardState.rows - BoardState.boundaryRow) * tileSize, // Invert Y
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    color: Colors.redAccent,
                  ),
                ),

                // Static Tiles
                for (final tile in state.staticTiles)
                  Positioned(
                    left: tile.column * tileSize,
                    bottom: tile.row * tileSize, // Row 0 is at the bottom
                    width: tileSize,
                    height: tileSize,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TileWidget(
                        value: tile.value,
                        isStatic: true,
                      ),
                    ),
                  ),

                // Active Tile
                if (state.activeTile != null)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                    left: state.activeTile!.column * tileSize,
                    bottom: state.activeTile!.row * tileSize, // Spawns at spawnRow
                    width: tileSize,
                    height: tileSize,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
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

  Widget _buildGridBackground(double tileSize) {
    return Column(
      children: List.generate(
        BoardState.rows,
        (r) => Row(
          children: List.generate(
            BoardState.columns,
            (c) => Container(
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                color: Colors.grey.withValues(alpha: 0.05),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
