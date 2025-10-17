// lib/screens/encounter7_screen.dart
import 'package:flutter/material.dart';
import '../managers/game_state.dart';
import 'encounter_features/vinyl_table_screen.dart';
import '../managers/audio_manager.dart';
import './shelves_screen.dart';
import 'package:jeepboxhero/screens/records_screen.dart';
import 'package:jeepboxhero/screens/cart_screen.dart';
import 'package:jeepboxhero/screens/encounter8_screen.dart';
import '../components/ui/phone_save_load_popup.dart';
import 'encounter_features/receipt_table_screen.dart';

class Encounter7Screen extends StatefulWidget {
  final Map<String, dynamic>? progress;
  const Encounter7Screen({this.progress, super.key});

  @override
  State<Encounter7Screen> createState() => _Encounter7ScreenState();
}

class _Encounter7ScreenState extends State<Encounter7Screen> {
  int _dialogueIndex = 0;
  bool _showContinue = false;
  bool _albumFound = false;
  bool _transactionComplete = false;
  bool _customerExiting = false;
  String? _selectedOption;

  final List<Map<String, dynamic>> _dialogues = [
    {
      'type': 'narration',
      'text': 'A woman sways inside, her bright jacket catching every light.',
      'speaker': null,
    },
    {
      'type': 'dialogue',
      'text':
          'Oh, honey! These floors remember me! I\'m looking for that record—the one that turned every sala into a dance floor. The grooves were simple, sweet, made for hips and heartbeats. Everyone knew the steps.',
      'speaker': 'Didi Disco',
    },
    {
      'type': 'dialogue',
      'text':
          'You mean the queens of primetime? Even my tito tried those moves after a few drinks.',
      'speaker': 'Tito Ramon',
    },
    {
      'type': 'dialogue',
      'text':
          'The cover was fierce—sparkles, sass, a group that looked unstoppable. That\'s the fever I need back.',
      'speaker': 'Didi Disco',
    },
        {
      'type': 'dialogue',
      'text':
          'The cover was fierce—sparkles, sass, a group that looked unstoppable. That\'s the fever I need back.',
      'speaker': 'Didi Disco',
    },
  ];

  final List<Map<String, dynamic>> _postChoiceDialogues = [
    {
      'type': 'narration',
      'text':
          '• Check the OPM/Pop section.\n• Look for a bold, glittering cover—women striking fierce poses under studio lights.\n• It’s all energy and confidence—sequins, smiles, and attitude that could stop traffic.',
      'speaker': null,
    },
  ];

  final List<Map<String, dynamic>> _postFindDialogues = [
    {
      'type': 'dialogue',
      'text': 'Yes! My queens! This is how you bring life to the party.',
      'speaker': 'Didi Disco',
    },
    {
      'type': 'dialogue',
      'text':
          'Careful, Didi. This shop\'s floor isn\'t built for your footwork.',
      'speaker': 'Tito Ramon',
    }
  ];

  final List<Map<String, dynamic>> _finalDialogues = [
    {
      'type': 'narration',
      'text': 'She winks, record in hand, already dancing out the door.',
      'speaker': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _updateShowContinue();
    try {
      AudioManager().playBgm('bgm_didi_theme.mp3', volume: 0.18, loop: true);
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
          targetAlbumTitle: 'Unang Putok',
          targetAlbumArtist: 'Sexbomb Girls',
          successNarration:
              'Flipping through the disco section, you find a sleeve bursting with glam—bold colors, a fierce all-girl group ready to perform.',
          successDialogue:
              '"Yes! My queens! This is how you bring life to the party."',
          successSpeaker: 'Didi Disco',
          wrongAlbumHint:
              'Look for a bold, glammed-up all-girl group cover in the Disco aisle.',
        ),
      ),
    );

    if (result == true && mounted) {
      GameState.addToCart({
        'album': 'Unang Putok',
        'artist': 'Sexbomb Girls',
        'imagePath': 'assets/albums/sexbomb_unang.png',
      });

      // Vinyl placement SFX disabled for now
      // try {
      //   AudioManager().playSfx('sfx_vinyl_place.mp3');
      // } catch (_) {}

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
              const Encounter8Screen(),
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
    return speaker != null && speaker.toString().contains('Didi Disco');
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
            Positioned.fill(
              child: Image.asset(
                'assets/backgrounds/shop_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey[300]);
                },
              ),
            ),
            // Phone icon overlay for save/load
            Positioned(
              right: 20,
              top: 20,
              child: IconButton(
                icon: Icon(Icons.phone_android,
                    size: 32, color: Colors.deepPurple),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => PhoneSaveLoadPopup(
                      encounterId: 'encounter7',
                      progress: {
                        'dialogueIndex': _dialogueIndex,
                        'albumFound': _albumFound,
                        'transactionComplete': _transactionComplete,
                        'selectedOption': _selectedOption,
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
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            // Didi Disco character (left)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              left: _customerExiting ? -w * 0.6 : w * 0.12,
              right: _customerExiting ? w * 1.2 : w * 0.50,
              top: h * 0.06,
              bottom: h * 0.28,
              child: Image.asset(
                _isCustomerSpeaking()
                    ? 'assets/characters/didi_talking.png'
                    : 'assets/characters/didi.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.transparent);
                },
              ),
            ),

            // Tito Ramon (behind counter)
            Positioned(
              right: w * 0.05,
              top: h * 0.15,
              width: w * 0.25,
              height: h * 0.40,
              child: Opacity(
                opacity: 0.0,
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

            // Vinyl cover on table
            if (_albumFound)
              Positioned(
                left: w * 0.35,
                bottom: h * 0.12,
                width: w * 0.25,
                height: w * 0.25,
                child: Image.asset(
                  'assets/albums/sexbomb_unang.png',
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
                  onTap: _albumFound
                      ? () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceiptTableScreen(encounterNumber: 7),
                            ),
                          );
                          if (result == 'purchase_complete' && mounted) {
                            setState(() {
                              _transactionComplete = true;
                              _dialogueIndex = 0;
                            });
                          }
                        }
                      : null,
                  child: Image.asset(
                    'assets/ui/closed_folder.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.transparent);
                    },
                  ),
                ),
              ),

            // Cash box (clickable only if album found)
            Positioned(
              right: -w * 0.15,
              bottom: -h * 0.03,
              width: w * 0.85,
              height: h * 0.65,
              child: GestureDetector(
                onTap: _albumFound
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VinylTableScreen(encounterNumber: 7),
                          ),
                        );
                      }
                    : null,
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

            // Top left: Back arrow and Phone icon
            Positioned(
              left: 16,
              top: 16,
              child: Row(children: [
                GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    child: Image.asset('assets/ui/back_arrow.png',
                        width: w * 0.055, height: w * 0.055,
                        errorBuilder: (context, error, stackTrace) {
                      return Container(
                          width: w * 0.055,
                          height: w * 0.055,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.arrow_back, size: 30));
                    })),
                const SizedBox(width: 12),
                GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => PhoneSaveLoadPopup(
                          encounterId: 'encounter7',
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
                    )),
              ]),
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
                              builder: (context) => const CartScreen()));
                      if (result == 'purchase_complete' && mounted) {
                        _onPurchaseComplete();
                      } else if (mounted) {
                        setState(() {});
                      }
                    },
                    child: Stack(clipBehavior: Clip.none, children: [
                      Image.asset('assets/ui/cart_icon.png',
                          width: w * 0.055, height: w * 0.055,
                          errorBuilder: (context, error, stackTrace) {
                        return Container(
                            width: w * 0.055,
                            height: w * 0.055,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.shopping_cart, size: 30));
                      }),
                      if (GameState.cartItems.isNotEmpty)
                        Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                                constraints: const BoxConstraints(
                                    minWidth: 20, minHeight: 20),
                                child: Text('${GameState.cartItems.length}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center))),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RecordsScreen()));
                        if (mounted) setState(() {});
                      },
                      child: Stack(clipBehavior: Clip.none, children: [
                        Image.asset('assets/ui/records_icon.png',
                            width: w * 0.055, height: w * 0.055,
                            errorBuilder: (context, error, stackTrace) {
                          return Container(
                              width: w * 0.055,
                              height: w * 0.055,
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.library_music, size: 30));
                        }),
                        if (GameState.records.isNotEmpty)
                          Positioned(
                              right: -6,
                              top: -6,
                              child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle),
                                  constraints: const BoxConstraints(
                                      minWidth: 20, minHeight: 20),
                                  child: Text('${GameState.records.length}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center))),
                      ])),
                ],
              ),
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
          // allow the text area to flex when available height is small
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
 if (_showContinue && !(_dialogueIndex >= _dialogues.length - 1))
          Positioned(
            right: w * 0.01,
            bottom: h * 0.01,
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
      ),
    );
  }

  Widget _buildDialogueOptions(double w, double h) {
    final options = [
      {'text': 'A disco without you isn\'t a disco at all.', 'value': 'A'},
      {'text': 'Let me find the sparkle.', 'value': 'B'},
      {'text': 'I bet those moves still hit.', 'value': 'C'},
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
                offset: const Offset(0, 4))
          ]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose your response:',
              style: TextStyle(
                  fontSize: w * 0.016,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
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
                            border: Border.all(
                                color: Colors.grey[400]!, width: 1.5)),
                        child: Text('${option['value']}: ${option['text']}',
                            style: TextStyle(
                                fontSize: w * 0.014, color: Colors.black87)),
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
