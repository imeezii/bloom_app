class Category {
  final String id;
  final String name;
  final String? thumbnail;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.thumbnail,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['idCategory'] ?? '',
      name: json['strCategory'] ?? 'Unknown',
      thumbnail: json['strCategoryThumb'],
      description: json['strCategoryDescription'],
    );
  }
}
