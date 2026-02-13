import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/recipe_step.dart';
import '../services/recipe_service.dart';

class RecipeStepsScreen extends StatefulWidget {
  // ID da receita (usado para buscar os passos)
  final String recipeId;

  // Título da receita (mostrado no AppBar)
  final String recipeTitle;

  const RecipeStepsScreen({
    super.key,
    required this.recipeId,
    required this.recipeTitle,
  });

  @override
  State<RecipeStepsScreen> createState() => _RecipeStepsScreenState();
}

class _RecipeStepsScreenState extends State<RecipeStepsScreen> {
  // Serviço responsável por obter os passos
  final _service = RecipeService();

  // Future que contém a lista de passos
  late Future<List<RecipeStep>> _future;

  // Índice do passo atual
  int _index = 0;

  @override
  void initState() {
    super.initState();

    // Inicia o carregamento dos passos da receita
    _future = _service.listSteps(widget.recipeId);
  }

  /// Avança para o próximo passo.
  /// Se estiver no último, volta à lista de receitas.
  void _next(int total) {
    if (_index < total - 1) {
      setState(() => _index++);
    } else {
      context.go('/recipes');
    }
  }

  /// Volta ao passo anterior.
  /// Se estiver no primeiro, volta à lista de receitas.
  void _prevOrBack() {
    if (_index == 0) {
      context.go('/recipes');
    } else {
      setState(() => _index--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FutureBuilder<List<RecipeStep>>(
            future: _future,
            builder: (context, snapshot) {
              // Enquanto carrega os dados
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Se ocorrer erro ao carregar os passos
              if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              }

              final steps = snapshot.data ?? [];

              // Segurança: se não houver passos, não renderiza nada
              if (steps.isEmpty) {
                return const SizedBox.shrink();
              }

              // Garante que o índice está dentro dos limites
              if (_index >= steps.length) _index = 0;

              final step = steps[_index];
              final isFirst = _index == 0;
              final isLast = _index == steps.length - 1;

              return Column(
                children: [
                  // Card com o conteúdo do passo
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Indicador do passo atual
                          Text(
                            'Passo ${_index + 1} de ${steps.length}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),

                          const SizedBox(height: 8),

                          // Imagem do passo (carregada do Supabase Storage)
                          if (step.imageUrl != null &&
                              step.imageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: CachedNetworkImage(
                                  imageUrl: step.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: Colors.grey.shade200,
                                  ),
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Título do passo
                          Text(
                            step.title ?? 'Instruções',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Descrição do passo
                          Text(
                            step.description,
                            style:
                                const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Botões de navegação
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _prevOrBack,
                          child: Text(
                            isFirst ? 'Voltar às receitas' : 'Anterior',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _next(steps.length),
                          child: Text(isLast ? 'Fim' : 'Próximo'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
