// lib/managers/game_state.dart

class GameState {
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
      _records.add(record);
    }
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
      addRecord({
        'album': item['album'],
        'artist': item['artist'],
        'imagePath': item['imagePath'] ?? 'assets/albums/default_album.png',
      });
    }
    _cartItems.clear(); // Empty the cart after checkout
  }

  // Reset entire game state
  static void reset() {
    _records.clear();
    _cartItems.clear();
  }
}
