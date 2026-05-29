import '../models/tile.dart';

class BoardService {
  static List<List<Tile>> createBoard(
    int rows,
    int cols,
  ) {
    return List.generate(
      rows,
      (_) => List.generate(
        cols,
        (_) => Tile(),
      ),
    );
  }
}