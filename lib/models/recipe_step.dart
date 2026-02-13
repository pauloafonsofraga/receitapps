class RecipeStep {
  final String id;
  final String recipeId;
  final int stepNumber;
  final String? title;
  final String description;
  final String? imageUrl;

  RecipeStep({
    required this.id,
    required this.recipeId,
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory RecipeStep.fromMap(Map<String, dynamic> map) {
    return RecipeStep(
      id: map['id'] as String,
      recipeId: map['recipe_id'] as String,
      stepNumber: map['step_number'] as int,
      title: map['title'] as String?,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String?,
    );
  }
}
