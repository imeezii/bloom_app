import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/meal.dart';
import '../services/favorites_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final MealService _service = MealService();
  final FavoritesService _favoritesService = FavoritesService();
  Meal? _meal;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadMeal();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.mealId);
    if (!mounted) return;
    setState(() {
      _isFavorite = isFav;
    });
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await _favoritesService.toggleFavorite(widget.mealId);
    if (!mounted) return;
    
    setState(() {
      _isFavorite = newStatus;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus ? 'Added to favorites' : 'Removed from favorites',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadMeal() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final meal = await _service.getMealById(widget.mealId);
      if (!mounted) return;
      
      setState(() {
        _meal = meal;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load meal details';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage,
                      style: const TextStyle(color: Colors.redAccent)))
              : _meal == null
                  ? const Center(
                      child: Text('Meal not found',
                          style: TextStyle(color: Colors.white54)))
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 300,
                          pinned: true,
                          stretch: true,
                          backgroundColor: const Color(0xFF16213E),
                          flexibleSpace: FlexibleSpaceBar(
                            background: _meal!.thumbnail != null
                                ? Image.network(
                                    _meal!.thumbnail!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: const Color(0xFF16213E),
                                    child: const Icon(Icons.restaurant,
                                        size: 100, color: Color(0xFFFF6B6B)),
                                  ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              Text(
                                _meal!.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_meal!.category != null)
                                    _buildChip(_meal!.category!, Icons.category),
                                  if (_meal!.area != null)
                                    _buildChip(_meal!.area!, Icons.public),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'INGREDIENTS',
                                style: TextStyle(
                                  color: Color(0xFFFF6B6B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ..._meal!.ingredients.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 8, color: Color(0xFFFF6B6B)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${entry.key} - ${entry.value}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              if (_meal!.instructions != null) ...[
                                const SizedBox(height: 24),
                                const Text(
                                  'INSTRUCTIONS',
                                  style: TextStyle(
                                    color: Color(0xFFFF6B6B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _meal!.instructions!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 80),
                            ]),
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: _meal != null
          ? FloatingActionButton.extended(
              onPressed: _toggleFavorite,
              backgroundColor: _isFavorite
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF16213E),
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
              ),
              label: Text(
                _isFavorite ? 'FAVORITED' : 'ADD TO FAVORITES',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFF6B6B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFF6B6B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
