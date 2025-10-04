// lib/screens/shop_screen.dart
import 'package:flutter/material.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _dialogueIndex = 0;
  bool _showContinue = false;

  final List<Map<String, dynamic>> _dialogues = [
    {
      'type': 'narration',
      'text':
          '[Scene: Inside the shop]\n\nStacks of vinyls and cassettes line the dusty shelves. Posters of old OPM bands cling to the walls. A guitar leans quietly in the corner.',
      'speaker': null,
    },
    {
      'type': 'dialogue',
      'text':
          'Ah, you made it! Welcome to Jeep Box Records. Back in my day, this place was more than just a shop. It was a stage. Every record here has a story, and today, you\'ll help me keep those stories alive.',
      'speaker': 'Tito Ramon',
    },
    {
      'type': 'player',
      'text':
          'I\'ve never worked in a record shop before… I don\'t even know where to start.',
      'speaker': 'You',
    },
    {
      'type': 'dialogue',
      'text':
          'Don\'t worry. Music has a way of teaching. Some customers will come looking for the hits, others for the hidden gems. Your job is simple: listen, learn, and help them find the soundtrack to their lives.',
      'speaker': 'Tito Ramon',
    },
    {
      'type': 'narration',
      'text':
          '[Tito Ramon hands you a faded receipt book and points to the shelves.]',
      'speaker': null,
    },
    {
      'type': 'dialogue',
      'text':
          'Now, go on. Let\'s see if you\'ve got the rhythm for this place.',
      'speaker': 'Tito Ramon',
    },
    {
      'type': 'dialogue',
      'text':
          'Alright, rookie. First lesson\'s on me. Let\'s see if you can find something special—Up Dharma Down\'s last album, UDD. People say it\'s their most mature work, stripped down but honest. Synths, groove, heartache, all in one.',
      'speaker': 'Tito Ramon (smirking)',
    },
    {
      'type': 'dialogue',
      'text':
          'Check under \'U\'. The name\'s shorter now, just three letters. That\'s how you\'ll spot it.',
      'speaker': 'Tito Ramon (pointing toward the shelves)',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showContinue = true;
        });
      }
    });
  }

  void _nextDialogue() {
    if (_dialogueIndex < _dialogues.length - 1) {
      setState(() {
        _dialogueIndex++;
        _showContinue = false;
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showContinue = true;
          });
        }
      });
    } else {
      // Dialogue finished - you can navigate away or show shop UI
      debugPrint('Dialogue finished!');
    }
  }

  Widget _asset({
    required String assetPath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey.withOpacity(0.3),
        );
      },
    );
  }

  bool _isTitoSpeaking() {
    final current = _dialogues[_dialogueIndex];
    return current['type'] == 'dialogue';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final currentDialogue = _dialogues[_dialogueIndex];

    return Scaffold(
      body: GestureDetector(
        onTap: _nextDialogue,
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: _asset(
                assetPath: 'assets/backgrounds/shop_bg.png',
                fit: BoxFit.cover,
              ),
            ),

            // Customer character - switches between normal and speaking
            Positioned(
              left: w * 0.20,
              right: w * 0.20,
              top: h * 0.05,
              bottom: h * 0.28,
              child: _asset(
                assetPath: _isTitoSpeaking()
                    ? 'assets/characters/tito_ramon_speaking.png'
                    : 'assets/characters/tito_ramon.png',
                fit: BoxFit.contain,
              ),
            ),

            // Table
            Positioned(
              left: 0,
              right: 0,
              bottom: -h * 0.05,
              height: h * 0.38,
              child: _asset(
                assetPath: 'assets/ui/table.png',
                fit: BoxFit.fill,
              ),
            ),

            // Folder
            Positioned(
              left: w * 0.03,
              bottom: h * 0.05,
              width: w * 0.38,
              height: h * 0.46,
              child: GestureDetector(
                onTap: () => debugPrint('Folder tapped'),
                child: _asset(
                  assetPath: 'assets/ui/closed_folder.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Cash box
            Positioned(
              right: -w * 0.15,
              bottom: -h * 0.03,
              width: w * 0.85,
              height: h * 0.65,
              child: GestureDetector(
                onTap: () => debugPrint('Cash box tapped'),
                child: _asset(
                  assetPath: 'assets/ui/cash_box.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Universal Dialogue Box (Bottom)
            Positioned(
              left: w * 0.04,
              right: w * 0.04,
              bottom: h * 0.01,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: h * 0.25,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.035,
                  vertical: h * 0.015,
                ),
                decoration: BoxDecoration(
                  color: currentDialogue['type'] == 'narration'
                      ? Colors.black.withOpacity(0.75)
                      : Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentDialogue['type'] == 'narration'
                        ? Colors.white70
                        : Colors.black87,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRect(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: currentDialogue['type'] == 'narration'
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      if (currentDialogue['speaker'] != null)
                        Text(
                          currentDialogue['speaker'],
                          style: TextStyle(
                            fontSize: w * 0.017,
                            fontWeight: FontWeight.bold,
                            color: currentDialogue['type'] == 'narration'
                                ? Colors.white
                                : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (currentDialogue['speaker'] != null)
                        SizedBox(height: h * 0.006),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            currentDialogue['text'] ?? '',
                            style: TextStyle(
                              fontSize: w * 0.014,
                              height: 1.35,
                              color: currentDialogue['type'] == 'narration'
                                  ? Colors.white
                                  : Colors.black,
                              fontStyle: currentDialogue['type'] == 'narration'
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                            textAlign: currentDialogue['type'] == 'narration'
                                ? TextAlign.center
                                : TextAlign.left,
                          ),
                        ),
                      ),
                      if (_showContinue) ...[
                        SizedBox(height: h * 0.006),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '▼ Tap to continue',
                            style: TextStyle(
                              fontSize: w * 0.011,
                              color: currentDialogue['type'] == 'narration'
                                  ? Colors.white70
                                  : Colors.black54,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Top left icons
            Positioned(
              left: 16,
              top: 16,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => debugPrint('Settings'),
                    child: _asset(
                      assetPath: 'assets/ui/settings_icon.png',
                      width: w * 0.055,
                      height: w * 0.055,
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => debugPrint('Tablet'),
                    child: _asset(
                      assetPath: 'assets/ui/tablet_icon.png',
                      width: w * 0.055,
                      height: w * 0.055,
                    ),
                  ),
                ],
              ),
            ),

            // Top right icons
            Positioned(
              right: 16,
              top: 16,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => debugPrint('Cart'),
                    child: _asset(
                      assetPath: 'assets/ui/cart_icon.png',
                      width: w * 0.055,
                      height: w * 0.055,
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => debugPrint('Records'),
                    child: _asset(
                      assetPath: 'assets/ui/records_icon.png',
                      width: w * 0.055,
                      height: w * 0.055,
                    ),
                  ),
                ],
              ),
            ),

            // Back arrow
            Positioned(
              left: 16,
              top: h * 0.48,
              child: GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                child: _asset(
                  assetPath: 'assets/ui/back_arrow.png',
                  width: w * 0.075,
                  height: w * 0.075,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
