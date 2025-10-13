// lib/screens/encounter1_screen.dart
import 'package:flutter/material.dart';
import '../managers/game_state.dart';
import '../managers/audio_manager.dart';
import './shelves_screen.dart';
import 'package:jeepboxhero/screens/records_screen.dart';
import 'package:jeepboxhero/screens/cart_screen.dart';
import 'package:jeepboxhero/screens/encounter2_screen.dart';
import '../components/ui/phone_save_load_popup.dart';

class Encounter1Screen extends StatefulWidget {
  final Map<String, dynamic>? progress;
  const Encounter1Screen({this.progress, super.key});

  @override
  State<Encounter1Screen> createState() => _Encounter1ScreenState();
}

class _Encounter1ScreenState extends State<Encounter1Screen> {
  int _dialogueIndex = 0;
  bool _showContinue = false;
  bool _albumFound = false;
  bool _transactionComplete = false;
  bool _customerExiting = false;
  String? _selectedOption;

  // Track record collections for this encounter
  List<dynamic> _recordCollection = [];

  final List<Map<String, dynamic>> _dialogues = [
    {
      'type': 'narration',
      'text':
          '[Scene: Jeep Box Records – Hip-Hop Section]\n\nA man in baggy jeans and a snapback bounces into the shop, his steps like a freestyle beat. He throws a playful salute to Tito Ramon.',
      'speaker': null,
    },
    {
      'type': 'dialogue',
      'text':
          'Yo! Still standing, Jeep Box! Back in the day, this place spun the soundtrack to my first battles. There\'s one record I need again—Tagalog verses slicing through English beats, fire and pride all in one. First of its kind.',
      'speaker': 'MC Luwalhati (grinning)',
    },
    {
      'type': 'dialogue',
      'text':
          'Francis M would\'ve liked you, kid. Always rhyming like the streets were your stage.',
      'speaker': 'Tito Ramon (smiling)',
    },
    {
      'type': 'dialogue',
      'text':
          'All I remember is the cover—loud, bold, like it was daring you to press play. That\'s the album that lit my fire.',
      'speaker': 'MC Luwalhati (laughing)',
    },
  ];

  final List<Map<String, dynamic>> _postChoiceDialogues = [
    {
      'type': 'narration',
      'text':
          '[Gameplay Prompt]\n\n• Navigate to the Hip-Hop section.\n• Look for a vibrant, graffiti-like cover featuring a man in shades.\n• This is the first album that brought Pinoy rap to the mainstream.',
      'speaker': null,
    },
  ];

  final List<Map<String, dynamic>> _postFindDialogues = [
    {
      'type': 'dialogue',
      'text': 'There it is. The first king of Pinoy rap. Still untouchable.',
      'speaker': 'MC Luwalhati (snapping his fingers)',
    },
    {
      'type': 'dialogue',
      'text': 'Legends don\'t fade, they echo.',
      'speaker': 'Tito Ramon (grinning)',
    },
    {
      'type': 'narration',
      'text':
          '[Gameplay Prompt]\n\n• Open the cart and complete the transaction.\n• Fill in the album details correctly.\n• Process the payment.',
      'speaker': null,
    },
  ];

  final List<Map<String, dynamic>> _finalDialogues = [
    {
      'type': 'narration',
      'text':
          '[Narration]\n\nMC Luwalhati nods, tapping the vinyl like a drumbeat as he heads toward the door.',
      'speaker': null,
    },
    {
      'type': 'dialogue',
      'text':
          'Salamat, pare. This one\'s gonna get the kids hyped again. Keep the legacy alive.',
      'speaker': 'MC Luwalhati',
    },
    {
      'type': 'dialogue',
      'text':
          'That\'s what we do here. Every beat, every rhyme—they all matter.',
      'speaker': 'Tito Ramon',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Restore progress if loading from save
    if (widget.progress != null) {
      _dialogueIndex = widget.progress!['dialogueIndex'] ?? 0;
      _albumFound = widget.progress!['albumFound'] ?? false;
      _transactionComplete = widget.progress!['transactionComplete'] ?? false;
      _selectedOption = widget.progress!['selectedOption'];
      _recordCollection =
          List<dynamic>.from(widget.progress!['recordCollection'] ?? []);
      // Restore GameState.records if present
      if (widget.progress!['records'] != null) {
        GameState.records = List<dynamic>.from(widget.progress!['records']);
      }
    }
    _updateShowContinue();
    // Play customer bell when encounter begins
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
      // End of current dialogue set
      if (_selectedOption == null) {
        // Show dialogue options
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
        builder: (context) => const ShelvesScreen(
          targetAlbumTitle: 'Yo!',
          targetAlbumArtist: 'Francis M',
          successNarration:
              'You flip through hip-hop sleeves until a vibrant, graffiti-like cover emerges—a man in shades, looking unshakable.',
          successDialogue:
              '"There it is. The first king of Pinoy rap. Still untouchable."',
          successSpeaker: 'MC Luwalhati (snapping his fingers)',
          wrongAlbumHint:
              'Look for a vibrant, graffiti-like cover with a man in shades. The first Pinoy rap album!',
        ),
      ),
    );

    if (result == true && mounted) {
      // Add Francis M album to cart when found
      GameState.addToCart({
        'album': 'Yo!',
        'artist': 'Francis Magalona',
        'imagePath': 'assets/albums/francis_m_yo.png',
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
        // Replace this encounter with Encounter2Screen using a fade+slide transition
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const Encounter2Screen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade =
                CurvedAnimation(parent: animation, curve: Curves.easeInOut);
            final offset =
                Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero)
                    .animate(animation);
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: offset, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ));
      }
    });
  }

  bool _isCustomerSpeaking() {
    final currentDialogues = _getCurrentDialogues();
    if (_dialogueIndex >= currentDialogues.length) return false;
    final speaker = currentDialogues[_dialogueIndex]['speaker'];
    return speaker != null && speaker.contains('MC Luwalhati');
  }

  bool _isTitoSpeaking() {
    final currentDialogues = _getCurrentDialogues();
    if (_dialogueIndex >= currentDialogues.length) return false;
    final speaker = currentDialogues[_dialogueIndex]['speaker'];
    return speaker != null && speaker.contains('Tito Ramon');
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
                      encounterId: 'encounter1',
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

            // MC Luwalhati character
            AnimatedPositioned(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              left: _customerExiting ? -w * 0.6 : w * 0.10,
              right: _customerExiting ? w * 1.2 : w * 0.30,
              top: h * 0.05,
              bottom: h * 0.28,
              child: Image.asset(
                _isCustomerSpeaking()
                    ? 'assets/characters/mc_luwalhati_speaking.png'
                    : 'assets/characters/mc_luwalhati.png',
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

            // Vinyl cover on table
            if (_albumFound)
              Positioned(
                left: w * 0.35,
                bottom: h * 0.12,
                width: w * 0.25,
                height: w * 0.25,
                child: Image.asset(
                  'assets/albums/francis_m_yo.png',
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
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => PhoneSaveLoadPopup(
                          encounterId: 'encounter1',
                          progress: {
                            'dialogueIndex': _dialogueIndex,
                            'albumFound': _albumFound,
                            'transactionComplete': _transactionComplete,
                            'selectedOption': _selectedOption,
                            'recordCollection': _recordCollection,
                            'records': GameState.records,
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
                                _recordCollection = List<dynamic>.from(
                                    state['progress']['recordCollection'] ??
                                        []);
                                if (state['progress']['records'] != null) {
                                  GameState.records = List<dynamic>.from(
                                      state['progress']['records']);
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

  Widget _buildDialogueBox(Map<String, dynamic> dialogue, double w, double h) {
    return Container(
      constraints: BoxConstraints(maxHeight: h * 0.25),
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.035,
        vertical: h * 0.015,
      ),
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
        mainAxisSize: MainAxisSize.min,
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
          // constrain and make dialogue text scrollable so the Column won't overflow
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: h * 0.16),
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
      {'text': 'Sounds like the roots of it all.', 'value': 'A'},
      {'text': 'I\'ll dig it up for you.', 'value': 'B'},
      {'text': 'The beat never dies.', 'value': 'C'},
    ];

    return Container(
      constraints: BoxConstraints(maxHeight: h * 0.40),
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.035,
        vertical: h * 0.010,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black87,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your response:',
            style: TextStyle(
              fontSize: w * 0.015,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: h * 0.008),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: h * 0.28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.map((option) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: h * 0.006),
                    child: InkWell(
                      onTap: () => _selectOption(option['value']!),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: w * 0.02,
                          vertical: h * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey[400]!,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          '${option['value']}: ${option['text']}',
                          style: TextStyle(
                            fontSize: w * 0.013,
                            color: Colors.black87,
                          ),
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
