import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage route selection history
class RouteHistoryService {
  static const String _historyKey = 'route_history';
  static const int _maxHistorySize = 5;

  /// Get the list of route IDs from history (most recent first)
  Future<List<int>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_historyKey);
      
      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.map((e) => e as int).toList();
    } catch (e) {
      print('Error loading route history: $e');
      return [];
    }
  }

  /// Add a route ID to history (adds to beginning, removes duplicates, limits size)
  Future<void> addToHistory(int routeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<int> history = await getHistory();
      
      // Remove if already exists (to move to front)
      history.remove(routeId);
      
      // Add to beginning
      history.insert(0, routeId);
      
      // Limit to max size
      if (history.length > _maxHistorySize) {
        history = history.sublist(0, _maxHistorySize);
      }
      
      // Save
      final String encoded = jsonEncode(history);
      await prefs.setString(_historyKey, encoded);
    } catch (e) {
      print('Error saving route history: $e');
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing route history: $e');
    }
  }
}
