import 'package:flutter/material.dart';

class VinylTableScreen extends StatelessWidget {
  final int encounterNumber;
  final VoidCallback? onBack;
  const VinylTableScreen({Key? key, required this.encounterNumber, this.onBack}) : super(key: key);

  static const Map<int, Map<String, String>> _encounterRecords = {
    1: {
      'artist': 'Francis M',
      'album': 'Yo!',
      'image': 'assets/albums/francis_m_yo_vinyl.png',
    },
    2: {
      'artist': 'Rico Blanco',
      'album': 'Your Universe',
      'image': 'assets/albums/rico_your_universe_vinyl.png',
    },
    3: {
      'artist': 'Kitchie Nadal',
      'album': 'Kitchie Nadal',
      'image': 'assets/albums/kitchie_nadal_vinyl.png',
    },
    4: {
      'artist': 'Gloc-9',
      'album': 'Mga Kwento ng Makata',
      'image': 'assets/albums/gloc9_kwento_vinyl.png',
    },
    5: {
      'artist': 'Lea Salonga',
      'album': 'Lea Salonga',
      'image': 'assets/albums/lea_salonga_vinyl.png',
    },
    6: {
      'artist': 'IV of Spades',
      'album': 'CLAPCLAPCLAP!',
      'image': 'assets/albums/ivspades_clap_vinyl.png',
    },
    7: {
      'artist': 'Sexbomb Girls',
      'album': 'Unang Putok',
      'image': 'assets/albums/sexbomb_unang_vinyl.png',
    },
    8: {
      'artist': 'Moira Dela Torre',
      'album': 'Malaya',
      'image': 'assets/albums/moira_malaya_vinyl.png',
    },
    9: {
      'artist': 'BINI',
      'album': 'Talaarawan',
      'image': 'assets/albums/bini_talaarawan_vinyl.png',
    },
    10: {
      'artist': 'Eraserheads',
      'album': 'Cutterpillow',
      'image': 'assets/albums/eraser_heads_cutterpillow_vinyl.png',
    },
  };

  @override
  Widget build(BuildContext context) {
    final record = _encounterRecords[encounterNumber];
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/vinyl_table.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.brown[200]),
            ),
          ),
 SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 0.0, 10.0, 10.0),
                child: GestureDetector(
                  onTap: () {
                    if (onBack != null) {
                      onBack!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset(
                    'assets/ui/back_arrow.png',
                    width: 60,
                    height: 60,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.black, size: 28),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          if (record != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(-80, 40), 
                    child: Image.asset(
                      record['image']!,
                      width: 400,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 320,
                        height: 320,
                        color: Colors.grey[400],
                        child: const Icon(Icons.album, size: 70),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Text(
                  //   record['album']!,
                  //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  // ),
                  // Text(
                  //   record['artist']!,
                  //   style: const TextStyle(fontSize: 18, color: Colors.white70),
                  // ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
