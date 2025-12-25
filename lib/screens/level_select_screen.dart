import 'package:flutter/material.dart';
import '../models/level_data.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  static const int totalLevels = 500;

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
              Color(0xFFB5E5FF), // Light sky blue
              Color(0xFFE8F4FC), // Soft white blue
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
                color: Colors.white.withAlpha((255 * 0.8).round()),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7AC5F5).withAlpha((255 * 0.3).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF7A9BB8),
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
                color: Color(0xFF5A5A7A),
              ),
            ),
          ),
          // Total stars display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((255 * 0.8).round()),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD580).withAlpha((255 * 0.4).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFD580), size: 20),
                const SizedBox(width: 4),
                Text(
                  '${_progress.totalStars}',
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
                    _getLevelColor(level).withAlpha((255 * 0.8).round()),
                  ],
                )
              : null,
          color: isUnlocked ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _getLevelColor(level).withAlpha((255 * 0.4).round()),
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
              Icon(
                Icons.lock,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(int level) {
    // Pastel colors for levels
    final colors = [
      const Color(0xFF7AC5F5), // Pastel blue
      const Color(0xFF7CE595), // Pastel green
      const Color(0xFFFFD580), // Pastel yellow
      const Color(0xFFFFBF8A), // Pastel orange
      const Color(0xFFFF9AAE), // Pastel pink
      const Color(0xFFD5A5FF), // Pastel purple
    ];
    return colors[(level - 1) % colors.length];
  }

  Widget _buildStars(int stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          color: index < stars ? const Color(0xFFFFD580) : Colors.white54,
          size: 12,
        );
      }),
    );
  }
}
