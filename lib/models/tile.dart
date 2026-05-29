class Tile {
  bool isMine;
  bool isRevealed;
  bool isFlagged;
  int adjacentMines;

  Tile({
    this.isMine = false,
    this.isRevealed = false,
    this.isFlagged = false,
    this.adjacentMines = 0,
  });
}