import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/game_state_notifier.dart';

class HeaderWidget extends ConsumerWidget {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);

    return Container(
      color: const Color(0xFF45414C), // Slightly different shade for header area
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  // close button placeholder
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: state.isGravityMode ? Colors.white24 : Colors.blueAccent.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    state.isGravityMode ? Icons.settings : Icons.grid_on, 
                    color: Colors.white
                  ),
                  onPressed: () {
                    ref.read(gameStateProvider.notifier).toggleMode();
                  },
                  tooltip: state.isGravityMode ? 'Switch to Classic Mode' : 'Switch to Gravity Mode',
                ),
              ),
            ],
          ),
          Text(
            '${state.score}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

