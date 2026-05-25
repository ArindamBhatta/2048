import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/game_screen.dart';

void main() {
  runApp(
    //riverpod is initialized here so that it can be used throughout the app
    const ProviderScope(
      child: CubeGame(),
    ),
  );
}

class CubeGame extends StatelessWidget {
  const CubeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
