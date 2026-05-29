import 'package:flutter/material.dart';
import '../models/tile.dart';
import 'dart:math';

class GameBoard extends StatefulWidget {
  final int resetKey;

  final VoidCallback onLose;
  final VoidCallback onWin;
  final VoidCallback onStart;

  const GameBoard({
    super.key,
    required this.resetKey,
    required this.onLose,
    required this.onWin,
    required this.onStart,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  static const int rows = 9;
  static const int cols = 9;

  late List<List<Tile>> board;
  bool gameOver = false;

  int remainingSafe = rows * cols - 10;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void didUpdateWidget(covariant GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.resetKey != widget.resetKey) {
      _initGame();
      gameOver = false;
      remainingSafe = rows * cols - 10;
      setState(() {});
    }
  }

  void _initGame() {
    board = List.generate(
      rows,
      (_) => List.generate(cols, (_) => Tile()),
    );

    _placeMines(10);
    _calculateAdjacentMines();
  }

  void _placeMines(int mineCount) {
    final random = Random();
    int placed = 0;

    while (placed < mineCount) {
      int r = random.nextInt(rows);
      int c = random.nextInt(cols);

      if (!board[r][c].isMine) {
        board[r][c].isMine = true;
        placed++;
      }
    }
  }

  void _calculateAdjacentMines() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (board[r][c].isMine) continue;

        int count = 0;

        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            int nr = r + dr;
            int nc = c + dc;

            if (nr >= 0 &&
                nr < rows &&
                nc >= 0 &&
                nc < cols &&
                board[nr][nc].isMine) {
              count++;
            }
          }
        }

        board[r][c].adjacentMines = count;
      }
    }
  }

  void _revealAllMines() {
    for (var row in board) {
      for (var tile in row) {
        if (tile.isMine) {
          tile.isRevealed = true;
        }
      }
    }
  }

  void _floodFill(int r, int c) {
    final stack = <List<int>>[];
    stack.add([r, c]);

    while (stack.isNotEmpty) {
      final cur = stack.removeLast();
      final cr = cur[0];
      final cc = cur[1];

      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          int nr = cr + dr;
          int nc = cc + dc;

          if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;

          final tile = board[nr][nc];

          if (tile.isRevealed || tile.isMine) continue;

          tile.isRevealed = true;
          remainingSafe--;

          if (tile.adjacentMines == 0) {
            stack.add([nr, nc]);
          }
        }
      }
    }
  }

  void _checkWin() {
    if (remainingSafe <= 0 && !gameOver) {
      gameOver = true;
      widget.onWin();
    }
  }

  void _revealTile(int r, int c) {
    if (gameOver) return;

    widget.onStart();

    setState(() {
      final tile = board[r][c];

      if (tile.isRevealed || tile.isFlagged) return;

      tile.isRevealed = true;

      if (tile.isMine) {
        gameOver = true;
        _revealAllMines();
        widget.onLose();
        return;
      }

      remainingSafe--;

      if (tile.adjacentMines == 0) {
        _floodFill(r, c);
      }

      _checkWin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 320,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: rows * cols,
        itemBuilder: (context, index) {
          final r = index ~/ cols;
          final c = index % cols;

          final tile = board[r][c];

          return GestureDetector(
            onTap: () => _revealTile(r, c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: tile.isRevealed
                    ? (tile.isMine
                        ? Colors.redAccent
                        : Colors.grey[300])
                    : Colors.deepPurple,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: tile.isRevealed
                    ? (tile.isMine
                        ? const Text('💣', style: TextStyle(fontSize: 18))
                        : (tile.adjacentMines > 0
                            ? Text(
                                '${tile.adjacentMines}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              )
                            : const SizedBox.shrink()))
                    : const SizedBox.shrink(),
              ),
            ),
          );
        },
      ),
    );
  }
}