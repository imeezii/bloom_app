import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import '../models/meal.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final MealService _mealService = MealService();
  final FavoritesService _favoritesService = FavoritesService();
  List<Meal> _favoriteMeals = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final favoriteIds = await _favoritesService.getFavoriteIds();
      
      if (favoriteIds.isEmpty) {
        if (!mounted) return;
        setState(() {
          _favoriteMeals = [];
          _isLoading = false;
        });
        return;
      }

      final List<Meal> meals = [];
      for (final id in favoriteIds) {
        try {
          final meal = await _mealService.getMealById(id);
          if (meal != null) {
            meals.add(meal);
          }
        } catch (e) {
          // Skip meals that fail to load
        }
      }

      if (!mounted) return;
      setState(() {
        _favoriteMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load favorites';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        title: const Text(
          'FAVORITES',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_favoriteMeals.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFavorites,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.redAccent)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFavorites,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B6B),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _favoriteMeals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No favorites yet',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Start exploring meals and add your favorites!',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      color: const Color(0xFFFF6B6B),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _favoriteMeals.length,
                        itemBuilder: (context, index) {
                          final meal = _favoriteMeals[index];
                          return GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MealDetailScreen(mealId: meal.id),
                                ),
                              );
                              // Reload favorites when returning
                              _loadFavorites();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16213E),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.horizontal(
                                        left: Radius.circular(20)),
                                    child: meal.thumbnail != null
                                        ? Image.network(
                                            meal.thumbnail!,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            width: 120,
                                            height: 120,
                                            color: const Color(0xFF1A1A2E),
                                            child: const Icon(Icons.restaurant,
                                                size: 50,
                                                color: Color(0xFFFF6B6B)),
                                          ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            meal.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (meal.category != null) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.category,
                                                    size: 14,
                                                    color: Color(0xFFFF6B6B)),
                                                const SizedBox(width: 6),
                                                Text(
                                                  meal.category!,
                                                  style: const TextStyle(
                                                    color: Color(0xFFFF6B6B),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (meal.area != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.public,
                                                    size: 14,
                                                    color: Colors.white54),
                                                const SizedBox(width: 6),
                                                Text(
                                                  meal.area!,
                                                  style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Icon(
                                      Icons.favorite,
                                      color: Color(0xFFFF6B6B),
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
