class MealPreview {
  final String id;
  final String name;
  final String? thumbnail;

  MealPreview({
    required this.id,
    required this.name,
    this.thumbnail,
  });

  factory MealPreview.fromJson(Map<String, dynamic> json) {
    return MealPreview(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? 'Unknown',
      thumbnail: json['strMealThumb'],
    );
  }
}
