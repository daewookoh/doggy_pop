import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

class GameServicesManager {
  static final GameServicesManager _instance = GameServicesManager._internal();
  factory GameServicesManager() => _instance;
  GameServicesManager._internal();

  bool _isSignedIn = false;
  bool _initialized = false;

  // Leaderboard ID - replace with your actual leaderboard ID from Play Console
  static const String leaderboardId = 'YOUR_LEADERBOARD_ID';

  bool get isSignedIn => _isSignedIn;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await signIn();
    } catch (e) {
      debugPrint('Game Services init error: $e');
    }
  }

  Future<bool> signIn() async {
    try {
      await GamesServices.signIn();
      _isSignedIn = true;
      debugPrint('Game Services: Signed in successfully');
      return true;
    } catch (e) {
      _isSignedIn = false;
      debugPrint('Game Services sign in failed: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      // Note: games_services doesn't have a direct signOut method
      // Users sign out through the Google Play Games app
      _isSignedIn = false;
    } catch (e) {
      debugPrint('Game Services sign out error: $e');
    }
  }

  Future<bool> submitScore(int score, {String? leaderboardID}) async {
    if (!_isSignedIn) {
      final success = await signIn();
      if (!success) return false;
    }

    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: leaderboardID ?? leaderboardId,
          iOSLeaderboardID: leaderboardID ?? leaderboardId,
          value: score,
        ),
      );
      debugPrint('Score submitted: $score');
      return true;
    } catch (e) {
      debugPrint('Failed to submit score: $e');
      return false;
    }
  }

  Future<void> showLeaderboard({String? leaderboardID}) async {
    if (!_isSignedIn) {
      final success = await signIn();
      if (!success) {
        debugPrint('Cannot show leaderboard: not signed in');
        return;
      }
    }

    try {
      await GamesServices.showLeaderboards(
        androidLeaderboardID: leaderboardID ?? leaderboardId,
        iOSLeaderboardID: leaderboardID ?? leaderboardId,
      );
    } catch (e) {
      debugPrint('Failed to show leaderboard: $e');
    }
  }

  Future<void> showAllLeaderboards() async {
    if (!_isSignedIn) {
      final success = await signIn();
      if (!success) {
        debugPrint('Cannot show leaderboards: not signed in');
        return;
      }
    }

    try {
      await GamesServices.showLeaderboards();
    } catch (e) {
      debugPrint('Failed to show leaderboards: $e');
    }
  }

  // Achievement methods (for future use)
  Future<bool> unlockAchievement(String achievementId) async {
    if (!_isSignedIn) {
      final success = await signIn();
      if (!success) return false;
    }

    try {
      await GamesServices.unlock(
        achievement: Achievement(
          androidID: achievementId,
          iOSID: achievementId,
        ),
      );
      debugPrint('Achievement unlocked: $achievementId');
      return true;
    } catch (e) {
      debugPrint('Failed to unlock achievement: $e');
      return false;
    }
  }

  Future<void> showAchievements() async {
    if (!_isSignedIn) {
      final success = await signIn();
      if (!success) return;
    }

    try {
      await GamesServices.showAchievements();
    } catch (e) {
      debugPrint('Failed to show achievements: $e');
    }
  }

  // Get player info
  Future<String?> getPlayerName() async {
    if (!_isSignedIn) return null;

    try {
      final name = await GamesServices.getPlayerName();
      return name;
    } catch (e) {
      debugPrint('Failed to get player name: $e');
      return null;
    }
  }
}
