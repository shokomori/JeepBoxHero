import 'package:flutter/material.dart';
import '../screens/encounter1_screen.dart';
import '../screens/encounter2_screen.dart';
import '../screens/encounter3_screen.dart';
import '../screens/encounter4_screen.dart';
import '../screens/encounter5_screen.dart';
import '../screens/encounter6_screen.dart';
import '../screens/encounter7_screen.dart';
import '../screens/encounter8_screen.dart';
import '../screens/encounter9_screen.dart';
import '../screens/encounter10_screen.dart';
import '../screens/shop_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveStateManager {
  /// Universal factory to load the correct encounter screen with progress
  static Widget loadEncounterScreen(
      String encounter, Map<String, dynamic> progress) {
    switch (encounter) {
      case 'encounter1':
        return Encounter1Screen(progress: progress);
      case 'encounter2':
        return Encounter2Screen(progress: progress);
      case 'encounter3':
        return Encounter3Screen(progress: progress);
      case 'encounter4':
        return Encounter4Screen(progress: progress);
      case 'encounter5':
        return Encounter5Screen(progress: progress);
      case 'encounter6':
        return Encounter6Screen(progress: progress);
      case 'encounter7':
        return Encounter7Screen(progress: progress);
      case 'encounter8':
        return Encounter8Screen(progress: progress);
      case 'encounter9':
        return Encounter9Screen(progress: progress);
      case 'encounter10':
        return Encounter10Screen(progress: progress);
      default:
        return ShopScreen();
    }
  }

  Future<void> deleteState(String id) async {
    try {
      final response = await _supabase.from(_table).delete().eq('id', id);
      if (kDebugMode) print('✅ Save state deleted: $response');
    } catch (e) {
      if (kDebugMode) print('❌ Delete state failed: $e');
    }
  }

  static final SaveStateManager _instance = SaveStateManager._internal();
  factory SaveStateManager() => _instance;
  SaveStateManager._internal();

  final _supabase = Supabase.instance.client;
  final String _table = 'save_states'; 

  Future<void> saveState({
    required String encounter,
    required Map<String, dynamic> progress,
  }) async {
    try {
      final response = await _supabase.from(_table).insert({
        'encounter': encounter,
        'progress': progress,
      });
      if (kDebugMode) print('✅ Save state uploaded: $response');
    } catch (e) {
      if (kDebugMode) print('❌ Save state failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> loadStates() async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .order('timestamp', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) print('❌ Load states failed: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> loadState(String encounter) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('encounter', encounter)
        .order('timestamp', ascending: false)
        .limit(1)
        .maybeSingle();
    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }
}
