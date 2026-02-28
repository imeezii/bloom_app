import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FavoritesService {
  static const String _favoritesKey = 'favorite_meals';

  // Get all favorite meal IDs
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(favoritesJson);
    return decoded.cast<String>();
  }

  // Check if a meal is favorited
  Future<bool> isFavorite(String mealId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(mealId);
  }

  // Add meal to favorites
  Future<void> addFavorite(String mealId) async {
    final favorites = await getFavoriteIds();
    if (!favorites.contains(mealId)) {
      favorites.add(mealId);
      await _saveFavorites(favorites);
    }
  }

  // Remove meal from favorites
  Future<void> removeFavorite(String mealId) async {
    final favorites = await getFavoriteIds();
    favorites.remove(mealId);
    await _saveFavorites(favorites);
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String mealId) async {
    final isFav = await isFavorite(mealId);
    if (isFav) {
      await removeFavorite(mealId);
      return false;
    } else {
      await addFavorite(mealId);
      return true;
    }
  }

  // Save favorites to storage
  Future<void> _saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }
}
