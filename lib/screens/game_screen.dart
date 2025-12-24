import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../game/bubble_game.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BubbleGame game;
  int score = 0;
  int remainingBubbles = 30;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    game = BubbleGame();
    game.onScoreChanged = (newScore) {
      setState(() => score = newScore);
    };
    game.onBubblesChanged = (bubbles) {
      setState(() => remainingBubbles = bubbles);
    };
    game.onGameStateChanged = (state) {
      if (state == GameState.win || state == GameState.lose) {
        _showResultScreen(state == GameState.win);
      } else if (state == GameState.paused) {
        setState(() => isPaused = true);
      } else {
        setState(() => isPaused = false);
      }
    };
  }

  void _showResultScreen(bool isWin) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          level: widget.level,
          score: score,
          stars: game.calculateStars(),
          isWin: isWin,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game with gesture detection
          GestureDetector(
            onPanStart: (details) => game.handlePanStart(details.localPosition),
            onPanUpdate: (details) => game.handlePanUpdate(details.localPosition),
            onPanEnd: (_) => game.handlePanEnd(),
            onTapUp: (details) => game.handleTap(details.localPosition),
            child: GameWidget(game: game),
          ),

          // HUD
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
              ],
            ),
          ),

          // Pause overlay
          if (isPaused) _buildPauseOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pause button
          GestureDetector(
            onTap: _togglePause,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((255 * 0.3).round()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
            ),
          ),

          // Level indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((255 * 0.3).round()),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Level ${widget.level}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Bubble counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((255 * 0.3).round()),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3498DB),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'x$remainingBubbles',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Container(
      color: Colors.black.withAlpha((255 * 0.7).round()),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a2e),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha((255 * 0.1).round()),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              _buildPauseButton(
                'Resume',
                const Color(0xFF2ECC71),
                _togglePause,
              ),
              const SizedBox(height: 12),
              _buildPauseButton(
                'Restart',
                const Color(0xFFF1C40F),
                _restartGame,
              ),
              const SizedBox(height: 12),
              _buildPauseButton(
                'Home',
                const Color(0xFFE74C3C),
                _goHome,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _togglePause() {
    if (isPaused) {
      game.resumeGame();
    } else {
      game.pauseGame();
    }
  }

  void _restartGame() {
    game.restartLevel();
    setState(() => isPaused = false);
  }

  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
