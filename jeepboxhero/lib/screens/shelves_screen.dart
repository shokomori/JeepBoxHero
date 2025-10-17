// lib/screens/shelves_screen.dart
import 'package:flutter/material.dart';

class ShelvesScreen extends StatefulWidget {
  final String targetAlbumTitle;
  final String targetAlbumArtist;
  final String successNarration;
  final String successDialogue;
  final String successSpeaker;
  final String wrongAlbumHint;

  const ShelvesScreen({
    super.key,
    required this.targetAlbumTitle,
    required this.targetAlbumArtist,
    this.successNarration = '',
    this.successDialogue = '',
    this.successSpeaker = 'Tito Ramon',
    this.wrongAlbumHint = '',
  });

  @override
  State<ShelvesScreen> createState() => _ShelvesScreenState();
}

class _ShelvesScreenState extends State<ShelvesScreen> {
  int _currentShelfIndex = 0;
  final int _totalShelves = 4;
  int? _highlightedAlbumIndex;

  final List<Map<String, dynamic>> _shelvesData = [
    {
      'label': 'First Shelf',
      'background': 'assets/shelves/loc1_all.png',
      'albums': [
        {
          'title': 'Kitchie Nadal',
          'artist': 'Kitchie Nadal',
          'year': '2004',
          'cover': 'assets/albums/kitchie_nadal.png',
        },
        {
          'title': 'Yo!',
          'artist': 'Francis M.',
          'year': '2012',
          'cover': 'assets/albums/francis_m_yo.png',
        },
        {
          'title': 'Malaya',
          'artist': 'Moira Dela Torre',
          'year': '2018',
          'cover': 'assets/albums/moira_malaya.png',
        },
      ],
    },
    {
      'label': 'Second Shelf',
      'background': 'assets/shelves/loc2_all.png',
      'albums': [
        {
          'title': 'Lea Salonga',
          'artist': 'Lea Salonga',
          'year': '1993',
          'cover': 'assets/albums/lea_salonga.png',
        },
        {
          'title': 'Mga Kwento ng Makata',
          'artist': 'Gloc-9',
          'year': '2012',
          'cover': 'assets/albums/gloc9_kwento.png',
        },
      ],
    },
    {
      'label': 'Third Shelf',
      'background': 'assets/shelves/loc3_all.png',
      'albums': [
        {
          'title': 'Unang Putok',
          'artist': 'Sexbomb Girls',
          'year': '2002',
          'cover': 'assets/albums/sexbomb_unang.png',
        },
        {
          'title': 'Your Universe',
          'artist': 'Rico Blanco',
          'year': '2008',
          'cover': 'assets/albums/rico_your_universe.png',
        },
        {
          'title': 'R2K',
          'artist': 'Regine Velasquez',
          'year': '1999',
          'cover': 'assets/albums/regine_r2k.png',
        },
      ],
    },
    {
      'label': 'Fourth Shelf',
      'background': 'assets/shelves/loc4_all.png',
      'albums': [
        {
          'title': 'CLAPCLAPCLAP!',
          'artist': 'IV of Spades',
          'year': '2018',
          'cover': 'assets/albums/ivspades_clap.png',
        },
        {
          'title': 'Talaarawan',
          'artist': 'BINI',
          'year': '2024',
          'cover': 'assets/albums/bini_talaarawan.png',
        },
        {
          'title': 'Cutterpillow',
          'artist': 'Eraserheads',
          'year': '2025',
          'cover': 'assets/albums/eraserheads_cutterpillow.png',
        },
        {
          'title': 'UDD',
          'artist': 'Up Dharma Down',
          'year': '2019',
          'cover': 'assets/albums/udd_album.png',
        },
      ],
    },
  ];

  void _goToPreviousShelf() {
    if (_currentShelfIndex > 0) {
      setState(() {
        _currentShelfIndex--;
        _highlightedAlbumIndex = null;
      });
    }
  }

  void _goToNextShelf() {
    if (_currentShelfIndex < _totalShelves - 1) {
      setState(() {
        _currentShelfIndex++;
        _highlightedAlbumIndex = null;
      });
    }
  }

  bool _isTargetAlbum(Map<String, dynamic> album) {
    String normalize(String s) {
      return s
          .toString()
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r"[^a-z0-9\s]"), '')
          .replaceAll(RegExp(r"\s+"), ' ');
    }

    final albumTitle = normalize(album['title'] ?? '');
    final targetTitle = normalize(widget.targetAlbumTitle);
    final albumArtist = normalize(album['artist'] ?? '');
    final targetArtist = normalize(widget.targetAlbumArtist);

    debugPrint('Matching album: "$albumTitle" vs targetTitle: "$targetTitle"');
    debugPrint(
        'Matching artist: "$albumArtist" vs targetArtist: "$targetArtist"');

    return albumTitle == targetTitle && albumArtist.contains(targetArtist);
  }

  void _onAlbumTap(Map<String, dynamic> album, int index) {
    debugPrint(
        'Album tapped: ${album['title']}, isTarget: ${_isTargetAlbum(album)}');

    setState(() {
      _highlightedAlbumIndex = index;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        if (_isTargetAlbum(album)) {
          _showSuccessDialog(album);
        } else {
          _showWrongAlbumDialog(album);
        }
      }
    });
  }

  void _showSuccessDialog(Map<String, dynamic> album) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 32),
            const SizedBox(width: 8),
            const Text('Found it!',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.successNarration.isNotEmpty) ...[
                const Text(
                  '[Narration]',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.successNarration,
                    style: const TextStyle(fontSize: 15, height: 1.4)),
                const SizedBox(height: 16),
              ],
              if (widget.successDialogue.isNotEmpty) ...[
                Text(
                  '${widget.successSpeaker}:',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.successDialogue,
                  style: const TextStyle(
                      fontSize: 15, height: 1.4, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Bring it to ${widget.successSpeaker} →',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showWrongAlbumDialog(Map<String, dynamic> album) {
    final hint = widget.wrongAlbumHint.isNotEmpty
        ? widget.wrongAlbumHint
        : 'But you\'re looking for ${widget.targetAlbumTitle} by ${widget.targetAlbumArtist}.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700], size: 32),
            const SizedBox(width: 8),
            const Text('Not quite...'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This is "${album['title']}" by ${album['artist']} (${album['year']})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(hint),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _highlightedAlbumIndex = null;
              });
            },
            child: const Text('Keep looking', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /// --- NO ANIMATION VERSION ---
  Widget _buildBottomAlbumPreview(
      Map<String, dynamic> album, Size size, int index) {
    final isHighlighted = _highlightedAlbumIndex == index;

    return GestureDetector(
      onTap: () => _onAlbumTap(album, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size.width * 0.18,
        height: size.width * 0.18,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isHighlighted
              ? Border.all(color: Colors.amber, width: 4)
              : Border.all(color: Colors.white54, width: 2),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            album['cover'],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.album, color: Colors.white70, size: 32),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        album['artist'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentShelf = _shelvesData[_currentShelfIndex];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              currentShelf['background'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF8B7355),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported,
                            size: 64, color: Colors.white54),
                        SizedBox(height: 16),
                        Text('Shelf image not found',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 18)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

// Left arrow
          Positioned(
            left: 16,
            top: size.height * 0.48,
            child: GestureDetector(
              onTap: _currentShelfIndex > 0 ? _goToPreviousShelf : null,
              child: Opacity(
                opacity: _currentShelfIndex > 0 ? 1.0 : 0.3,
                child: Image.asset(
                  'assets/ui/left_arrow.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          size: 40, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),

// Right arrow
          Positioned(
            right: 16,
            top: size.height * 0.48,
            child: GestureDetector(
              onTap: _currentShelfIndex < _totalShelves - 1
                  ? _goToNextShelf
                  : null,
              child: Opacity(
                opacity: _currentShelfIndex < _totalShelves - 1 ? 1.0 : 0.3,
                child: Image.asset(
                  'assets/ui/right_arrow.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward,
                          size: 40, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ),

// Albums bottom row (no animation)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: Wrap(
                spacing: size.width * 0.03,
                alignment: WrapAlignment.center,
                children: List.generate(
                  currentShelf['albums'].length,
                  (index) => _buildBottomAlbumPreview(
                    currentShelf['albums'][index],
                    size,
                    index,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
