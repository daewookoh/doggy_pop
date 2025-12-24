import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import '../config/game_config.dart';
import '../models/bubble_type.dart';
import '../services/audio_service.dart';
import 'components/bubble.dart';
import 'components/bubble_grid.dart';
import 'components/shooter.dart';
import 'components/aim_line.dart';
import 'components/ceiling.dart';
import 'effects/pop_effect.dart';
import 'effects/combo_effect.dart';

enum GameState { playing, paused, win, lose }

class BubbleGame extends FlameGame with HasCollisionDetection {
  late BubbleGrid bubbleGrid;
  late Shooter shooter;
  late AimLine aimLine;
  late Ceiling ceiling;

  final AudioService _audio = AudioService();

  GameState gameState = GameState.playing;

  int score = 0;
  int remainingBubbles = GameConfig.defaultBubbleCount;
  int currentLevel = 1;

  // Callbacks for UI updates
  Function(int)? onScoreChanged;
  Function(int)? onBubblesChanged;
  Function(GameState)? onGameStateChanged;

  @override
  Color backgroundColor() => GameConfig.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize audio
    await _audio.init();
    await _audio.startBgm(AudioService.bgmGame);

    // Add ceiling
    ceiling = Ceiling();
    add(ceiling);

    // Add bubble grid
    bubbleGrid = BubbleGrid();
    add(bubbleGrid);

    // Add aim line
    aimLine = AimLine();
    add(aimLine);

    // Add shooter
    shooter = Shooter(
      onBubbleShot: _onBubbleShot,
    );
    add(shooter);

    // Initialize first level
    await loadLevel(1);
  }

  Future<void> loadLevel(int level) async {
    currentLevel = level;
    score = 0;
    remainingBubbles = GameConfig.defaultBubbleCount;
    gameState = GameState.playing;

    bubbleGrid.clearAll();
    bubbleGrid.generateLevel(level);

    shooter.loadNextBubble(bubbleGrid.getAvailableTypes());

    onScoreChanged?.call(score);
    onBubblesChanged?.call(remainingBubbles);
    onGameStateChanged?.call(gameState);
  }

  void _onBubbleShot(Bubble bubble) {
    if (gameState != GameState.playing) return;

    _audio.playShoot();

    remainingBubbles--;
    onBubblesChanged?.call(remainingBubbles);

    add(bubble);
  }

  void onBubbleAttached(Bubble bubble, int row, int col) {
    // Add bubble to grid
    bubbleGrid.attachBubble(bubble, row, col);

    // Check for matches
    final matchedBubbles = bubbleGrid.findMatches(row, col);

    if (matchedBubbles.length >= GameConfig.minMatchCount) {
      // Pop matched bubbles
      int popScore = _popBubbles(matchedBubbles);

      // Find and drop floating bubbles
      final floatingBubbles = bubbleGrid.findFloatingBubbles();
      int dropScore = _dropBubbles(floatingBubbles);

      // Calculate combo
      double multiplier = 1.0;
      if (matchedBubbles.length == 4) {
        multiplier = GameConfig.combo4Multiplier;
      } else if (matchedBubbles.length >= 5) {
        multiplier = GameConfig.combo5Multiplier;
      }

      score += ((popScore + dropScore) * multiplier).toInt();
      onScoreChanged?.call(score);

      // Check win condition
      if (bubbleGrid.isEmpty) {
        _onWin();
        return;
      }
    }

    // Check lose condition
    if (bubbleGrid.hasReachedBottom() || remainingBubbles <= 0) {
      if (!bubbleGrid.isEmpty) {
        _onLose();
        return;
      }
    }

    // Load next bubble
    shooter.loadNextBubble(bubbleGrid.getAvailableTypes());
  }

  int _popBubbles(List<Bubble> bubbles) {
    if (bubbles.isNotEmpty) {
      _audio.playPop();
    }

    for (final bubble in bubbles) {
      // Add pop effect
      add(PopEffect(
        position: bubble.position.clone(),
        color: bubble.type.color,
      ));
      add(BurstEffect(
        position: bubble.position.clone(),
        color: bubble.type.color,
      ));
      bubble.pop();
    }

    final popScore = bubbles.length * GameConfig.scorePerPop;

    // Show combo effect if 4+ matched
    if (bubbles.isNotEmpty) {
      final centerPos = bubbles.fold<Vector2>(
        Vector2.zero(),
        (sum, b) => sum + b.position,
      ) / bubbles.length.toDouble();

      if (bubbles.length >= 4) {
        _audio.playCombo();
        add(ComboEffect(
          position: centerPos,
          comboCount: bubbles.length,
          score: popScore,
        ));
      } else {
        add(ScorePopup(position: centerPos, score: popScore));
      }
    }

    return popScore;
  }

  int _dropBubbles(List<Bubble> bubbles) {
    if (bubbles.isNotEmpty) {
      _audio.playDrop();
    }

    for (final bubble in bubbles) {
      bubble.drop();
    }

    if (bubbles.isNotEmpty) {
      final centerPos = bubbles.fold<Vector2>(
        Vector2.zero(),
        (sum, b) => sum + b.position,
      ) / bubbles.length.toDouble();

      add(ScorePopup(
        position: centerPos,
        score: bubbles.length * GameConfig.scorePerDrop,
      ));
    }

    return bubbles.length * GameConfig.scorePerDrop;
  }

  void _onWin() {
    gameState = GameState.win;
    _audio.stopBgm();
    _audio.playWin();
    onGameStateChanged?.call(gameState);
  }

  void _onLose() {
    gameState = GameState.lose;
    _audio.stopBgm();
    _audio.playLose();
    onGameStateChanged?.call(gameState);
  }

  void pauseGame() {
    if (gameState == GameState.playing) {
      gameState = GameState.paused;
      pauseEngine();
      _audio.pauseBgm();
      onGameStateChanged?.call(gameState);
    }
  }

  void resumeGame() {
    if (gameState == GameState.paused) {
      gameState = GameState.playing;
      resumeEngine();
      _audio.resumeBgm();
      onGameStateChanged?.call(gameState);
    }
  }

  void restartLevel() {
    loadLevel(currentLevel);
  }

  int calculateStars() {
    final maxScore = bubbleGrid.initialBubbleCount * GameConfig.scorePerPop * 2;
    final percentage = score / maxScore;

    if (percentage >= GameConfig.star3Threshold) return 3;
    if (percentage >= GameConfig.star2Threshold) return 2;
    if (percentage >= GameConfig.star1Threshold) return 1;
    return 0;
  }

  // Handle pan start (called from game screen)
  void handlePanStart(Offset position) {
    if (gameState != GameState.playing) return;
    aimLine.startAiming(Vector2(position.dx, position.dy));
  }

  // Handle pan update (called from game screen)
  void handlePanUpdate(Offset position) {
    if (gameState != GameState.playing) return;
    aimLine.updateAim(Vector2(position.dx, position.dy));
  }

  // Handle pan end (called from game screen)
  void handlePanEnd() {
    if (gameState != GameState.playing) return;

    final angle = aimLine.getAngle();
    if (angle != null && angle < -0.1 && angle > -pi + 0.1) {
      shooter.shoot(angle);
    }
    aimLine.stopAiming();
  }

  // Handle tap (called from game screen)
  void handleTap(Offset position) {
    if (gameState != GameState.playing) return;

    final shooterPosition = shooter.position;

    // Only shoot if tapping above the shooter
    if (position.dy < shooterPosition.y - 50) {
      final angle = atan2(
        position.dy - shooterPosition.y,
        position.dx - shooterPosition.x,
      );

      // Limit angle to prevent shooting downward
      if (angle < -0.1 && angle > -pi + 0.1) {
        shooter.shoot(angle);
      }
    }
  }
}
