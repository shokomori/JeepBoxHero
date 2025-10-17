// lib/screens/epilogue_screen.dart
import 'package:flutter/material.dart';
import '../managers/audio_manager.dart';
import '../main.dart';

class EpilogueScreen extends StatefulWidget {
  const EpilogueScreen({super.key});

  @override
  State<EpilogueScreen> createState() => _EpilogueScreenState();
}

class _EpilogueScreenState extends State<EpilogueScreen> {
  int _pageIndex = 0;
  final List<String> _pages = [
    'The neon signs outside hum softly as Jeep Box Records winds down. The shelves stand a little emptier, the receipt book carries fresh names, and the air is thick with the echoes of songs once more alive.',
    'Tito Ramon:\n"Not bad, kid. You’ve got the rhythm for this. Jeep Box has always been more than four walls and vinyl. It’s where music keeps breathing, where memories don’t fade. As long as there are people who listen, this place will never die."',
    'You step outside, the streets of Cubao alive with jeepneys, laughter, and the glow of midnight lights. In your chest, a quiet certainty takes root—this shop is more than a job. It’s a stage for untold stories, a refuge for lost songs, and a bridge between generations.\n\nThe night wraps around you, but the music lingers. Tomorrow, the door will chime again, another soul will walk in, and another story will be waiting. Jeep Box Records is alive—and now, so are you in its rhythm.'
  ];

  @override
  void initState() {
    super.initState();
    try {
      AudioManager()
          .playAmbient('bgm_epilogue_ambient.mp3', volume: 0.14, loop: true);
    } catch (_) {}
  }

  void _nextPage() {
    if (_pageIndex < _pages.length - 1) {
      setState(() => _pageIndex++);
    } else {
      try {
        AudioManager().stopAmbient();
      } catch (_) {}

      // Restart the app by returning to MainMenuScreen and clearing the nav stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainMenuScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: _nextPage,
        child: Stack(
          children: [
            // Background and dim
            Positioned.fill(
                child: Image.asset('assets/backgrounds/shop_night.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.black87);
            })),
            Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.35))),

            // Fade-in effect for the whole scene
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 600),
                child: const SizedBox.shrink(),
              ),
            ),

            // Tito Ramon entrance - slide from right when we reach his page (pageIndex == 1)
            if (_pageIndex >= 1)
              Positioned(
                right: w * 0.02,
                bottom: h * 0.30,
                width: w * 0.28,
                height: h * 0.42,
                child: AnimatedSlide(
                  offset: _pageIndex >= 1 ? Offset.zero : const Offset(0.4, 0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  child: Image.asset('assets/characters/ramon_night.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.transparent);
                  }),
                ),
              ),

            // Bottom-positioned narration/dialogue box (cinematic framing)
            if (true)
              Positioned(
                left: w * 0.04,
                right: w * 0.04,
                bottom: h * 0.04,
                child: Container(
                  constraints: BoxConstraints(maxHeight: h * 0.25),
                  padding: EdgeInsets.symmetric(
                      horizontal: w * 0.035, vertical: h * 0.015),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white70, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            _pages[_pageIndex],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: w * 0.014,
                              height: 1.35,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.006),
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text('▼ Tap to continue',
                              style: TextStyle(
                                  fontSize: w * 0.011,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70)))
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
