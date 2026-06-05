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
        // Calculate the scale factor to fit the 400x600 virtual board into the constraints
        final double scaleX = constraints.maxWidth / BoardState.bucketWidth;
        final double scaleY = constraints.maxHeight / BoardState.bucketHeight;
        final double scale = scaleX < scaleY ? scaleX : scaleY;

        final double boardWidth = BoardState.bucketWidth * scale;
        final double boardHeight = BoardState.bucketHeight * scale;
        final double scaledTileSize = BoardState.tileSize * scale;

        return Center(
          child: Container(
            width: boardWidth,
            height: boardHeight,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.0),
              border: Border(
                left: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 3.0),
                right: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 3.0),
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 4.0),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ---- Vertical Guide Line for Active Tile ----
                if (state.activeTile != null)
                  Positioned(
                    left: (state.activeTile!.x + BoardState.tileSize / 2) * scale - 1.0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),

                // ---- Warning/Game Over Line ----
                Positioned(
                  bottom: BoardState.warningLineY * scale,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Positioned(
                  bottom: BoardState.warningLineY * scale + 4,
                  left: 8,
                  child: Text(
                    'WARNING LIMIT',
                    style: TextStyle(
                      color: Colors.redAccent.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                // ---- Static Tiles ----
                for (final tile in state.staticTiles)
                  AnimatedPositioned(
                    key: ValueKey(tile.id),
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    left: tile.x * scale,
                    bottom: tile.y * scale,
                    width: scaledTileSize,
                    height: scaledTileSize,
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: TileWidget(
                        value: tile.value,
                        isStatic: true,
                      ),
                    ),
                  ),

                // ---- Active Tile (spawns at the top, drops down) ----
                if (state.activeTile != null)
                  AnimatedPositioned(
                    key: ValueKey(state.activeTile!.id),
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    left: state.activeTile!.x * scale,
                    bottom: state.activeTile!.y * scale,
                    width: scaledTileSize,
                    height: scaledTileSize,
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
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
