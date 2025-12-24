import 'package:flutter/foundation.dart';

class GameStateModel extends ChangeNotifier {
  int _score = 0;
  int _remainingBubbles = 30;
  int _currentLevel = 1;
  int _stars = 0;
  bool _isPaused = false;
  bool _isGameOver = false;
  bool _isWin = false;

  // Getters
  int get score => _score;
  int get remainingBubbles => _remainingBubbles;
  int get currentLevel => _currentLevel;
  int get stars => _stars;
  bool get isPaused => _isPaused;
  bool get isGameOver => _isGameOver;
  bool get isWin => _isWin;

  // Setters with notification
  void setScore(int value) {
    _score = value;
    notifyListeners();
  }

  void setRemainingBubbles(int value) {
    _remainingBubbles = value;
    notifyListeners();
  }

  void setCurrentLevel(int value) {
    _currentLevel = value;
    notifyListeners();
  }

  void setStars(int value) {
    _stars = value;
    notifyListeners();
  }

  void setPaused(bool value) {
    _isPaused = value;
    notifyListeners();
  }

  void setGameOver(bool value, bool isWin) {
    _isGameOver = value;
    _isWin = isWin;
    notifyListeners();
  }

  void reset() {
    _score = 0;
    _remainingBubbles = 30;
    _isPaused = false;
    _isGameOver = false;
    _isWin = false;
    notifyListeners();
  }
}
