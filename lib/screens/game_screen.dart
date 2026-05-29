import 'package:flutter/material.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minesweeper"),
      ),
      body: const Center(
        child: GameBoard(),
      ),
    );
  }
}