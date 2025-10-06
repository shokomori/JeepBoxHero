// lib/screens/shop_screen.dart
import 'package:flutter/material.dart';
import './shelves_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _dialogueIndex = 0;
  bool _showContinue = false;
  bool _albumFound = false;
  bool _showReceiptBook = false;
  bool _showReceipt = false;
  bool _customerExiting = false;
  final TextEditingController _albumController = TextEditingController();
  final TextEditingController _artistController = TextEditingController();

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
    {
      'type': 'narration',
      'text':
          '[Gameplay Instructions]\n\n• Move around with the controls to navigate the shelves.\n• Interact with records to inspect them.\n• Locate UDD and bring it back to Tito Ramon.',
      'speaker': null,
    },
  ];

  final List<Map<String, dynamic>> _postFindDialogues = [
    {
      'type': 'dialogue',
      'text':
          'Second lesson: sales. Even if it\'s me, treat it like the real thing. Write down the details—album, artist—and make sure everything\'s logged neat and proper. Every copy has a story tied to it.',
      'speaker': 'Tito Ramon (pulling out the receipt book)',
    },
    {
      'type': 'narration',
      'text':
          '[Gameplay Prompt]\n\n• Open the receipt book.\n• Fill in the details of the transaction (UDD – Up Dharma Down).\n• Hand over the "change" to Tito Ramon.',
      'speaker': null,
    },
  ];

  final List<Map<String, dynamic>> _finalDialogues = [
    {
      'type': 'narration',
      'text':
          '[Narration]\n\nTito Ramon takes the record from your hands, smiling faintly as he runs his fingers over the sleeve.',
      'speaker': null,
    },
    {
      'type': 'dialogue',
      'text':
          'Not bad for your first dig. Remember, every album you pull from these shelves isn\'t just music—it\'s a piece of someone\'s life. Treat it that way.',
      'speaker': 'Tito Ramon (patting your shoulder)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _updateShowContinue();
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

  @override
  void dispose() {
    _albumController.dispose();
    _artistController.dispose();
    super.dispose();
  }

  void _nextDialogue() {
    final currentDialogues = _albumFound
        ? (_showReceiptBook ? _finalDialogues : _postFindDialogues)
        : _dialogues;

    if (_dialogueIndex < currentDialogues.length - 1) {
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
      if (!_albumFound) {
        _startGameplay();
      } else if (_albumFound && !_showReceiptBook) {
        setState(() {
          _showReceiptBook = true;
        });
      }
    }
  }

  void _startGameplay() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ShelvesScreen()),
    );

    if (result == true && mounted) {
      setState(() {
        _albumFound = true;
        _dialogueIndex = 0;
        _showContinue = false;
      });
      _updateShowContinue();
    }
  }

  void _submitReceipt() {
    final album = _albumController.text.trim().toLowerCase();
    final artist = _artistController.text.trim().toLowerCase();

    if (album == 'udd' && artist == 'up dharma down') {
      setState(() {
        _showReceiptBook = false;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _showReceipt = true;
          });

          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _customerExiting = true;
              });

              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) {
                  setState(() {
                    _showReceipt = false;
                    _customerExiting = false;
                    _dialogueIndex = 0;
                    _showContinue = false;
                  });
                  _updateShowContinue();
                }
              });
            }
          });
        }
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Not quite right...'),
          content: const Text(
            'Double-check the album and artist name. Remember, it\'s UDD by Up Dharma Down.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildReceiptBook() {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Container(
        width: size.width * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8DC),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
          border: Border.all(color: Colors.brown, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '📖 RECEIPT BOOK',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jeep Box Records',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(height: 32, thickness: 2),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Transaction Details:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _albumController,
              decoration: InputDecoration(
                labelText: 'Album Name',
                hintText: 'Enter album name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _artistController,
              decoration: InputDecoration(
                labelText: 'Artist Name',
                hintText: 'Enter artist name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showReceiptBook = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitReceipt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isTitoSpeaking() {
    final currentDialogues = _albumFound
        ? (_showReceiptBook ? _finalDialogues : _postFindDialogues)
        : _dialogues;
    final current = currentDialogues[_dialogueIndex];
    return current['type'] == 'dialogue';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    final currentDialogues = _albumFound
        ? (_showReceiptBook ? _finalDialogues : _postFindDialogues)
        : _dialogues;
    final currentDialogue = currentDialogues[_dialogueIndex];

    return Scaffold(
      body: GestureDetector(
        onTap: _showReceiptBook || _showReceipt ? null : _nextDialogue,
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
              left: _customerExiting ? -w * 0.6 : w * 0.20,
              right: _customerExiting ? w * 1.2 : w * 0.20,
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
                      child: const Center(
                        child: Icon(Icons.album, size: 64),
                      ),
                    );
                  },
                ),
              ),

            // Receipt on table
            if (_showReceipt)
              Positioned(
                left: w * 0.35,
                bottom: h * 0.15,
                width: w * 0.3,
                height: w * 0.4,
                child: Image.asset(
                  'assets/receipts/udd.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.white,
                      child: const Center(
                        child: Icon(Icons.receipt, size: 64),
                      ),
                    );
                  },
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

            // Receipt Book Overlay
            if (_showReceiptBook)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: _buildReceiptBook(),
                ),
              ),

            // Dialogue Box
            if (!_showReceiptBook &&
                !_showReceipt &&
                !_customerExiting &&
                _dialogueIndex >= 0 &&
                _dialogueIndex < currentDialogues.length)
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

            // Top left icons
            if (!_showReceiptBook && !_showReceipt)
              Positioned(
                left: 16,
                top: 16,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => debugPrint('Settings'),
                      child: Image.asset(
                        'assets/ui/settings_icon.png',
                        width: w * 0.055,
                        height: w * 0.055,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.settings);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => debugPrint('Tablet'),
                      child: Image.asset(
                        'assets/ui/tablet_icon.png',
                        width: w * 0.055,
                        height: w * 0.055,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.tablet);
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Top right icons
            if (!_showReceiptBook && !_showReceipt)
              Positioned(
                right: 16,
                top: 16,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => debugPrint('Cart'),
                      child: Image.asset(
                        'assets/ui/cart_icon.png',
                        width: w * 0.055,
                        height: w * 0.055,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.shopping_cart);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => debugPrint('Records'),
                      child: Image.asset(
                        'assets/ui/records_icon.png',
                        width: w * 0.055,
                        height: w * 0.055,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.library_music);
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Back arrow
            if (!_showReceiptBook && !_showReceipt)
              Positioned(
                left: 16,
                top: h * 0.48,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Image.asset(
                    'assets/ui/back_arrow.png',
                    width: w * 0.075,
                    height: w * 0.075,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.arrow_back, size: 48);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
