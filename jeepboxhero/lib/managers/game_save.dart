// lib/managers/game_save.dart
import 'dart:convert';

class GameSave {
  final String screenName;
  final int dialogueIndex;
  final bool albumFound;
  final bool transactionComplete;
  final List<Map<String, dynamic>> cartItems;
  final List<Map<String, dynamic>> records;
  final DateTime lastSaved;

  GameSave({
    required this.screenName,
    required this.dialogueIndex,
    required this.albumFound,
    required this.transactionComplete,
    required this.cartItems,
    required this.records,
    required this.lastSaved,
  });

  Map<String, dynamic> toJson() => {
        'screen_name': screenName,
        'dialogue_index': dialogueIndex,
        'album_found': albumFound,
        'transaction_complete': transactionComplete,
        'cart_items': cartItems,
        'records': records,
        'last_saved': lastSaved.toIso8601String(),
      };

  static GameSave fromJson(Map<String, dynamic> json) {
    // Some Supabase responses return strings for timestamps and dynamic types for jsonb
    final cart = json['cart_items'];
    final records = json['records'];
    List<Map<String, dynamic>> parseList(dynamic input) {
      if (input == null) return [];
      if (input is String) {
        final decoded = jsonDecode(input);
        return List<Map<String, dynamic>>.from(decoded);
      } else if (input is List) {
        return List<Map<String, dynamic>>.from(input);
      } else {
        return [];
      }
    }

    final lastSavedRaw = json['last_saved'] ?? json['meta']?['last_saved'];
    DateTime parsedLast;
    if (lastSavedRaw == null) {
      parsedLast = DateTime.now();
    } else {
      parsedLast = DateTime.parse(lastSavedRaw.toString());
    }

    return GameSave(
      screenName: json['screen_name'] ?? 'ShopScreen',
      dialogueIndex: (json['dialogue_index'] ?? 0) as int,
      albumFound: (json['album_found'] ?? false) as bool,
      transactionComplete: (json['transaction_complete'] ?? false) as bool,
      cartItems: parseList(cart),
      records: parseList(records),
      lastSaved: parsedLast,
    );
  }
}
