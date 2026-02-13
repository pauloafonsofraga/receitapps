import '../models/recipe.dart';
import '../models/recipe_step.dart';
import '../supabase_client.dart';


class RecipeService {
  /// Lista receitas a partir da tabela `recipes`.
  ///
  /// `query` é opcional:
  /// - Se estiver vazio: devolve todas as receitas ordenadas.
  /// - Se tiver texto: filtra localmente (em memória).
  ///
  /// Nota: como o projeto tem poucas receitas (ex.: 5), filtrar localmente é
  /// simples e evita dependência de métodos específicos (ilike) do Postgrest.
  Future<List<Recipe>> listRecipes({String? query}) async {
    // Vai buscar todas as receitas ao Supabase.
    // Selecionamos apenas os campos necessários para a lista.
    final data = await supabase
        .from('recipes')
        .select('id, title, category, thumbnail_url, created_at')
        .order('created_at', ascending: false);

    // Converte a lista de Maps (JSON) para uma lista de objetos Recipe.
    final recipes = (data as List)
        .map((e) => Recipe.fromMap(e as Map<String, dynamic>))
        .toList();

    // Normaliza a query: remove espaços e converte para minúsculas.
    final q = (query ?? '').trim().toLowerCase();

    // Se não houver pesquisa, devolve a lista completa.
    if (q.isEmpty) return recipes;

    // Filtra localmente pelo título.
    // Para 5–10 receitas, isto é rápido e totalmente aceitável.
    return recipes.where((r) => r.title.toLowerCase().contains(q)).toList();
  }

  /// Lista os passos de uma receita na tabela `recipe_steps`.
  ///
  /// Recebe o `recipeId` para filtrar:
  /// - `.eq('recipe_id', recipeId)` seleciona apenas passos dessa receita.
  /// - `.order('step_number')` garante que os passos vêm na ordem correta.
  Future<List<RecipeStep>> listSteps(String recipeId) async {
    // Query ao Supabase para obter passos da receita selecionada.
    final data = await supabase
        .from('recipe_steps')
        .select('id, recipe_id, step_number, title, description, image_url')
        .eq('recipe_id', recipeId)
        .order('step_number', ascending: true);

    // Converte a lista de Maps (JSON) para uma lista de objetos RecipeStep.
    return (data as List)
        .map((e) => RecipeStep.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
