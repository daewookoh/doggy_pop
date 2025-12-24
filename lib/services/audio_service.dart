import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flame_audio/flame_audio.dart';
import 'storage_service.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final StorageService _storage = StorageService();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _initialized = false;
  bool _soundFilesAvailable = false;

  // Sound effect keys
  static const String sfxShoot = 'shoot.wav';
  static const String sfxPop = 'pop.wav';
  static const String sfxDrop = 'drop.wav';
  static const String sfxCombo = 'combo.wav';
  static const String sfxWin = 'win.wav';
  static const String sfxLose = 'lose.wav';
  static const String sfxButton = 'button.wav';

  // BGM keys
  static const String bgmMenu = 'menu_bgm.mp3';
  static const String bgmGame = 'game_bgm.mp3';

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  Future<void> init() async {
    if (_initialized) return;

    _soundEnabled = await _storage.isSoundEnabled();
    _musicEnabled = await _storage.isMusicEnabled();
    _initialized = true;

    // Try to preload sounds
    try {
      await FlameAudio.audioCache.loadAll([
        sfxShoot,
        sfxPop,
        sfxDrop,
        sfxCombo,
        sfxWin,
        sfxLose,
        sfxButton,
      ]);
      _soundFilesAvailable = true;
      debugPrint('Sound files loaded successfully');
    } catch (e) {
      _soundFilesAvailable = false;
      debugPrint('Sound files not found, using system sounds');
    }
  }

  // Play sound effect
  Future<void> playSound(String sound) async {
    if (!_soundEnabled) return;

    if (_soundFilesAvailable) {
      try {
        await FlameAudio.play(sound, volume: 0.5);
        return;
      } catch (e) {
        // Fallback to system sound
      }
    }

    // Use system sound as fallback
    await _playSystemSound();
  }

  // System sound fallback
  Future<void> _playSystemSound() async {
    try {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Ignore errors
    }
  }

  // Play shooting sound
  Future<void> playShoot() async {
    if (!_soundEnabled) return;

    if (_soundFilesAvailable) {
      await playSound(sfxShoot);
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  // Play pop sound
  Future<void> playPop() async {
    if (!_soundEnabled) return;

    if (_soundFilesAvailable) {
      await playSound(sfxPop);
    } else {
      await HapticFeedback.mediumImpact();
      await SystemSound.play(SystemSoundType.click);
    }
  }

  // Play drop sound
  Future<void> playDrop() async {
    if (!_soundEnabled) return;

    if (_soundFilesAvailable) {
      await playSound(sfxDrop);
    } else {
      await HapticFeedback.lightImpact();
    }
  }

  // Play combo sound
  Future<void> playCombo() async {
    if (!_soundEnabled) return;

    if (_soundFilesAvailable) {
      await playSound(sfxCombo);
    } else {
      await HapticFeedback.heavyImpact();
      await SystemSound.play(SystemSoundType.click);
    }
  }

  // Play win sound
  Future<void> playWin() async {
    if (!_soundEnabled) return;

    if (_soundFilesAvailable) {
      await playSound(sfxWin);
    } else {
      // Victory vibration pattern
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    }
  }

  // Play lose sound
  Future<void> playLose() async {
    if (!_soundEnabled) return;

    if (_soundFilesAvailable) {
      await playSound(sfxLose);
    } else {
      await HapticFeedback.vibrate();
    }
  }

  // Play button click sound
  Future<void> playButton() async {
    if (!_soundEnabled) return;

    if (_soundFilesAvailable) {
      await playSound(sfxButton);
    } else {
      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.selectionClick();
    }
  }

  // Start background music
  Future<void> startBgm(String bgm) async {
    if (!_musicEnabled) return;

    try {
      await FlameAudio.bgm.play(bgm, volume: 0.3);
    } catch (e) {
      debugPrint('BGM file not found: $bgm');
    }
  }

  // Stop background music
  Future<void> stopBgm() async {
    try {
      await FlameAudio.bgm.stop();
    } catch (e) {
      // Ignore
    }
  }

  // Pause background music
  Future<void> pauseBgm() async {
    try {
      await FlameAudio.bgm.pause();
    } catch (e) {
      // Ignore
    }
  }

  // Resume background music
  Future<void> resumeBgm() async {
    if (!_musicEnabled) return;
    try {
      await FlameAudio.bgm.resume();
    } catch (e) {
      // Ignore
    }
  }

  // Toggle sound effects
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _storage.setSoundEnabled(enabled);
  }

  // Toggle music
  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await _storage.setMusicEnabled(enabled);

    if (enabled) {
      await resumeBgm();
    } else {
      await pauseBgm();
    }
  }

  // Dispose
  Future<void> dispose() async {
    await stopBgm();
    FlameAudio.audioCache.clearAll();
  }
}
