import 'package:flutter/material.dart';
import '../models/level_data.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  static const int totalLevels = 30;

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final StorageService _storage = StorageService();
  PlayerProgress _progress = const PlayerProgress();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress = await _storage.loadProgress();
    setState(() {
      _progress = progress;
      _isLoading = false;
    });
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
          child: Column(
            children: [
              _buildHeader(context),
              if (_isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              else
                Expanded(
                  child: _buildLevelGrid(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white70,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Select Level',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Total stars display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFF1C40F), size: 20),
                const SizedBox(width: 4),
                Text(
                  '${_progress.totalStars}',
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

  Widget _buildLevelGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 0.85,
      ),
      itemCount: LevelSelectScreen.totalLevels,
      itemBuilder: (context, index) {
        final level = index + 1;
        final isUnlocked = _progress.isLevelUnlocked(level);
        final stars = _progress.getStarsForLevel(level);

        return _buildLevelButton(context, level, isUnlocked, stars);
      },
    );
  }

  Widget _buildLevelButton(
    BuildContext context,
    int level,
    bool isUnlocked,
    int stars,
  ) {
    return GestureDetector(
      onTap: isUnlocked
          ? () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(level: level),
                ),
              );
              // Reload progress when returning from game
              if (result == true || context.mounted) {
                _loadProgress();
              }
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _getLevelColor(level),
                    _getLevelColor(level).withAlpha((255 * 0.7).round()),
                  ],
                )
              : null,
          color: isUnlocked ? null : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _getLevelColor(level).withAlpha((255 * 0.3).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isUnlocked) ...[
              Text(
                '$level',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              _buildStars(stars),
            ] else ...[
              const Icon(
                Icons.lock,
                color: Colors.white30,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    final colors = [
      const Color(0xFF3498DB),
      const Color(0xFF2ECC71),
      const Color(0xFFF1C40F),
      const Color(0xFFE67E22),
      const Color(0xFFE74C3C),
      const Color(0xFF9B59B6),
    ];
    return colors[(level - 1) % colors.length];
  }

  Widget _buildStars(int stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: index < stars ? const Color(0xFFF1C40F) : Colors.white30,
          size: 12,
        );
      }),
    );
  }
}
