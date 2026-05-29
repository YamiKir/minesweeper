import 'package:flutter_test/flutter_test.dart';
import 'package:minesweeper/main.dart';

void main() {
  testWidgets('App starts and shows Minesweeper title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MinesweeperApp());

    expect(find.text('Minesweeper'), findsOneWidget);
  });
}