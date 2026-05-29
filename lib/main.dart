import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MinesweeperApp());
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}