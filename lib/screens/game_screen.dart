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

  bool _timerRunning = true;

  FaceState face = FaceState.happy;

  int rows = 9;
  int cols = 9;
  int mines = 10;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() async {
    _timerRunning = true;

    while (mounted && _timerRunning) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_timerRunning || !mounted) break;
      setState(() => seconds++);
    }
  }

  void _stopTimer() {
    _timerRunning = false;
  }

  void _resetGame() {
    setState(() {
      seconds = 0;
      resetKey++;
      face = FaceState.happy;
    });

    _startTimer();
  }

  void _setFace(FaceState f) {
    setState(() => face = f);
  }

  String _emoji() {
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

  // ---------------- SETTINGS ----------------
  void _openSettings() {
    int tempRows = rows;
    int tempCols = cols;
    int tempMines = mines;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final maxMines =
                (tempRows * tempCols * 0.35).floor().clamp(1, 999);

            // 🔥 CRITICAL FIX: clamp value BEFORE slider renders
            tempMines = tempMines.clamp(1, maxMines);

            return AlertDialog(
              title: const Text("Game Settings"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _slider(
                    label: "Rows",
                    value: tempRows.toDouble(),
                    min: 5,
                    max: 20,
                    onChanged: (v) {
                      setDialogState(() => tempRows = v.toInt());
                    },
                  ),
                  _slider(
                    label: "Cols",
                    value: tempCols.toDouble(),
                    min: 5,
                    max: 20,
                    onChanged: (v) {
                      setDialogState(() => tempCols = v.toInt());
                    },
                  ),

                  // ---------------- FIXED MINES SLIDER ----------------
                  Column(
                    children: [
                      Text("Mines: $tempMines"),
                      Slider(
                        value: tempMines.toDouble(),
                        min: 1,
                        max: maxMines.toDouble(),
                        divisions: (maxMines - 1).clamp(1, 200),
                        onChanged: (v) {
                          setDialogState(() {
                            tempMines = v.toInt().clamp(1, maxMines);
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      rows = tempRows;
                      cols = tempCols;

                      final maxMines =
                          (rows * cols * 0.35).floor().clamp(1, 999);

                      mines = tempMines.clamp(1, maxMines);

                      resetKey++;
                      seconds = 0;
                      face = FaceState.happy;
                    });

                    _startTimer();
                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
  }) {
    return Column(
      children: [
        Text("$label: ${value.toInt()}"),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: (max - min).toInt().clamp(1, 100),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          const Spacer(),

          Center(
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        seconds.toString().padLeft(3, '0'),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: _resetGame,
                        icon: Text(_emoji(),
                            style: const TextStyle(fontSize: 22)),
                      ),

                      IconButton(
                        onPressed: _openSettings,
                        icon: const Icon(Icons.settings, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  GameBoard(
                    resetKey: resetKey,
                    rows: rows,
                    cols: cols,
                    mineCount: mines,
                    onStart: () {
                      if (face == FaceState.happy) {
                        setState(() => face = FaceState.shocked);
                      }
                    },
                    onLose: () {
                      _stopTimer();
                      _setFace(FaceState.lose);
                    },
                    onWin: () {
                      _stopTimer();
                      _setFace(FaceState.win);
                    },
                  ),
                ],
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}