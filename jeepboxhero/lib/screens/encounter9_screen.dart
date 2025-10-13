// lib/screens/encounter9_screen.dart
import 'package:flutter/material.dart';
import '../managers/game_state.dart';
import '../managers/audio_manager.dart';
import './shelves_screen.dart';
import 'package:jeepboxhero/screens/records_screen.dart';
import 'package:jeepboxhero/screens/cart_screen.dart';
import 'package:jeepboxhero/screens/encounter10_screen.dart';
import '../components/ui/phone_save_load_popup.dart';

class Encounter9Screen extends StatefulWidget {
  final Map<String, dynamic>? progress;
  const Encounter9Screen({this.progress, super.key});

  @override
  State<Encounter9Screen> createState() => _Encounter9ScreenState();
}

class _Encounter9ScreenState extends State<Encounter9Screen> {
  int _dialogueIndex = 0;
  bool _showContinue = false;
  bool _albumFound = false;
  bool _transactionComplete = false;
  bool _customerExiting = false;
  String? _selectedOption;

  final List<Map<String, dynamic>> _dialogues = [
    {
      'type': 'narration',
      'text':
          '[Scene: Jeep Box Records – P-Pop Shelf]\n\nA bubbly girl skips in, pastel nails tapping on her phone as she scrolls through fancams.',
      'speaker': null,
    },
    {
      'type': 'dialogue',
      'text':
          'Omg! Please tell me you still have it—the pastel diary album, doodles on the cover like teenage secrets. Every track is like falling in love for the first time. My bias owns this era.',
      'speaker': 'Bibi G. (excited)',
    },
    {
      'type': 'dialogue',
      'text':
          'Ah, the new queens of pop. Their fans fill the shop faster than my records do.',
      'speaker': 'Tito Ramon (laughing)',
    },
    {
      'type': 'dialogue',
      'text':
          'I need it for my collection. Pink cover, glitter doodles, everything so… cute it hurts.',
      'speaker': 'Bibi G. (pouting)',
    },
  ];

  final List<Map<String, dynamic>> _postChoiceDialogues = [
    {
      'type': 'narration',
      'text': 'A bright pastel sleeve appears, doodled with hearts and notes.',
      'speaker': null,
    },
  ];

  final List<Map<String, dynamic>> _postFindDialogues = [
    {
      'type': 'dialogue',
      'text': 'Yes! Talaarawan era supremacy! I love them so much!',
      'speaker': 'Bibi G. (squealing)',
    },
    {
      'type': 'dialogue',
      'text': 'Careful, Bibi. Don\'t faint before the checkout.',
      'speaker': 'Tito Ramon (smiling)',
    },
    {
      'type': 'narration',
      'text': 'She skips out, hugging the record.',
      'speaker': null,
    },
  ];

  final List<Map<String, dynamic>> _finalDialogues = [
    {
      'type': 'narration',
      'text': 'She skips out, hugging the record.',
      'speaker': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _updateShowContinue();
    try {
      AudioManager().playBgm('bgm_bibig_theme.mp3', volume: 0.18, loop: true);
    } catch (_) {}
    try {
      AudioManager().playSfx('sfx_bell_customer.mp3');
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
    if (_selectedOption == null) return _dialogues;
    if (!_albumFound) return _postChoiceDialogues;
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
      if (_selectedOption == null) {
        setState(() {
          _showContinue = false;
        });
      } else if (!_albumFound) {
        _startGameplay();
      } else if (_transactionComplete) {
        _exitCustomer();
      }
    }
  }

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
      _dialogueIndex = 0;
      _showContinue = false;
    });
    _updateShowContinue();
  }

  void _startGameplay() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShelvesScreen(
          targetAlbumTitle: 'Talaarawan',
          targetAlbumArtist: 'Bini',
          successNarration:
              'A bright pastel sleeve appears, doodled with hearts and notes.',
          successDialogue:
              '"Yes! Talaarawan era supremacy! I love them so much!"',
          successSpeaker: 'Bibi G. (squealing)',
          wrongAlbumHint:
              'Look for a pastel diary-like sleeve covered in doodles in the P-Pop shelf.',
        ),
      ),
    );

    if (result == true && mounted) {
      GameState.addToCart({
        'album': 'Talaarawan',
        'artist': 'Bini',
        'imagePath': 'assets/albums/bini_talaarawan.png',
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
    Future.delayed(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      try {
        AudioManager().stopBgm();
      } catch (_) {}

      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Encounter10Screen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offset =
                Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
                    .animate(animation);
            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(animation);
            return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: offset, child: child));
          },
        ));
      }
    });
  }

  bool _isCustomerSpeaking() {
    final currentDialogues = _getCurrentDialogues();
    if (_dialogueIndex >= currentDialogues.length) return false;
    final speaker = currentDialogues[_dialogueIndex]['speaker'];
    return speaker != null && speaker.toString().contains('Bibi G');
  }

  bool _isTitoSpeaking() {
    final currentDialogues = _getCurrentDialogues();
    if (_dialogueIndex >= currentDialogues.length) return false;
    final speaker = currentDialogues[_dialogueIndex]['speaker'];
    return speaker != null && speaker.toString().contains('Tito Ramon');
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

    final showOptions = _selectedOption == null &&
        _dialogueIndex >= _dialogues.length - 1 &&
        _showContinue;

    return Scaffold(
      body: GestureDetector(
        onTap: showOptions ? null : _nextDialogue,
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

            // Top left: Back arrow and Phone icon
            Positioned(
              left: 16,
              top: 16,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (route) => false);
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
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => PhoneSaveLoadPopup(
                          encounterId: 'encounter9',
                          progress: {
                            'dialogueIndex': _dialogueIndex,
                            'albumFound': _albumFound,
                            'transactionComplete': _transactionComplete,
                            'selectedOption': _selectedOption,
                            'recordCollection': GameState.records,
                          },
                          onLoad: (state) {
                            if (state != null) {
                              setState(() {
                                _dialogueIndex =
                                    state['progress']['dialogueIndex'] ?? 0;
                                _albumFound =
                                    state['progress']['albumFound'] ?? false;
                                _transactionComplete = state['progress']
                                        ['transactionComplete'] ??
                                    false;
                                _selectedOption =
                                    state['progress']['selectedOption'];
                                if (state['progress']['recordCollection'] !=
                                    null) {
                                  GameState.records =
                                      List<Map<String, dynamic>>.from(
                                          state['progress']
                                              ['recordCollection']);
                                }
                              });
                            }
                          },
                        ),
                      );
                    },
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
                              child: const Icon(Icons.shopping_cart, size: 30),
                            );
                          },
                        ),
                        if (GameState.cartItems.isNotEmpty)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
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
                              child: const Icon(Icons.library_music, size: 30),
                            );
                          },
                        ),
                        if (GameState.records.isNotEmpty)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
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

            // Bibi character (left)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              left: _customerExiting ? -w * 0.6 : w * 0.12,
              right: _customerExiting ? w * 1.2 : w * 0.30,
              top: h * 0.06,
              bottom: h * 0.28,
              child: Image.asset(
                _isCustomerSpeaking()
                    ? 'assets/characters/bibi_talking.png'
                    : 'assets/characters/bibi.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.transparent);
                },
              ),
            ),

            // Tito Ramon
            Positioned(
              right: w * 0.05,
              top: h * 0.15,
              width: w * 0.25,
              height: h * 0.40,
              child: Opacity(
                opacity: 0.7,
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

            // Album on table
            if (_albumFound)
              Positioned(
                left: w * 0.35,
                bottom: h * 0.12,
                width: w * 0.25,
                height: w * 0.25,
                child: Image.asset(
                  'assets/albums/bini_talaarawan.png',
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

            // Dialogue Box or Options
            if (!_customerExiting && (currentDialogue != null || showOptions))
              Positioned(
                left: w * 0.04,
                right: w * 0.04,
                bottom: h * 0.01,
                child: showOptions
                    ? _buildDialogueOptions(w, h)
                    : _buildDialogueBox(currentDialogue!, w, h),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogueBox(Map<String, dynamic> dialogue, double w, double h) {
    return Container(
      constraints: BoxConstraints(maxHeight: h * 0.25),
      padding: EdgeInsets.symmetric(horizontal: w * 0.035, vertical: h * 0.015),
      decoration: BoxDecoration(
        color: dialogue['type'] == 'narration'
            ? Colors.black.withOpacity(0.75)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              dialogue['type'] == 'narration' ? Colors.white70 : Colors.black87,
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
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: dialogue['type'] == 'narration'
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (dialogue['speaker'] != null)
            Text(
              dialogue['speaker'],
              style: TextStyle(
                fontSize: w * 0.017,
                fontWeight: FontWeight.bold,
                color: dialogue['type'] == 'narration'
                    ? Colors.white
                    : Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (dialogue['speaker'] != null) SizedBox(height: h * 0.006),
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                dialogue['text'] ?? '',
                style: TextStyle(
                  fontSize: w * 0.014,
                  height: 1.35,
                  color: dialogue['type'] == 'narration'
                      ? Colors.white
                      : Colors.black,
                  fontStyle: dialogue['type'] == 'narration'
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
                textAlign: dialogue['type'] == 'narration'
                    ? TextAlign.center
                    : TextAlign.left,
              ),
            ),
          ),
          if (_showContinue && !(_dialogueIndex >= _dialogues.length - 1)) ...[
            SizedBox(height: h * 0.006),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '▼ Tap to continue',
                style: TextStyle(
                  fontSize: w * 0.011,
                  color: dialogue['type'] == 'narration'
                      ? Colors.white70
                      : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDialogueOptions(double w, double h) {
    final options = [
      {'text': 'Sounds like sunshine in vinyl form.', 'value': 'A'},
      {'text': 'Let\'s find your queens.', 'value': 'B'},
      {'text': 'Music and diary pages—perfect combo.', 'value': 'C'},
    ];

    return Container(
      constraints: BoxConstraints(maxHeight: h * 0.38),
      padding: EdgeInsets.symmetric(horizontal: w * 0.035, vertical: h * 0.008),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black87, width: 2.5),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your response:',
            style: TextStyle(
              fontSize: w * 0.016,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: h * 0.008),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: h * 0.26),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.map((option) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: h * 0.008),
                    child: InkWell(
                      onTap: () => _selectOption(option['value']!),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: w * 0.02, vertical: h * 0.01),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.grey[400]!, width: 1.5),
                        ),
                        child: Text(
                          '${option['value']}: ${option['text']}',
                          style: TextStyle(
                              fontSize: w * 0.014, color: Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
