import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/meal.dart';
import 'meal_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MealService _service = MealService();
  final TextEditingController _searchController = TextEditingController();
  List<Meal> _meals = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _hasSearched = false;

  Future<void> _searchMeals() async {
    if (_searchController.text.trim().isEmpty) return;
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _hasSearched = true;
    });

    try {
      final meals = await _service.searchMeals(_searchController.text.trim());
      if (!mounted) return;
      
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to search meals';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        title: const Text(
          'SEARCH MEALS',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF16213E),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for meals...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFF6B6B)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _meals = [];
                      _hasSearched = false;
                    });
                  },
                ),
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _searchMeals(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF6B6B)))
                : _errorMessage.isNotEmpty
                    ? Center(
                        child: Text(_errorMessage,
                            style: const TextStyle(color: Colors.redAccent)))
                    : !_hasSearched
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search,
                                    size: 80, color: Colors.white24),
                                SizedBox(height: 16),
                                Text(
                                  'Search for your favorite meals',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : _meals.isEmpty
                            ? const Center(
                                child: Text(
                                  'No meals found',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _meals.length,
                                itemBuilder: (context, index) {
                                  final meal = _meals[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MealDetailScreen(mealId: meal.id),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF16213E),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.horizontal(
                                                    left: Radius.circular(20)),
                                            child: meal.thumbnail != null
                                                ? Image.network(
                                                    meal.thumbnail!,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 100,
                                                    height: 100,
                                                    color:
                                                        const Color(0xFF1A1A2E),
                                                    child: const Icon(
                                                        Icons.restaurant,
                                                        color:
                                                            Color(0xFFFF6B6B)),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (meal.category != null) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      meal.category!,
                                                      style: const TextStyle(
                                                        color: Color(0xFFFF6B6B),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }
}
