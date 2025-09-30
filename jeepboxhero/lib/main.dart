// main.dart
import 'package:flutter/material.dart';

class MainMenuScreen extends StatefulWidget {
  final VoidCallback? onNewGame;
  final VoidCallback? onContinue;
  final VoidCallback? onQuit;
  const MainMenuScreen({this.onNewGame, this.onContinue, this.onQuit, Key? key})
      : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  bool _logoTapped = false;
  late AnimationController _controller;
  late Animation<double> _logoOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoOffset = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLogoTap() {
    if (_logoTapped) return;
    setState(() => _logoTapped = true);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Logo placement
    final logoWidth = size.width * 0.45;
    final logoHeight = logoWidth * 0.8;
    final logoStartX = size.width * 0.5 - logoWidth / 2;
    final logoEndX = size.width * 0.65 - logoWidth / 2;
    final logoY = size.height * 0.05;

    // Button layout (flush left, smaller size)
    final buttonWidth = size.width * 0.35; // 35% of screen width
    final buttonHeight = size.height * 0.1; // 10% of screen height
    final buttonTargetX = size.width * 0.05; // margin from left edge
    final buttonStartX = -buttonWidth; // slide in from off-screen
    final buttonStartY = size.height * 0.25;
    final buttonSpacing = size.height * 0.06;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/menu_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Animated content
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final logoX =
                  logoStartX + (_logoOffset.value * (logoEndX - logoStartX));

              return Stack(
                children: [
                  // Logo
                  Positioned(
                    left: logoX,
                    top: logoY,
                    child: GestureDetector(
                      onTap: _onLogoTap,
                      child: Image.asset(
                        'assets/ui/logo.png',
                        width: logoWidth,
                        height: logoHeight,
                      ),
                    ),
                  ),

                  // Buttons (appear after logo tapped)
                  if (_logoTapped)
                    ...List.generate(3, (i) {
                      final buttonNames = ['start', 'continue', 'quit'];
                      final slideProgress = _logoOffset.value.clamp(0.0, 1.0);
                      final buttonX = buttonStartX +
                          (buttonTargetX - buttonStartX) * slideProgress;

                      return Positioned(
                        left: buttonX,
                        top: buttonStartY + i * (buttonHeight + buttonSpacing),
                        child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: GestureDetector(
                            onTap: () {
                              if (i == 0) widget.onNewGame?.call();
                              if (i == 1) widget.onContinue?.call();
                              if (i == 2) widget.onQuit?.call();
                            },
                            child: Image.asset(
                              'assets/ui/${buttonNames[i]}.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

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
      home: MainMenuScreen(
        onNewGame: () => print('Start new game'),
        onContinue: () => print('Continue game'),
        onQuit: () => print('Quit game'),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
