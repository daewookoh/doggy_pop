import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/audio_service.dart';
import '../services/game_services_manager.dart';
import '../services/ad_service.dart';
import 'level_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audio = AudioService();
  final GameServicesManager _gameServices = GameServicesManager();
  final AdService _adService = AdService();
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
    _loadBannerAd();
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

  void _loadBannerAd() {
    _adService.loadBannerAd(
      onLoaded: () {
        setState(() => _isBannerAdLoaded = true);
      },
      onFailed: (error) {
        setState(() => _isBannerAdLoaded = false);
      },
    );
  }

  @override
  void dispose() {
    _adService.disposeBannerAd();
    super.dispose();
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
              Color(0xFFFFF5F5), // Soft pink white
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
    return Image.asset(
      'assets/images/logo_text.webp',
      width: 280,
      fit: BoxFit.contain,
    );
  }

  Widget _buildBubblesDecoration() {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPawBubble(const Color(0xFFFFB5C5), const Color(0xFFFF8FA5), 30),
          const SizedBox(width: 10),
          _buildPawBubble(const Color(0xFFB5F5C5), const Color(0xFF7CE595), 40),
          const SizedBox(width: 10),
          _buildPawBubble(const Color(0xFFB5E5FF), const Color(0xFF7AC5F5), 50),
          const SizedBox(width: 10),
          _buildPawBubble(const Color(0xFFFFE5A5), const Color(0xFFFFC560), 40),
          const SizedBox(width: 10),
          _buildPawBubble(const Color(0xFFE5C5FF), const Color(0xFFD595FF), 30),
        ],
      ),
    );
  }

  Widget _buildPawBubble(Color bubbleColor, Color pawColor, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Colors.white.withAlpha((255 * 0.9).round()),
            bubbleColor.withAlpha((255 * 0.85).round()),
            bubbleColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: bubbleColor.withAlpha((255 * 0.5).round()),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CustomPaint(
        painter: PawPrintPainter(pawColor: pawColor),
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
            colors: [Color(0xFF7CE595), Color(0xFF5CC575)], // Pastel green
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7CE595).withAlpha((255 * 0.5).round()),
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
          color: Colors.white.withAlpha((255 * 0.7).round()),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFFD5A5FF).withAlpha((255 * 0.5).round()),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD5A5FF).withAlpha((255 * 0.3).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: const Color(0xFF8B7BA8),
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
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Color(0xFF5A5A7A),
              fontWeight: FontWeight.bold,
            ),
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
          Text(label, style: const TextStyle(color: Color(0xFF5A5A7A))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF7CE595),
            thumbColor: WidgetStateProperty.all(Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    if (_isBannerAdLoaded && _adService.bannerAd != null) {
      return Container(
        width: _adService.bannerAd!.size.width.toDouble(),
        height: _adService.bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _adService.bannerAd!),
      );
    }
    return const SizedBox(height: 50);
  }
}

class PawPrintPainter extends CustomPainter {
  final Color pawColor;

  PawPrintPainter({required this.pawColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final pawPaint = Paint()..color = pawColor;
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.4).round());

    // Main pad (oval at bottom-center)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.12),
        width: radius * 0.65,
        height: radius * 0.5,
      ),
      pawPaint,
    );

    // Main pad highlight
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.08, center.dy + radius * 0.02),
        width: radius * 0.2,
        height: radius * 0.15,
      ),
      highlightPaint,
    );

    // Toe pads
    final toePositions = [
      Offset(center.dx - radius * 0.32, center.dy - radius * 0.25),
      Offset(center.dx - radius * 0.12, center.dy - radius * 0.38),
      Offset(center.dx + radius * 0.12, center.dy - radius * 0.38),
      Offset(center.dx + radius * 0.32, center.dy - radius * 0.25),
    ];

    final toeSizes = [radius * 0.16, radius * 0.17, radius * 0.17, radius * 0.16];

    for (int i = 0; i < toePositions.length; i++) {
      canvas.drawCircle(toePositions[i], toeSizes[i], pawPaint);
      canvas.drawCircle(
        toePositions[i] + Offset(-toeSizes[i] * 0.2, -toeSizes[i] * 0.2),
        toeSizes[i] * 0.3,
        highlightPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
