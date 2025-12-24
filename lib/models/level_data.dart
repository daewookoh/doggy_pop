import 'bubble_type.dart';

class LevelData {
  final int levelNumber;
  final int bubbleCount;
  final int targetScore;
  final List<List<BubbleType?>> initialGrid;
  final List<BubbleType> availableTypes;

  const LevelData({
    required this.levelNumber,
    required this.bubbleCount,
    required this.targetScore,
    required this.initialGrid,
    required this.availableTypes,
  });

  // Generate levels procedurally
  static LevelData generate(int level) {
    final bubbleCount = 25 + (level * 2);
    final targetScore = 500 * level;
    final colorCount = (2 + (level ~/ 3)).clamp(3, 6);
    final availableTypes = BubbleType.values.take(colorCount).toList();

    return LevelData(
      levelNumber: level,
      bubbleCount: bubbleCount,
      targetScore: targetScore,
      initialGrid: [],
      availableTypes: availableTypes,
    );
  }
}

class PlayerProgress {
  final Map<int, int> levelStars; // level -> stars (0-3)
  final int highestUnlockedLevel;
  final int totalStars;

  const PlayerProgress({
    this.levelStars = const {},
    this.highestUnlockedLevel = 1,
    this.totalStars = 0,
  });

  PlayerProgress copyWith({
    Map<int, int>? levelStars,
    int? highestUnlockedLevel,
    int? totalStars,
  }) {
    return PlayerProgress(
      levelStars: levelStars ?? this.levelStars,
      highestUnlockedLevel: highestUnlockedLevel ?? this.highestUnlockedLevel,
      totalStars: totalStars ?? this.totalStars,
    );
  }

  bool isLevelUnlocked(int level) {
    return level <= highestUnlockedLevel;
  }

  int getStarsForLevel(int level) {
    return levelStars[level] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'levelStars': levelStars.map((k, v) => MapEntry(k.toString(), v)),
      'highestUnlockedLevel': highestUnlockedLevel,
      'totalStars': totalStars,
    };
  }

  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    final levelStarsRaw = json['levelStars'] as Map<String, dynamic>? ?? {};
    final levelStars = levelStarsRaw.map((k, v) => MapEntry(int.parse(k), v as int));

    return PlayerProgress(
      levelStars: levelStars,
      highestUnlockedLevel: json['highestUnlockedLevel'] as int? ?? 1,
      totalStars: json['totalStars'] as int? ?? 0,
    );
  }
}
