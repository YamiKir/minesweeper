import 'package:flutter/material.dart';
import '../models/tile.dart';
import 'dart:math';

class GameBoard extends StatefulWidget {
  final int resetKey;

  final int rows;
  final int cols;
  final int mineCount;

  final VoidCallback onLose;
  final VoidCallback onWin;
  final VoidCallback onStart;

  const GameBoard({
    super.key,
    required this.resetKey,
    required this.rows,
    required this.cols,
    required this.mineCount,
    required this.onLose,
    required this.onWin,
    required this.onStart,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<Tile>> board;
  bool gameOver = false;

  late int remainingSafe;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void didUpdateWidget(covariant GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.resetKey != widget.resetKey ||
        oldWidget.rows != widget.rows ||
        oldWidget.cols != widget.cols ||
        oldWidget.mineCount != widget.mineCount) {
      _initGame();
      setState(() {});
    }
  }

  // ---------------- INIT GAME ----------------
  void _initGame() {
    board = List.generate(
      widget.rows,
      (_) => List.generate(widget.cols, (_) => Tile()),
    );

    gameOver = false;

    final maxMines = widget.rows * widget.cols - 1;
    final safeMineCount = widget.mineCount.clamp(0, maxMines);

    remainingSafe = widget.rows * widget.cols - safeMineCount;

    _placeMines(safeMineCount);
    _calculateAdjacentMines();
  }

  void _placeMines(int mineCount) {
    final random = Random();
    int placed = 0;

    while (placed < mineCount) {
      int r = random.nextInt(widget.rows);
      int c = random.nextInt(widget.cols);

      if (!board[r][c].isMine) {
        board[r][c].isMine = true;
        placed++;
      }
    }
  }

  void _calculateAdjacentMines() {
    for (int r = 0; r < widget.rows; r++) {
      for (int c = 0; c < widget.cols; c++) {
        if (board[r][c].isMine) continue;

        int count = 0;

        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            int nr = r + dr;
            int nc = c + dc;

            if (nr >= 0 &&
                nr < widget.rows &&
                nc >= 0 &&
                nc < widget.cols &&
                board[nr][nc].isMine) {
              count++;
            }
          }
        }

        board[r][c].adjacentMines = count;
      }
    }
  }

  // ---------------- GAME LOGIC ----------------
  void _revealAllMines() {
    for (var row in board) {
      for (var tile in row) {
        if (tile.isMine) {
          tile.isRevealed = true;
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

          if (nr < 0 ||
              nr >= widget.rows ||
              nc < 0 ||
              nc >= widget.cols) continue;

          final tile = board[nr][nc];

          if (tile.isRevealed || tile.isMine || tile.isFlagged) continue;

          tile.isRevealed = true;
          remainingSafe--;

          if (tile.adjacentMines == 0) {
            stack.add([nr, nc]);
          }
        }
      }
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

  void _toggleFlag(int r, int c) {
    if (gameOver) return;

    setState(() {
      final tile = board[r][c];

      if (tile.isRevealed) return;

      tile.isFlagged = !tile.isFlagged;
    });
  }

  // ---------------- TILE UI ----------------
  Widget _buildTile(Tile tile, double size) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: tile.isRevealed
              ? (tile.isMine
                  ? Text('💣', style: TextStyle(fontSize: size))
                  : (tile.adjacentMines > 0
                      ? Text(
                          '${tile.adjacentMines}',
                          style: TextStyle(
                            fontSize: size * 0.7,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        )
                      : const SizedBox.shrink()))
              : tile.isFlagged
                  ? Text('🚧', style: TextStyle(fontSize: size * 0.8))
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  // ---------------- UI (NO CUT-OFF FIX) ----------------
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double padding = 16;

        final maxW = constraints.maxWidth - padding * 2;
        final maxH = constraints.maxHeight - padding * 2;

        // 🔥 TRUE SAFE FIT (no forced square, no overflow)
        final tileSize = min(
          maxW / widget.cols,
          maxH / widget.rows,
        );

        final gridWidth = tileSize * widget.cols;
        final gridHeight = tileSize * widget.rows;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(padding),
            child: FittedBox(
              fit: BoxFit.contain, // 🔥 prevents any cut-off
              child: SizedBox(
                width: gridWidth,
                height: gridHeight,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.cols,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: widget.rows * widget.cols,
                  itemBuilder: (context, index) {
                    final r = index ~/ widget.cols;
                    final c = index % widget.cols;

                    final tile = board[r][c];

                    return GestureDetector(
                      onTap: () => _revealTile(r, c),
                      onLongPress: () => _toggleFlag(r, c),

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        decoration: BoxDecoration(
                          color: tile.isRevealed
                              ? (tile.isMine
                                  ? Colors.redAccent
                                  : Colors.grey[300])
                              : (tile.isFlagged
                                  ? Colors.yellow[700]
                                  : Colors.deepPurple),
                          borderRadius: BorderRadius.circular(3),
                        ),

                        child: Center(
                          child: _buildTile(tile, tileSize * 0.55),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}