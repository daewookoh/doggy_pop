class LeaderboardEntry {
  final String playerName;
  final int score;
  final int level;
  final int stars;
  final DateTime date;

  const LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.level,
    required this.stars,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
      'level': level,
      'stars': stars,
      'date': date.toIso8601String(),
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerName: json['playerName'] as String? ?? 'Player',
      score: json['score'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      stars: json['stars'] as int? ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'LeaderboardEntry(name: $playerName, score: $score, level: $level)';
  }
}
