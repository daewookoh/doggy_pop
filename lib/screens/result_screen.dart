import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/game_services_manager.dart';
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
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

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
    }
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
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
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
            color: widget.isWin ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
            letterSpacing: 4,
            shadows: [
              Shadow(
                color: (widget.isWin ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C))
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
            color: Colors.white70,
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
                      ? const Color(0xFFF1C40F)
                      : Colors.white.withAlpha((255 * 0.2).round()),
                  shadows: isEarned
                      ? [
                          Shadow(
                            color: const Color(0xFFF1C40F).withAlpha((255 * 0.5).round()),
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
        color: Colors.white.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha((255 * 0.1).round()),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'SCORE',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: widget.score),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Text(
                '$value',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
          color: const Color(0xFF34495E),
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        const SizedBox(width: 20),

        // Retry button
        _buildButton(
          icon: Icons.refresh,
          color: const Color(0xFFF1C40F),
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
            color: const Color(0xFF2ECC71),
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
            color: const Color(0xFF3498DB),
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
            colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3498DB).withAlpha((255 * 0.4).round()),
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
    return GestureDetector(
      onTap: () {
        // TODO: Show reward ad
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward ad will be shown here'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9B59B6).withAlpha((255 * 0.4).round()),
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
