// lib/managers/game_state.dart

class GameState {
  // Setter for restoring records from save
  static set records(List recordsList) {
    _records
      ..clear()
      ..addAll(List<Map<String, dynamic>>.from(recordsList));
  }

  // Static lists to maintain state across screens
  static final List<Map<String, dynamic>> _records = [];
  static final List<Map<String, dynamic>> _cartItems = [];

  // Getters
  static List<Map<String, dynamic>> get records => List.unmodifiable(_records);
  static List<Map<String, dynamic>> get cartItems =>
      List.unmodifiable(_cartItems);

  // Records management
  static void addRecord(Map<String, dynamic> record) {
    // Prevent duplicate records
    bool exists = _records.any((r) =>
        r['album'] == record['album'] && r['artist'] == record['artist']);

    if (!exists) {
      // Ensure we store an audioPath for the record if available or can be inferred
      final Map<String, dynamic> toStore = Map<String, dynamic>.from(record);
      if (toStore['audioPath'] == null) {
        final imagePath = toStore['imagePath'] ?? '';
        final inferred = _inferAudioPathFromImage(imagePath) ??
            _inferAudioPathFromNames(toStore['album'], toStore['artist']);
        if (inferred != null) toStore['audioPath'] = inferred;
      }

      _records.add(toStore);
    }
  }

  // Try to infer an audio filename (assets/audio/bgm_<name>.mp3) from an image path
  static String? _inferAudioPathFromImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    try {
      final fileName = imagePath.split('/').last;
      var base = fileName
          .replaceAll('.png', '')
          .replaceAll('.jpg', '')
          .replaceAll('.jpeg', '');
      base = base.replaceAll(RegExp(r'_(info|vinyl|tracklist)\$'), '');
      // Normalize spaces/uppercase to underscore-lowercase
      base = base.replaceAll(' ', '_').toLowerCase();
      return 'bgm_${base}.mp3';
    } catch (_) {
      return null;
    }
  }

  static String? _inferAudioPathFromNames(String? album, String? artist) {
    if ((album == null || album.isEmpty) && (artist == null || artist.isEmpty))
      return null;
    final combined = '${album ?? ''}_${artist ?? ''}'
        .replaceAll(RegExp(r"[^a-zA-Z0-9_]"), '_')
        .toLowerCase();
    return 'bgm_${combined}.mp3';
  }

  static void removeRecord(int index) {
    if (index >= 0 && index < _records.length) {
      _records.removeAt(index);
    }
  }

  static void clearRecords() {
    _records.clear();
  }

  // Cart management
  static void addToCart(Map<String, dynamic> item) {
    _cartItems.add(item);
  }

  static void removeFromCart(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
    }
  }

  static void clearCart() {
    _cartItems.clear();
  }

  static double getTotalPrice() {
    return _cartItems.fold(0.0, (sum, item) {
      final price = item['price'];
      if (price is int) {
        return sum + price.toDouble();
      } else if (price is double) {
        return sum + price;
      } else if (price is String) {
        return sum + (double.tryParse(price) ?? 0.0);
      }
      return sum;
    });
  }

  // Check if an album is in the cart
  static bool isInCart(String album, String artist) {
    return _cartItems
        .any((item) => item['album'] == album && item['artist'] == artist);
  }

  // ✅ Complete transaction: move all cart items into records
  static void completeTransaction() {
    for (var item in _cartItems) {
      final recordMap = {
        'album': item['album'],
        'artist': item['artist'],
        'imagePath': item['imagePath'] ?? 'assets/albums/default_album.png',
      };
      // if the cart item already included an audioPath, pass it along
      if (item['audioPath'] != null) recordMap['audioPath'] = item['audioPath'];
      addRecord(recordMap);
    }
    _cartItems.clear(); // Empty the cart after checkout
  }

  // Reset entire game state
  static void reset() {
    _records.clear();
    _cartItems.clear();
  }
}
