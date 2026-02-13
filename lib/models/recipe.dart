class Recipe {
  final String id;
  final String title;
  final String category;
  final String? thumbnailUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.category,
    required this.thumbnailUrl,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      thumbnailUrl: map['thumbnail_url'] as String?,
    );
  }
}
