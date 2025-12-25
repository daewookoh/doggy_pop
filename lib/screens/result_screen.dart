import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/game_services_manager.dart';
import '../services/ad_service.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';

class ResultScreen extends StatefulWidget {
  final int level;
  final int score;
  final int stars;
  final bool isWin;

  const ResultScreen({
    super.key,
    required this.level,
    required this.score,
    required this.stars,
    required this.isWin,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  final GameServicesManager _gameServices = GameServicesManager();
  final AdService _adService = AdService();
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _isRewardAdLoaded = false;
  bool _rewardClaimed = false;
  int _displayScore = 0;

  @override
  void initState() {
    super.initState();
    _displayScore = widget.score;

    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _animController.forward();

    // Save progress if won
    if (widget.isWin) {
      _saveProgress();
      _loadRewardedAd();
    }
  }

  void _loadRewardedAd() {
    _adService.loadRewardedAd(
      onLoaded: () {
        setState(() => _isRewardAdLoaded = true);
      },
      onFailed: (error) {
        setState(() => _isRewardAdLoaded = false);
      },
    );
  }

  Future<void> _saveProgress() async {
    await _storage.updateLevelProgress(widget.level, widget.stars);
    // Submit score to leaderboard
    await _gameServices.submitScore(widget.score);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB5E5FF), // Light sky blue
              Color(0xFFFFF5F5), // Soft pink white
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Result title
                ScaleTransition(
                  scale: _scaleAnim,
                  child: _buildResultTitle(),
                ),

                const SizedBox(height: 20),

                // Stars
                if (widget.isWin) _buildStars(),

                const SizedBox(height: 30),

                // Score
                _buildScoreCard(),

                const Spacer(),

                // Buttons
                _buildButtons(context),

                const SizedBox(height: 20),

                // Leaderboard button
                if (widget.isWin) _buildLeaderboardButton(),

                const SizedBox(height: 15),

                // Reward ad button
                if (widget.isWin) _buildRewardAdButton(),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultTitle() {
    return Column(
      children: [
        Text(
          widget.isWin ? 'CLEAR!' : 'GAME OVER',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: widget.isWin ? const Color(0xFF7CE595) : const Color(0xFFFF9AAE),
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: (widget.isWin ? const Color(0xFF7CE595) : const Color(0xFFFF9AAE))
                    .withAlpha((255 * 0.5).round()),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        Text(
          'Level ${widget.level}',
          style: const TextStyle(
            fontSize: 20,
            color: Color(0xFF7A9BB8),
          ),
        ),
      ],
    );
  }

  Widget _buildStars() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isEarned = index < widget.stars;
            final delay = index * 0.2;
            final starProgress = ((value - delay) / 0.4).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Transform.scale(
                scale: isEarned ? starProgress : 1.0,
                child: Icon(
                  Icons.star,
                  size: 50,
                  color: isEarned
                      ? const Color(0xFFFFD580)
                      : const Color(0xFFD0D0D0),
                  shadows: isEarned
                      ? [
                          Shadow(
                            color: const Color(0xFFFFD580).withAlpha((255 * 0.5).round()),
                            blurRadius: 15,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.9).round()),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7AC5F5).withAlpha((255 * 0.3).round()),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'SCORE',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7A9BB8),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: _displayScore),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Text(
                '$value',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5A5A7A),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Home button
        _buildButton(
          icon: Icons.home,
          color: const Color(0xFF8B9BB8),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        const SizedBox(width: 20),

        // Retry button
        _buildButton(
          icon: Icons.refresh,
          color: const Color(0xFFFFD580),
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => GameScreen(level: widget.level),
              ),
            );
          },
        ),
        const SizedBox(width: 20),

        // Next level button (only if won)
        if (widget.isWin)
          _buildButton(
            icon: Icons.arrow_forward,
            color: const Color(0xFF7CE595),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(level: widget.level + 1),
                ),
              );
            },
          ),

        // Level select button (only if lost)
        if (!widget.isWin)
          _buildButton(
            icon: Icons.grid_view,
            color: const Color(0xFF7AC5F5),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LevelSelectScreen(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((255 * 0.4).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildLeaderboardButton() {
    return GestureDetector(
      onTap: () {
        _gameServices.showLeaderboard();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7AC5F5), Color(0xFF5AA5D5)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7AC5F5).withAlpha((255 * 0.4).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.leaderboard, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardAdButton() {
    // 이미 보상을 받았거나 광고가 로드되지 않은 경우 표시하지 않음
    if (_rewardClaimed || !_isRewardAdLoaded) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        _adService.showRewardedAd(
          onRewarded: (reward) {
            setState(() {
              _displayScore = widget.score * 2;
              _rewardClaimed = true;
            });
            // 보너스 점수도 리더보드에 제출
            _gameServices.submitScore(_displayScore);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('x2 보너스! 점수: $_displayScore'),
                backgroundColor: const Color(0xFFD5A5FF),
              ),
            );
          },
          onAdFailed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다'),
                backgroundColor: Color(0xFFFF9AAE),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD5A5FF), Color(0xFFB575E5)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD5A5FF).withAlpha((255 * 0.4).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_fill, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'x2 Reward',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
