// lib/managers/save_manager.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'game_save.dart';

class SaveManager {
  final _supabase = Supabase.instance.client;
  final String _table = 'game_saves';

  /// Save or overwrite a slot for the current user
  Future<void> saveToSlot(GameSave save, int slot) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final payload = {
      'user_id': user.id,
      'slot': slot,
      ...save.toJson(),
    };

    final response = await _supabase.from(_table).upsert(payload);
    if (response == null) {
      throw Exception('Save failed: null response');
    }
  }

  /// Load a slot for the current user
  Future<GameSave?> loadSlot(int slot) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final data = await _supabase
        .from(_table)
        .select()
        .eq('user_id', user.id)
        .eq('slot', slot)
        .maybeSingle();

    if (data == null) return null;
    return GameSave.fromJson(Map<String, dynamic>.from(data));
  }

  /// Get all available slots up to [maxSlots]
  Future<Map<int, GameSave?>> getSlots(int maxSlots) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final data = await _supabase
        .from(_table)
        .select()
        .eq('user_id', user.id)
        .order('slot');

    final List list = data as List;
    final Map<int, GameSave?> map = {
      for (var i = 1; i <= maxSlots; i++) i: null
    };
    for (final item in list) {
      final m = Map<String, dynamic>.from(item);
      map[m['slot'] as int] = GameSave.fromJson(m);
    }
    return map;
  }

  /// Delete a slot
  Future<void> deleteSlot(int slot) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    await _supabase
        .from(_table)
        .delete()
        .eq('user_id', user.id)
        .eq('slot', slot);
  }
}
