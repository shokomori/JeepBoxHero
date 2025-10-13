import 'components/ui/phone_save_load_popup.dart';
import 'screens/encounter2_screen.dart';
// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/shop_screen.dart';
import 'managers/audio_manager.dart';

const supabaseUrl = 'https://aolfomgjqcqeaewwieup.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvbGZvbWdqcWNxZWFld3dpZXVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzNTQ5NzcsImV4cCI6MjA3NTkzMDk3N30.LEkKM9HU_Ws7kPjcrMN-cgvll7AiNdu7vjj_PaZ-6-0';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Supabase first (before anything else that depends on it)
  try {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: true,
    );

    if (kDebugMode) {
      print('✅ Supabase initialized successfully');
    }
  } catch (e) {
    print('❌ Supabase initialization failed: $e');
  }

  // ✅ Initialize audio manager (non-blocking but inside try/catch)
  try {
    await AudioManager().initialize();
  } catch (e) {
    print('AudioManager initialize failed: $e');
  }

  // Debug: verify which home widget is used
  if (kDebugMode) {
    print('main.dart: about to run JeepBoxApp');
  }

  runApp(const JeepBoxApp());
}

class JeepBoxApp extends StatelessWidget {
  const JeepBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('JeepBoxApp.build: MaterialApp.home = MainMenuScreen');
    }
    return MaterialApp(
      title: 'Jeep Box Hero',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Courier',
      ),
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
  bool _showLoadDialog = false;
  List<Map<String, dynamic>> _saveStates = [];
  bool _loadingStates = false;
  String? _loadError;

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
    // Start menu BGM on user gesture to satisfy browser autoplay policies
    try {
      AudioManager().playBgm('menu_music.mp3', volume: 0.25);
    } catch (_) {}
  }

  void _onContinueTap() async {
    showDialog(
      context: context,
      builder: (context) => PhoneSaveLoadPopup(
        encounterId: 'main_menu',
        progress: {},
        onLoad: (loadedState) {
          if (loadedState != null) {
            // You can route to the correct encounter here
            final encounter = loadedState['encounter'] ?? 'shop';
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) {
                  // Route to the correct screen based on encounter
                  // You can expand this logic for all encounters
                  if (encounter == 'encounter2') {
                    return const Encounter2Screen();
                  }
                  // Add more encounter screens as needed
                  return ShopScreen();
                },
              ),
            );
          }
        },
      ),
    );
  }

  void _onSelectSaveState(Map<String, dynamic> state) async {
    // TODO: Restore game state from selected save state
    // For now, just close dialog and go to ShopScreen
    setState(() {
      _showLoadDialog = false;
    });
    try {
      await AudioManager().stopBgm();
    } catch (_) {}
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ShopScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _onCloseLoadDialog() {
    setState(() {
      _showLoadDialog = false;
    });
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

  Future<void> _onNarrationTap() async {
    if (!_narrationComplete) {
      setState(() {
        _visibleText = _fullText;
        _narrationComplete = true;
      });
      return;
    }

    // Stop menu BGM then navigate to ShopScreen
    try {
      await AudioManager().stopBgm();
    } catch (_) {}

    // Navigate to ShopScreen instead of GameScreen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShopScreen(), // Removed const
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
                        ...List.generate(3, (index) {
                          final buttonFiles = [
                            'assets/ui/start.png',
                            'assets/ui/continue.png',
                            'assets/ui/quit.png'
                          ];
                          return Positioned(
                            left: buttonX,
                            top: buttonStartY + (index * buttonSpacing),
                            child: Opacity(
                              opacity: opacity,
                              child: GestureDetector(
                                onTap: () {
                                  if (index == 0) _startNarration();
                                  if (index == 1) _onContinueTap();
                                  if (index == 2) widget.onQuit?.call();
                                },
                                child: Image.asset(
                                  buttonFiles[index],
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        }),

                      // Load State Dialog
                      if (_showLoadDialog)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withOpacity(0.7),
                            child: Center(
                              child: Container(
                                width: size.width * 0.7,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Load Save State',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: _onCloseLoadDialog,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (_loadingStates)
                                      const CircularProgressIndicator(),
                                    if (_loadError != null)
                                      Text(_loadError!,
                                          style: const TextStyle(
                                              color: Colors.red)),
                                    if (!_loadingStates &&
                                        _saveStates.isEmpty &&
                                        _loadError == null)
                                      const Text('No save states found.'),
                                    if (!_loadingStates &&
                                        _saveStates.isNotEmpty)
                                      SizedBox(
                                        height: 220,
                                        child: ListView.builder(
                                          itemCount: _saveStates.length,
                                          itemBuilder: (context, idx) {
                                            final state = _saveStates[idx];
                                            return Card(
                                              child: ListTile(
                                                title: Text(
                                                    'Encounter: ${state['encounter'] ?? 'Unknown'}'),
                                                subtitle: Text(
                                                    'Saved: ${state['timestamp'] ?? ''}'),
                                                onTap: () =>
                                                    _onSelectSaveState(state),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

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
