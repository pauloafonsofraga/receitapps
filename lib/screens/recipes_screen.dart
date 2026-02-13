import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final _service = RecipeService();
  final _search = TextEditingController();

  late Future<List<Recipe>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listRecipes();
  }

  void _reload() {
    setState(() {
      _future = _service.listRecipes(query: _search.text);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
        actions: [
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                        labelText: 'Pesquisar receita',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onSubmitted: (_) => _reload(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('Pesquisar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<Recipe>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    }

                    final recipes = snapshot.data ?? [];
                    if (recipes.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhuma receita encontrada.)',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: recipes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final r = recipes[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            final t = Uri.encodeComponent(r.title);
                            context.go('/recipe/${r.id}/steps?title=$t');
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 84,
                                      height: 64,
                                      child: (r.thumbnailUrl == null || r.thumbnailUrl!.isEmpty)
                                          ? Container(
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.image_not_supported),
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: r.thumbnailUrl!,
                                              fit: BoxFit.cover,
                                              placeholder: (_, __) => Container(color: Colors.grey.shade200),
                                              errorWidget: (_, __, ___) => Container(
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.broken_image),
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.title,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(r.category, style: TextStyle(color: Colors.grey.shade700)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
