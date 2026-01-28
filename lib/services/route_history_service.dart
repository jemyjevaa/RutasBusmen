import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage route selection history
class RouteHistoryService {
  static const String _historyKey = 'route_history';
  static const String _favoritesKey = 'route_favorites';
  static const String _tutorialShownKey = 'native_tutorial_shown';
  static const String _showETAKey = 'show_eta_outside_app';
  static const String _wantsNativeETAKey = 'wants_native_eta';
  static const int _maxHistorySize = 4;

  /// Get background activity preference
  Future<bool> getShowETAPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_showETAKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Set background activity preference
  Future<void> setShowETAPreference(bool show) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_showETAKey, show);
    } catch (e) {
      print('Error saving ETA preference: $e');
    }
  }

  /// Get whether user wants to activate native ETA (intent)
  Future<bool> getWantsNativeETAPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_wantsNativeETAKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Set whether user wants to activate native ETA (intent)
  Future<void> setWantsNativeETAPreference(bool wants) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_wantsNativeETAKey, wants);
    } catch (e) {
      print('Error saving wantsNativeETA preference: $e');
    }
  }

  /// Get whether the native tutorial has been shown
  Future<bool> hasShownTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_tutorialShownKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Set the native tutorial as shown
  Future<void> setTutorialShown(bool shown) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_tutorialShownKey, shown);
    } catch (e) {
      print('Error saving tutorial state: $e');
    }
  }

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

  /// Get the list of favorite route IDs
  Future<List<int>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? favoritesList = prefs.getStringList(_favoritesKey);
      
      if (favoritesList == null) {
        return [];
      }
      
      return favoritesList.map((e) => int.parse(e)).toList();
    } catch (e) {
      print('Error loading route favorites: $e');
      return [];
    }
  }

  /// Toggle a route ID in favorites
  Future<bool> toggleFavorite(int routeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<int> favorites = await getFavorites();
      
      bool isNowFavorite;
      if (favorites.contains(routeId)) {
        favorites.remove(routeId);
        isNowFavorite = false;
      } else {
        favorites.add(routeId);
        isNowFavorite = true;
      }
      
      await prefs.setStringList(_favoritesKey, favorites.map((e) => e.toString()).toList());
      return isNowFavorite;
    } catch (e) {
      print('Error toggling route favorite: $e');
      return false;
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
