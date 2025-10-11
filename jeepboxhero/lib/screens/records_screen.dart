// lib/screens/records_screen.dart
import 'package:flutter/material.dart';
import '../managers/game_state.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final records = GameState.records;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collected Records'),
        backgroundColor: const Color(0xFFD2691E),
      ),
      body: records.isEmpty
          ? const Center(
              child: Text(
                'No records collected yet.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // More columns for smaller cards
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlbumDetailScreen(record: record),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            child: Image.asset(
                              record['imagePath'] ?? '',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.album, size: 60),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            children: [
                              Text(
                                record['album'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                record['artist'] ?? '',
                                style: const TextStyle(fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AlbumDetailScreen extends StatelessWidget {
  final Map<String, dynamic> record;

  const AlbumDetailScreen({super.key, required this.record});

  String _getAssetBaseName() {
    // Convert imagePath like 'assets/albums/bini_talaarawan.png'
    // to 'bini_talaarawan'
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
              'assets/backgrounds/table_down_left.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFFD2B48C));
              },
            ),
          ),

          // Main content - centered vertically
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.04,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side: Info card
                  Flexible(
                    flex: 24,
                    child: Container(
                      constraints: BoxConstraints(maxHeight: h * 0.6),
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
                            padding: const EdgeInsets.all(16),
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

                  SizedBox(width: w * 0.02),

                  // Center: Enlarged vinyl with album cover
                  Flexible(
                    flex: 44,
                    child: Container(
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
                  ),

                  SizedBox(width: w * 0.02),

                  // Right side: Tracklist card (enlarged)
                  Flexible(
                    flex: 32,
                    child: ClipRect(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: h * 0.75),
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
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
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
