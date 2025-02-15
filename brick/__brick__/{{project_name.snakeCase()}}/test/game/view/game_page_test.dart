// Copyright (c) {{current_year}}, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flame_audio/bgm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:{{project_name.snakeCase()}}/game/game.dart';
import 'package:{{project_name.snakeCase()}}/loading/cubit/cubit.dart';

import '../../helpers/helpers.dart';

class _FakeAssetSource extends Fake implements AssetSource {}

class _MockAudioCubit extends MockCubit<AudioState> implements AudioCubit {}

class _MockAudioPlayer extends Mock implements AudioPlayer {}

class _MockBgm extends Mock implements Bgm {}

void main() {
  group('GamePage', () {
    late PreloadCubit preloadCubit;

    setUp(() {
      preloadCubit = MockPreloadCubit();
      when(() => preloadCubit.audio).thenReturn(AudioCache());
    });

    setUpAll(() {
      registerFallbackValue(_FakeAssetSource());
    });

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
          preloadCubit: preloadCubit,
        );

        await tester.tap(find.byType(FloatingActionButton));

        await tester.pump();
        await tester.pump();

        expect(find.byType(GamePage), findsOneWidget);
      });
    });

    testWidgets('renders GameView', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpApp(
          const GamePage(),
          preloadCubit: preloadCubit,
        );
        expect(find.byType(GameView), findsOneWidget);
      });
    });
  });

  group('GameView', () {
    late AudioCubit audioCubit;

    setUp(() {
      audioCubit = _MockAudioCubit();
      when(() => audioCubit.state).thenReturn(AudioState());

      final effectPlayer = _MockAudioPlayer();
      when(() => audioCubit.effectPlayer).thenReturn(effectPlayer);
      final bgm = _MockBgm();
      when(() => audioCubit.bgm).thenReturn(bgm);
      when(() => bgm.play(any())).thenAnswer((_) async {});
      when(bgm.pause).thenAnswer((_) async {});
    });

    testWidgets('toggles mute button correctly', (tester) async {
      final controller = StreamController<AudioState>();
      whenListen(audioCubit, controller.stream, initialState: AudioState());

      final game = TestGame();
      await tester.pumpApp(
        BlocProvider.value(
          value: audioCubit,
          child: Material(child: GameView(game: game)),
        ),
      );

      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      controller.add(AudioState(volume: 0));
      await tester.pump();

      expect(find.byIcon(Icons.volume_off), findsOneWidget);

      controller.add(AudioState());
      await tester.pump();

      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('calls correct method based on state', (tester) async {
      final controller = StreamController<AudioState>();
      when(audioCubit.toggleVolume).thenAnswer((_) async {});
      whenListen(audioCubit, controller.stream, initialState: AudioState());

      final game = TestGame();
      await tester.pumpApp(
        BlocProvider.value(
          value: audioCubit,
          child: Material(child: GameView(game: game)),
        ),
      );

      await tester.tap(find.byIcon(Icons.volume_up));
      controller.add(AudioState(volume: 0));
      await tester.pump();
      verify(audioCubit.toggleVolume).called(1);

      await tester.tap(find.byIcon(Icons.volume_off));
      controller.add(AudioState());
      await tester.pump();
      verify(audioCubit.toggleVolume).called(1);
    });
  });
}
