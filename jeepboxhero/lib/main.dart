import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jeep Box Hero',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: false),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});
  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _menuShown = false;
  bool _logoTappedOnce = false;

  // durations used by animations
  final Duration _animDuration = const Duration(milliseconds: 650);
  final Curve _animCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // keep content behind system bars for cinematic look
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final double h = constraints.maxHeight;

            // tweak sizes for responsiveness
            final double logoWidth = w > 600 ? 360 : 260;
            final double buttonsWidth = w > 600 ? 280 : 200;

            // positions
            final double logoTop = h * 0.18;
            final double buttonsTop = h * 0.36;

            return Stack(
              children: [
                // Background
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/menu_bg.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.black),
                  ),
                ),

                // Buttons container (slides in from left)
                AnimatedPositioned(
                  duration: _animDuration,
                  curve: _animCurve,
                  top: buttonsTop,
                  // when hidden, place it off-screen to the left; when shown, give room from left
                  left: _menuShown ? w * 0.06 : -buttonsWidth - 40,
                  child: AnimatedOpacity(
                    duration: _animDuration,
                    opacity: _menuShown ? 1.0 : 0.0,
                    child: SizedBox(
                      width: buttonsWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageButton(
                            assetPath: 'assets/images/btn_continue.png',
                            width: buttonsWidth,
                            onTap: () {
                              // placeholder: implement real continue logic
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Continue pressed'),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildImageButton(
                            assetPath: 'assets/images/btn_newgame.png',
                            width: buttonsWidth,
                            onTap: () {
                              // placeholder: navigate to a simple "New Game" screen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const NewGameScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          _buildImageButton(
                            assetPath: 'assets/images/btn_exit.png',
                            width: buttonsWidth,
                            onTap: () async {
                              // confirm then exit app
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Exit'),
                                  content: const Text('Exit the game?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(false),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(c).pop(true),
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                              if (result == true) {
                                SystemNavigator.pop();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Logo (centered initially, slides to the right when tapped)
                AnimatedPositioned(
                  duration: _animDuration,
                  curve: _animCurve,
                  top: logoTop,
                  // center horizontally when menu hidden, move to right when shown
                  left: _menuShown ? w * 0.60 : (w / 2) - (logoWidth / 2),
                  child: GestureDetector(
                    onTap: () {
                      if (!_logoTappedOnce) {
                        // first tap: trigger animation
                        setState(() {
                          _menuShown = true;
                          _logoTappedOnce = true;
                        });
                      } else if (!_menuShown) {
                        // safety: ensure menuShown toggles if user taps again quickly
                        setState(() {
                          _menuShown = true;
                        });
                      } else {
                        // optional: do something if logo is tapped again after moved
                      }
                    },
                    child: AnimatedScale(
                      duration: _animDuration,
                      curve: _animCurve,
                      scale: _menuShown ? 0.92 : 1.0,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: logoWidth,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          // fallback UI if image missing
                          return Container(
                            width: logoWidth,
                            height: logoWidth * 0.45,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'JEEP BOX HERO',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.amberAccent,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // image button helper
  Widget _buildImageButton({
    required String assetPath,
    required double width,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Image.asset(
          assetPath,
          width: width,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            // fallback styled container if button image missing
            return Container(
              width: width,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amberAccent.withOpacity(0.6)),
              ),
              child: const Center(
                child: Text(
                  'BUTTON',
                  style: TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Simple placeholder screen for "New Game"
class NewGameScreen extends StatelessWidget {
  const NewGameScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Game')),
      body: const Center(
        child: Text('New Game screen - implement your gameplay here'),
      ),
    );
  }
}
