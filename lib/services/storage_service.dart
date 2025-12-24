import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level_data.dart';

class StorageService {
  static const String _progressKey = 'player_progress';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _musicEnabledKey = 'music_enabled';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Player Progress
  Future<PlayerProgress> loadProgress() async {
    _prefs ??= await SharedPreferences.getInstance();

    final jsonString = _prefs!.getString(_progressKey);
    if (jsonString == null) {
      return const PlayerProgress();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerProgress.fromJson(json);
    } catch (e) {
      return const PlayerProgress();
    }
  }

  Future<void> saveProgress(PlayerProgress progress) async {
    _prefs ??= await SharedPreferences.getInstance();
    final jsonString = jsonEncode(progress.toJson());
    await _prefs!.setString(_progressKey, jsonString);
  }

  Future<PlayerProgress> updateLevelProgress(int level, int stars) async {
    var progress = await loadProgress();

    final currentStars = progress.getStarsForLevel(level);
    if (stars > currentStars) {
      final newLevelStars = Map<int, int>.from(progress.levelStars);
      newLevelStars[level] = stars;

      final newTotalStars = newLevelStars.values.fold(0, (a, b) => a + b);
      final newHighest = level >= progress.highestUnlockedLevel
          ? level + 1
          : progress.highestUnlockedLevel;

      progress = progress.copyWith(
        levelStars: newLevelStars,
        highestUnlockedLevel: newHighest,
        totalStars: newTotalStars,
      );

      await saveProgress(progress);
    }

    return progress;
  }

  // Sound Settings
  Future<bool> isSoundEnabled() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_soundEnabledKey, enabled);
  }

  Future<bool> isMusicEnabled() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getBool(_musicEnabledKey) ?? true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_musicEnabledKey, enabled);
  }

  // Reset all data
  Future<void> resetAll() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.clear();
  }
}
