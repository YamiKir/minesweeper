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

  // ---------------- INIT ----------------
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
      final r = random.nextInt(widget.rows);
      final c = random.nextInt(widget.cols);

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
            final nr = r + dr;
            final nc = c + dc;

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

      if (remainingSafe <= 0) {
        gameOver = true;
        widget.onWin();
      }
    });
  }

  void _revealAllMines() {
    for (final row in board) {
      for (final tile in row) {
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
          final nr = cr + dr;
          final nc = cc + dc;

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

  void _toggleFlag(int r, int c) {
    if (gameOver) return;

    setState(() {
      final tile = board[r][c];
      if (!tile.isRevealed) {
        tile.isFlagged = !tile.isFlagged;
      }
    });
  }

  // ---------------- TILE UI (FIXED NUMBERS) ----------------
  Widget _buildContent(Tile tile, double size) {
    const textStyleBase = TextStyle(
      fontWeight: FontWeight.bold,
    );

    if (!tile.isRevealed) {
      return tile.isFlagged
          ? Text("🚩", style: TextStyle(fontSize: size * 0.6))
          : const SizedBox.shrink();
    }

    if (tile.isMine) {
      return Text("💣", style: TextStyle(fontSize: size * 0.6));
    }

    if (tile.adjacentMines > 0) {
      return Text(
        "${tile.adjacentMines}",
        style: textStyleBase.copyWith(
          fontSize: size * 0.5,
          color: _numberColor(tile.adjacentMines),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Color _numberColor(int n) {
    switch (n) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.red;
      case 4:
        return Colors.deepPurple;
      case 5:
        return Colors.brown;
      case 6:
        return Colors.teal;
      case 7:
        return Colors.black;
      case 8:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  // ---------------- BUILD (SAFE RESIZE) ----------------
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 12.0;
        const spacing = 2.0;

        final maxW = max(50.0, constraints.maxWidth - padding * 2);
        final maxH = max(50.0, constraints.maxHeight - padding * 2);

        final tileSize = max(
          6.0,
          min(
            (maxW - ((widget.cols - 1) * spacing)) / widget.cols,
            (maxH - ((widget.rows - 1) * spacing)) / widget.rows,
          ),
        );

        final boardW =
            tileSize * widget.cols + (widget.cols - 1) * spacing;
        final boardH =
            tileSize * widget.rows + (widget.rows - 1) * spacing;

        return Center(
          child: SizedBox(
            width: boardW,
            height: boardH,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.cols,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
              ),
              itemCount: widget.rows * widget.cols,
              itemBuilder: (context, index) {
                final r = index ~/ widget.cols;
                final c = index % widget.cols;
                final tile = board[r][c];

                return GestureDetector(
                  onTap: () => _revealTile(r, c),
                  onLongPress: () => _toggleFlag(r, c),
                  child: Container(
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
                      child: _buildContent(tile, tileSize),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}