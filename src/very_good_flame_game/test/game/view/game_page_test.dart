import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_good_flame_game/game/game.dart';

import '../../helpers/helpers.dart';

void main() {
  group('GamePage', () {
    testWidgets('is routable', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpApp(
          Builder(
            builder: (context) => Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () => Navigator.of(context).push(GamePage.route()),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(FloatingActionButton));

        await tester.pump();
        await tester.pump();

        expect(find.byType(GamePage), findsOneWidget);
      });
    });

    testWidgets('renders GameView', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpApp(const GamePage());
        expect(find.byType(GameView), findsOneWidget);
      });
    });
  });

  group(
    'GameView',
    () {
      testWidgets('tapping the volume icon toggles the mute state',
          (tester) async {
        final game = TestGame();
        await tester.pumpApp(Material(child: GameView(game: game)));

        expect(find.byType(IconButton), findsOneWidget);
        expect(find.byIcon(Icons.volume_off), findsOneWidget);

        await tester.tap(find.byIcon(Icons.volume_off));
        await tester.pump();

        expect(find.byIcon(Icons.volume_up), findsOneWidget);
      });
    },
  );
}