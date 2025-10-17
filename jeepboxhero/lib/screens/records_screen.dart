// lib/screens/records_screen.dart
import 'package:flutter/material.dart';
import '../managers/game_state.dart';
import '../managers/audio_manager.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = GameState.records;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/preview_album.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFD2B48C), Color(0xFFA0826D)],
                    ),
                  ),
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      w * 0.04, h * 0.02, w * 0.04, h * 0.03),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.0),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/ui/back_arrow.png',
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.arrow_back, size: 26);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 10), 
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0000),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFD700), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.local_offer, color: Colors.yellow, size: 26),
                              const SizedBox(width: 10),
                              Text(
                                'RECORD SALES',
                                style: TextStyle(
                                  fontSize: w * 0.048,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  fontFamily: 'RobotoCondensed', 
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: const Offset(1, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${records.length}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                // Records Grid
                Expanded(
                  child: records.isEmpty
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.only(right: 50 ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.0),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.0),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.library_music_outlined,
                                  size: 80,
                                  color: Colors.brown.withOpacity(0.9),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No records collected yet',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start exploring to find vinyl records!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF8B4513).withOpacity(1.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: w * 0.04),
                          child: GridView.builder(
                            // Allow scrolling so users can access all collected records
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.68,
                              crossAxisSpacing: w * 0.025,
                              mainAxisSpacing: h * 0.02,
                            ),
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records[index];
                              return _RecordCard(
                                record: record,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AlbumDetailScreen(record: record),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                ),

                SizedBox(height: h * 0.02),
              ],
            ),
          ),
        ],
      ),

    );
  }
}

class _RecordCard extends StatelessWidget {
  final Map<String, dynamic> record;
  final VoidCallback onTap;

  const _RecordCard({
    required this.record,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6), 
        decoration: BoxDecoration(
          // color: Colors.white,
          border: Border.all(
            color: const Color(0xFFD2691E).withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Album Cover — no white border, fits fully
            Expanded(
              flex: 7,
              child: SizedBox.expand(
                child: Image.asset(
                  record['imagePath'] ?? '',
                  fit: BoxFit.cover, // ensures full cover
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFD2691E).withOpacity(0.15),
                    child: const Icon(
                      Icons.album,
                      size: 50,
                      color: Color(0xFFD2691E),
                    ),
                  ),
                ),
              ),
            ),

            // Subtle gloss overlay
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                        Colors.black.withOpacity(0.08),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Album Info
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5D7),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFFD2691E).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      record['album'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        color: Color(0xFF4B2C10),
                        letterSpacing: 0.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record['artist'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF8B4513).withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AlbumDetailScreen extends StatelessWidget {
  final Map<String, dynamic> record;

  const AlbumDetailScreen({super.key, required this.record});

  String _getAssetBaseName() {
    final imagePath = record['imagePath'] ?? '';
    final fileName = imagePath.split('/').last;
    return fileName.replaceAll('.png', '');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    final baseName = _getAssetBaseName();

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/preview_album.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFFD2B48C));
              },
            ),
          ),

          // Main content - centered vertically
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: Info card
                  Flexible(
                    flex: 40,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: h * 3.5),
                      child: Image.asset(
                        'assets/albums/${baseName}_info.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8DC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.brown,
                                width: 3,
                              ),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record['album'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  record['artist'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Info card image not found',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Center: Enlarged vinyl with album cover (with play button underneath)
                  Flexible(
                    flex: 47,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxHeight: h * 0.7),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/albums/${baseName}_vinyl.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 250,
                                height: 250,
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.album,
                                  size: 120,
                                  color: Colors.white54,
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(height: h * 0.02),

                        // Centered play card below the vinyl
                        Container(
                          width: w * 0.32,
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 6))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(record['album'] ?? '', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: w * 0.016)),
                                    SizedBox(height: h * 0.006),
                                    Text(record['artist'] ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: w * 0.012, color: Colors.brown.withOpacity(0.7))),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  final audioPath = record['audioPath'] ?? 'audio/${baseName.replaceAll('_info', '')}.mp3';
                                  try {
                                    await AudioManager().stopBgm();
                                  } catch (_) {}
                                  try {
                                    await AudioManager().playBgm(audioPath, volume: 0.2, loop: true);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Playing ${record['album']}')));
                                  } catch (e) {
                                    try {
                                      await AudioManager().playSfx('sfx_page_turn.mp3');
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Preview unavailable — played a sample instead.')));
                                    } catch (_) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to play audio.')));
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  backgroundColor: const Color(0xFF6C63FF),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.play_arrow, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text('Play', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right side: Tracklist card
                  SizedBox(
                    height: h * 0.75, 
                    child: ClipRect(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: h * .75),
                        padding: EdgeInsets.symmetric(horizontal: w * 0.01),
                        child: Center(
                          child: SizedBox(
                            width: w * 0.26,
                            child: Image.asset(
                              'assets/albums/${baseName}_tracklist.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.94),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.brown,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Text(
                                    'Tracklist\nnot found',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Back button
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.0),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/ui/back_arrow.png',
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.arrow_back, size: 28);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
