// ============================================
// FILE 1: shop_screen.dart (Tutorial)
// ============================================
// lib/screens/shop_screen.dart
import 'package:flutter/material.dart';
import '../managers/game_state.dart';
import '../managers/audio_manager.dart';
import './shelves_screen.dart';
import 'package:jeepboxhero/screens/records_screen.dart';
import 'package:jeepboxhero/screens/cart_screen.dart';
import './encounter1_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _dialogueIndex = 0;
  bool _showContinue = false;
  bool _albumFound = false;
  bool _transactionComplete = false;
  bool _customerExiting = false;

  final List<Map<String, dynamic>> _dialogues = [
    {
      'type': 'narration',
      'text':
          'Stacks of vinyls and cassettes line the dusty shelves. Posters of old OPM bands cling to the walls. A guitar leans quietly in the corner.',
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
      'speaker': 'Tito Ramon',
    },
    {
      'type': 'dialogue',
      'text':
          'Check under \'U\'. The name\'s shorter now, just three letters. That\'s how you\'ll spot it.',
      'speaker': 'Tito Ramon',
    },
    {
      'type': 'narration',
      'text':
          '• Move around with the controls to navigate the shelves.\n• Interact with records to inspect them.\n• Locate UDD and bring it back to Tito Ramon.',
      'speaker': null,
    },
  ];

  final List<Map<String, dynamic>> _postFindDialogues = [
    {
      'type': 'dialogue',
      'text':
          'Good work finding that. Now, let\'s handle the transaction properly. Open the cart, write down the details—album, artist—and make sure everything\'s logged neat and proper. Every copy has a story tied to it.',
      'speaker': 'Tito Ramon',
    },
    {
      'type': 'narration',
      'text':
          '• Open the cart (top right corner).\n• Fill in the details of the transaction (UDD – Up Dharma Down).\n• Hand over the "change" to Tito Ramon.',
      'speaker': null,
    },
  ];

  final List<Map<String, dynamic>> _finalDialogues = [
    {
      'type': 'narration',
      'text':
          'Tito Ramon takes the record from your hands, smiling faintly as he runs his fingers over the sleeve.',
      'speaker': null,
    },
    {
      'type': 'dialogue',
      'text':
          'Not bad for your first dig. Remember, every album you pull from these shelves isn\'t just music—it\'s a piece of someone\'s life. Treat it that way.',
      'speaker': 'Tito Ramon',
    },
  ];

  @override
  void initState() {
    super.initState();
    _updateShowContinue();
    // Start persistent shop ambient music (looping)
    try {
      AudioManager()
          .playAmbient('bgm_shop_ambient.mp3', volume: 0.25, loop: true);
    } catch (_) {}
  }

  void _updateShowContinue() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showContinue = true;
        });
      }
    });
  }

  List<Map<String, dynamic>> _getCurrentDialogues() {
    if (!_albumFound) return _dialogues;
    if (!_transactionComplete) return _postFindDialogues;
    return _finalDialogues;
  }

  void _nextDialogue() {
    final currentDialogues = _getCurrentDialogues();

    if (_dialogueIndex < currentDialogues.length - 1) {
      setState(() {
        _dialogueIndex++;
        _showContinue = false;
      });
      _updateShowContinue();
    } else {
      // End of current dialogue set
      if (!_albumFound) {
        _startGameplay();
      } else if (_transactionComplete) {
        _exitCustomer();
      }
      // If album found but transaction not complete, wait for cart interaction
    }
  }

  void _startGameplay() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShelvesScreen(
          targetAlbumTitle: 'UDD',
          targetAlbumArtist: 'Up Dharma Down',
          successNarration:
              'You scan the rows of vinyl until your hand lands on a sleek black-and-white cover with UDD embossed across it. Carefully, you lift it out and walk it over.',
          successDialogue:
              '"There you go. Eyes sharp, hands steady. This one marks the band\'s evolution—less spectacle, more intimacy. Fans call it the sound of moving on."',
          successSpeaker: 'Tito Ramon',
          wrongAlbumHint: 'Remember, check under "U"!',
        ),
      ),
    );

    if (result == true && mounted) {
      // Add UDD album to cart when found
      GameState.addToCart({
        'album': 'UDD',
        'artist': 'Up Dharma Down',
        'imagePath': 'assets/albums/udd_album.png',
      });

      setState(() {
        _albumFound = true;
        _dialogueIndex = 0;
        _showContinue = false;
      });
      _updateShowContinue();
    }
  }

  void _onPurchaseComplete() {
    setState(() {
      _transactionComplete = true;
      _dialogueIndex = 0;
      _showContinue = false;
    });
    _updateShowContinue();
  }

  void _exitCustomer() {
    setState(() {
      _customerExiting = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        // Tutorial complete - navigate to Encounter 1
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Encounter1Screen()),
        );
      }
    });
  }

  bool _isTitoSpeaking() {
    final currentDialogues = _getCurrentDialogues();
    if (_dialogueIndex >= currentDialogues.length) return false;
    return currentDialogues[_dialogueIndex]['type'] == 'dialogue';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final currentDialogues = _getCurrentDialogues();
    final currentDialogue = _dialogueIndex < currentDialogues.length
        ? currentDialogues[_dialogueIndex]
        : null;

    return Scaffold(
      body: GestureDetector(
        onTap: _nextDialogue,
        child: Stack(
          children: [
            // Background
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/shop_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey[300]);
                },
              ),
            ),

            // Customer character
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              left: _customerExiting ? -w * 0.6 : w * 0.05,
              right: _customerExiting ? w * 1.2 : w * 0.40,
              top: h * 0.05,
              bottom: h * 0.28,
              child: Image.asset(
                _isTitoSpeaking()
                    ? 'assets/characters/tito_ramon_speaking.png'
                    : 'assets/characters/tito_ramon.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.transparent);
                },
              ),
            ),

            // Table
            Positioned(
              left: 0,
              right: 0,
              bottom: -h * 0.05,
              height: h * 0.38,
              child: Image.asset(
                'assets/ui/table.png',
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.brown[200]);
                },
              ),
            ),

            // Vinyl cover on table
            if (_albumFound)
              Positioned(
                left: w * 0.35,
                bottom: h * 0.12,
                width: w * 0.25,
                height: w * 0.25,
                child: Image.asset(
                  'assets/albums/udd_album.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[400],
                      child: const Center(child: Icon(Icons.album, size: 64)),
                    );
                  },
                ),
              ),

            // Folder
            Positioned(
              left: w * 0.00001, 
              bottom: h * 0.05,
              width: w * 0.38,
              height: h * 0.46,
              child: GestureDetector(
                onTap: () => debugPrint('Folder tapped'),
                child: Image.asset(
                  'assets/ui/closed_folder.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.transparent);
                  },
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
                child: Image.asset(
                  'assets/ui/cash_box.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.transparent);
                  },
                ),
              ),
            ),

            // Dialogue Box
            if (!_customerExiting && currentDialogue != null)
              Positioned(
                left: w * 0.04,
                right: w * 0.04,
                bottom: h * 0.01,
                child: Container(
                  constraints: BoxConstraints(maxHeight: h * 0.25),
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
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
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

            // Top left: Back arrow and Phone icon
            Positioned(
              left: 16,
              top: 16,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    child: Image.asset(
                      'assets/ui/back_arrow.png',
                      width: w * 0.055,
                      height: w * 0.055,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: w * 0.055,
                          height: w * 0.055,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_back, size: 30),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => debugPrint('Phone tapped'),
                    child: Image.asset(
                      'assets/ui/tablet_icon.png',
                      width: w * 0.055,
                      height: w * 0.055,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: w * 0.055,
                          height: w * 0.055,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.phone, size: 30),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Top right: Cart and Records icons with badges
            Positioned(
              right: 16,
              top: 16,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );

                      if (result == 'purchase_complete' && mounted) {
                        _onPurchaseComplete();
                      } else if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(
                          'assets/ui/cart_icon.png',
                          width: w * 0.055,
                          height: w * 0.055,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: w * 0.055,
                              height: w * 0.055,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_cart,
                                size: 30,
                              ),
                            );
                          },
                        ),
                        if (GameState.cartItems.isNotEmpty)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '${GameState.cartItems.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecordsScreen(),
                        ),
                      );
                      if (mounted) setState(() {});
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Image.asset(
                          'assets/ui/records_icon.png',
                          width: w * 0.055,
                          height: w * 0.055,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: w * 0.055,
                              height: w * 0.055,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.library_music,
                                size: 30,
                              ),
                            );
                          },
                        ),
                        if (GameState.records.isNotEmpty)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '${GameState.records.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
