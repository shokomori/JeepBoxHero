// lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const JeepBoxApp());
}

class JeepBoxApp extends StatelessWidget {
  const JeepBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeep Box Hero',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const MainMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onQuit;
  const MainMenuScreen({this.onContinue, this.onQuit, super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  bool _logoTapped = false;
  bool _showNarration = false;
  bool _narrationComplete = false;
  String _fullText = "";
  String _visibleText = "";
  int _charIndex = 0;
  bool _isTransitioning = false;

  late final AnimationController _slideController;
  late final Animation<double> _slideAnimation;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _fadeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        setState(() {
          _showNarration = true;
          _narrationComplete = false;
        });
        _typeWriter();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onLogoTap() {
    if (_logoTapped) return;
    setState(() => _logoTapped = true);
    _slideController.forward();
  }

  void _startNarration() {
    if (_isTransitioning) return;
    setState(() => _isTransitioning = true);

    _fullText =
        "The streets of Cubao are alive again. Neon lights hum, jeepneys roar, and the scent of street food drifts through the night air. "
        "Tucked between an old cinema and a sari-sari store is Jeep Box Records, a tiny shop that once echoed with the dreams of its owner.\n\n"
        "You arrive on your first day as the shop's newest employee, still unsure what this small store holds for you.";
    _visibleText = "";
    _charIndex = 0;
    _narrationComplete = false;

    if (_slideController.status != AnimationStatus.completed) {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _slideController.removeStatusListener(listener);
          _fadeController.forward();
        }
      }

      _slideController.addStatusListener(listener);
    } else {
      _fadeController.forward();
    }
  }

  Future<void> _typeWriter() async {
    await Future.delayed(const Duration(milliseconds: 120));
    for (int i = 0; i < _fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() {
        _visibleText += _fullText[i];
        _charIndex = i;
      });
    }
    if (!mounted) return;
    setState(() {
      _narrationComplete = true;
      _isTransitioning = false;
    });
  }

  void _onNarrationTap() {
    if (!_narrationComplete) {
      setState(() {
        _visibleText = _fullText;
        _narrationComplete = true;
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const GameScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final logoWidth = size.width * 0.45;
    final logoHeight = logoWidth * 0.75;
    final logoStartX = size.width / 2 - logoWidth / 2;
    final logoMidX = size.width * 0.68 - logoWidth / 2;
    final logoEndX = size.width;
    final logoY = size.height / 2 - logoHeight / 2;

    final buttonWidth = size.width * 0.5;
    final buttonHeight = size.height * 0.12;
    final buttonStartX = -buttonWidth;
    final buttonMidX = size.width * 0.05;
    final buttonEndX = -buttonWidth;
    final buttonStartY = size.height * 0.28;
    final buttonSpacing = buttonHeight + (size.height * 0.025);

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/menu_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          AnimatedBuilder(
            animation: _slideController,
            builder: (context, _) {
              return AnimatedBuilder(
                animation: _fadeController,
                builder: (context, __) {
                  final slideProgress = _slideAnimation.value;
                  final fadeProgress = _fadeAnimation.value;

                  final logoMidPoint =
                      logoStartX + (slideProgress * (logoMidX - logoStartX));
                  final logoX =
                      logoMidPoint + (fadeProgress * (logoEndX - logoMidPoint));

                  final buttonMidPoint = buttonStartX +
                      (slideProgress * (buttonMidX - buttonStartX));
                  final buttonX = buttonMidPoint +
                      (fadeProgress * (buttonEndX - buttonMidPoint));

                  final opacity = 1.0 - fadeProgress;

                  return Stack(
                    children: [
                      // Logo
                      if (!_showNarration)
                        Positioned(
                          left: logoX,
                          top: logoY,
                          child: Opacity(
                            opacity: opacity,
                            child: GestureDetector(
                              onTap: _onLogoTap,
                              child: Image.asset(
                                'assets/ui/logo.png',
                                width: logoWidth,
                                height: logoHeight,
                              ),
                            ),
                          ),
                        ),

                      // Buttons
                      if (_logoTapped && !_showNarration)
                        ...List.generate(3, (i) {
                          final buttonFiles = [
                            'assets/ui/start.png',
                            'assets/ui/continue.png',
                            'assets/ui/quit.png'
                          ];
                          return Positioned(
                            left: buttonX,
                            top: buttonStartY + (i * buttonSpacing),
                            child: Opacity(
                              opacity: opacity,
                              child: GestureDetector(
                                onTap: () {
                                  if (i == 0) _startNarration();
                                  if (i == 1) widget.onContinue?.call();
                                  if (i == 2) widget.onQuit?.call();
                                },
                                child: Image.asset(
                                  buttonFiles[i],
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        }),

                      // Narration
                      if (_showNarration)
                        Positioned(
                          left: size.width * 0.08,
                          right: size.width * 0.08,
                          bottom: size.height * 0.08,
                          child: GestureDetector(
                            onTap: _onNarrationTap,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red,
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _visibleText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                  if (_narrationComplete)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '▼ Tap to continue',
                                          style: TextStyle(
                                            color: Colors.green.withOpacity(
                                                ((_charIndex ~/ 10) % 2 == 0)
                                                    ? 1.0
                                                    : 0.5),
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game Screen")),
      body: const Center(
        child: Text(
          "Game starts here!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
