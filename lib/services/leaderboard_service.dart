import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  static const String _leaderboardKey = 'leaderboard';
  static const String _playerNameKey = 'player_name';
  static const int maxEntries = 100;

  SharedPreferences? _prefs;
  String _playerName = 'Player';

  String get playerName => _playerName;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _playerName = _prefs!.getString(_playerNameKey) ?? 'Player';
  }

  Future<void> setPlayerName(String name) async {
    _prefs ??= await SharedPreferences.getInstance();
    _playerName = name.isEmpty ? 'Player' : name;
    await _prefs!.setString(_playerNameKey, _playerName);
  }

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    _prefs ??= await SharedPreferences.getInstance();

    final jsonString = _prefs!.getString(_leaderboardKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final entries = jsonList
          .map((json) => LeaderboardEntry.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort by score descending
      entries.sort((a, b) => b.score.compareTo(a.score));
      return entries;
    } catch (e) {
      return [];
    }
  }

  Future<int> addScore({
    required int score,
    required int level,
    required int stars,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();

    final entry = LeaderboardEntry(
      playerName: _playerName,
      score: score,
      level: level,
      stars: stars,
      date: DateTime.now(),
    );

    final entries = await getLeaderboard();
    entries.add(entry);

    // Sort by score descending
    entries.sort((a, b) => b.score.compareTo(a.score));

    // Keep only top entries
    final trimmedEntries = entries.take(maxEntries).toList();

    // Save
    final jsonList = trimmedEntries.map((e) => e.toJson()).toList();
    await _prefs!.setString(_leaderboardKey, jsonEncode(jsonList));

    // Return rank (1-based)
    return trimmedEntries.indexWhere((e) =>
            e.score == score &&
            e.level == level &&
            e.playerName == _playerName) +
        1;
  }

  Future<int> getHighScore() async {
    final entries = await getLeaderboard();
    if (entries.isEmpty) return 0;
    return entries.first.score;
  }

  Future<LeaderboardEntry?> getPersonalBest() async {
    final entries = await getLeaderboard();
    try {
      return entries.firstWhere((e) => e.playerName == _playerName);
    } catch (e) {
      return null;
    }
  }

  Future<int> getRank(int score) async {
    final entries = await getLeaderboard();
    int rank = 1;
    for (final entry in entries) {
      if (entry.score > score) {
        rank++;
      } else {
        break;
      }
    }
    return rank;
  }

  Future<void> clearLeaderboard() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_leaderboardKey);
  }
}
