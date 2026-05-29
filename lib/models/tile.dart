class Tile {
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int neighboringMines;

  Tile({
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.neighboringMines = 0,
  });
}