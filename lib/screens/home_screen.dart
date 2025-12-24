import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/game_services_manager.dart';
import 'level_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audio = AudioService();
  final GameServicesManager _gameServices = GameServicesManager();
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audio.init();
    setState(() {
      _soundEnabled = _audio.soundEnabled;
      _musicEnabled = _audio.musicEnabled;
    });
    // Start menu BGM
    await _audio.startBgm(AudioService.bgmMenu);
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
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Title
                _buildTitle(),

                const Spacer(flex: 1),

                // Animated bubbles decoration
                _buildBubblesDecoration(),

                const Spacer(flex: 1),

                // Play Button
                _buildPlayButton(context),

                const SizedBox(height: 20),

                // Settings Row
                _buildSettingsRow(context),

                const Spacer(flex: 2),

                // Ad banner placeholder
                _buildAdBanner(),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF3498DB),
              Color(0xFF9B59B6),
              Color(0xFFE74C3C),
            ],
          ).createShader(bounds),
          child: const Text(
            'Bubble Pop',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        const Text(
          'Adventure',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Colors.white70,
            letterSpacing: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildBubblesDecoration() {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBubble(const Color(0xFFE74C3C), 30),
          const SizedBox(width: 10),
          _buildBubble(const Color(0xFF2ECC71), 40),
          const SizedBox(width: 10),
          _buildBubble(const Color(0xFF3498DB), 50),
          const SizedBox(width: 10),
          _buildBubble(const Color(0xFFF1C40F), 40),
          const SizedBox(width: 10),
          _buildBubble(const Color(0xFF9B59B6), 30),
        ],
      ),
    );
  }

  Widget _buildBubble(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            color.withAlpha((255 * 0.8).round()),
            color,
            color.withAlpha((255 * 0.6).round()),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((255 * 0.5).round()),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _audio.playButton();
        _audio.stopBgm();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
        );
      },
      child: Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2ECC71).withAlpha((255 * 0.4).round()),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'PLAY',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIconButton(
          Icons.settings,
          () => _showSettingsDialog(context),
        ),
        const SizedBox(width: 20),
        _buildIconButton(
          Icons.leaderboard,
          () {
            _audio.playButton();
            _gameServices.showLeaderboard();
          },
        ),
        const SizedBox(width: 20),
        _buildIconButton(
          _soundEnabled ? Icons.volume_up : Icons.volume_off,
          () {
            _audio.playButton();
            setState(() {
              _soundEnabled = !_soundEnabled;
              _audio.setSoundEnabled(_soundEnabled);
            });
          },
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withAlpha((255 * 0.2).round()),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white70,
          size: 24,
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    _audio.playButton();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSettingsToggle(
                'Sound Effects',
                _soundEnabled,
                (value) {
                  setDialogState(() => _soundEnabled = value);
                  setState(() => _soundEnabled = value);
                  _audio.setSoundEnabled(value);
                  if (value) _audio.playButton();
                },
              ),
              _buildSettingsToggle(
                'Music',
                _musicEnabled,
                (value) {
                  setDialogState(() => _musicEnabled = value);
                  setState(() => _musicEnabled = value);
                  _audio.setMusicEnabled(value);
                  _audio.playButton();
                },
              ),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  _audio.playButton();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsToggle(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF2ECC71),
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.05).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withAlpha((255 * 0.1).round()),
        ),
      ),
      child: const Center(
        child: Text(
          'Ad Banner',
          style: TextStyle(color: Colors.white30),
        ),
      ),
    );
  }
}
