import 'package:flutter/material.dart';
import '../widgets/game_board.dart';

enum FaceState { happy, shocked, win, lose }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int seconds = 0;
  int resetKey = 0;

  FaceState face = FaceState.happy;

  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        seconds++;
      });

      return true;
    });
  }

  void _resetGame() {
    setState(() {
      seconds = 0;
      resetKey++;
      face = FaceState.happy;
    });
  }

  void _setFace(FaceState newFace) {
    setState(() {
      face = newFace;
    });
  }

  String _faceEmoji() {
    switch (face) {
      case FaceState.happy:
        return "🙂";
      case FaceState.shocked:
        return "😮";
      case FaceState.win:
        return "😎";
      case FaceState.lose:
        return "😵";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          const Spacer(),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.deepPurple),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              seconds.toString().padLeft(3, '0'),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),

                          // FACE BUTTON
                          IconButton(
                            onPressed: _resetGame,
                            icon: Text(
                              _faceEmoji(),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),

                          const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      GameBoard(
                        resetKey: resetKey,
                        onLose: () => _setFace(FaceState.lose),
                        onWin: () => _setFace(FaceState.win),
                        onStart: () {
                          if (face == FaceState.happy) {
                            _setFace(FaceState.shocked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}