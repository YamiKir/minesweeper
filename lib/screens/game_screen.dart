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
    _stopTimer();

    setState(() {
      seconds = 0;
      resetKey++;
      face = FaceState.happy;
    });

    _startTimer();
  }

  void _setFace(FaceState state) {
    setState(() => face = state);
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
            final maxMines = (tempRows * tempCols) - 1;
            if (tempMines > maxMines) tempMines = maxMines;

            return AlertDialog(
              title: const Text("Game Settings"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Rows: $tempRows"),
                    Slider(
                      value: tempRows.toDouble(),
                      min: 5,
                      max: 20,
                      divisions: 15,
                      onChanged: (v) {
                        setDialogState(() => tempRows = v.toInt());
                      },
                    ),

                    Text("Columns: $tempCols"),
                    Slider(
                      value: tempCols.toDouble(),
                      min: 5,
                      max: 20,
                      divisions: 15,
                      onChanged: (v) {
                        setDialogState(() => tempCols = v.toInt());
                      },
                    ),

                    Text("Mines: $tempMines"),
                    Slider(
                      value: tempMines.toDouble(),
                      min: 1,
                      max: (tempRows * tempCols - 1).toDouble(),
                      divisions: (tempRows * tempCols - 2).clamp(1, 400),
                      onChanged: (v) {
                        setDialogState(() => tempMines = v.toInt());
                      },
                    ),
                  ],
                ),
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
                      mines = tempMines;

                      seconds = 0;
                      resetKey++;
                      face = FaceState.happy;
                    });

                    _stopTimer();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth.clamp(320.0, 700.0);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: panelWidth,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple),
              ),
              child: Column(
                children: [
                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        seconds.toString().padLeft(3, '0'),
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      IconButton(
                        onPressed: _resetGame,
                        icon: Text(
                          _emoji(),
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),

                      // ✅ SETTINGS RESTORED
                      IconButton(
                        onPressed: _openSettings,
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: GameBoard(
                      resetKey: resetKey,
                      rows: rows,
                      cols: cols,
                      mineCount: mines,
                      onStart: () {
                        if (face == FaceState.happy) {
                          _setFace(FaceState.shocked);
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}