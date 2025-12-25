import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../game/bubble_game.dart';
import '../services/ad_service.dart';
import '../utils/hex_grid_utils.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late BubbleGame game;
  final AdService _adService = AdService();
  int score = 0;
  int remainingBubbles = 30;
  bool isPaused = false;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
    _loadBannerAd();
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

  void _loadInterstitialAd() {
    _adService.loadInterstitialAd();
  }

  void _loadBannerAd() {
    _adService.loadBannerAd(
      onLoaded: () {
        setState(() => _isBannerAdLoaded = true);
      },
      onFailed: (error) {
        setState(() => _isBannerAdLoaded = false);
      },
    );
  }

  @override
  void dispose() {
    _adService.disposeBannerAd();
    super.dispose();
  }

  void _showResultScreen(bool isWin) {
    void navigateToResult() {
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

    // 게임 횟수 체크 후 3회마다 전면 광고 표시
    final shouldShowAd = _adService.incrementGameCountAndCheckAd();

    if (shouldShowAd && _adService.isInterstitialAdLoaded) {
      _adService.showInterstitialAd(
        onAdDismissed: navigateToResult,
        onAdFailed: navigateToResult,
      );
    } else {
      navigateToResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set SafeArea top padding for grid positioning
    final safeAreaTop = MediaQuery.of(context).padding.top;
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate shooter Y position (above banner ad and safe area bottom)
    // Banner ad height is approximately 50, plus some padding
    const bannerHeight = 60.0;
    const shooterPadding = 80.0; // Distance from bottom
    HexGridUtils.shooterY = screenHeight - safeAreaBottom - bannerHeight - shooterPadding;
    HexGridUtils.safeAreaTop = safeAreaTop;

    return Scaffold(
      body: Column(
        children: [
          // Game area (expands to fill available space above banner)
          Expanded(
            child: Stack(
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
          ),

          // Banner ad at bottom
          _buildAdBanner(),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    if (_isBannerAdLoaded && _adService.bannerAd != null) {
      return Container(
        color: const Color(0xFFE8F4FC),
        width: double.infinity,
        height: _adService.bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _adService.bannerAd!),
      );
    }
    // 광고가 로드되지 않아도 공간 확보 (레이아웃 일관성)
    return const SizedBox(height: 50);
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
                color: Colors.white.withAlpha((255 * 0.8).round()),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7AC5F5).withAlpha((255 * 0.3).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isPaused ? Icons.play_arrow : Icons.pause,
                color: const Color(0xFF7A9BB8),
              ),
            ),
          ),

          // Level indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.8).round()),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7AC5F5).withAlpha((255 * 0.3).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Level ${widget.level}',
              style: const TextStyle(
                color: Color(0xFF5A5A7A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Bubble counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.8).round()),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7AC5F5).withAlpha((255 * 0.3).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF7AC5F5),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'x$remainingBubbles',
                  style: const TextStyle(
                    color: Color(0xFF5A5A7A),
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
      color: Colors.black.withAlpha((255 * 0.5).round()),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7AC5F5).withAlpha((255 * 0.3).round()),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A5A7A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF7A9BB8),
                ),
              ),
              const SizedBox(height: 24),
              _buildPauseButton(
                'Resume',
                const Color(0xFF7CE595),
                _togglePause,
              ),
              const SizedBox(height: 12),
              _buildPauseButton(
                'Restart',
                const Color(0xFFFFD580),
                _restartGame,
              ),
              const SizedBox(height: 12),
              _buildPauseButton(
                'Home',
                const Color(0xFFFF9AAE),
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
