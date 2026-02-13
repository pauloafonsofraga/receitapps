import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/recipes_screen.dart';
import 'screens/recipe_steps_screen.dart';
import 'screens/profile_screen.dart';

/// Referência global ao cliente Supabase
final supabase = Supabase.instance.client;

final router = GoRouter(
  // Ecrã inicial da aplicação
  initialLocation: '/login',

  // Função de redirecionamento global
  redirect: (context, state) {
    final session = supabase.auth.currentSession;
    final isLoggedIn = session != null;

    final isLogin = state.matchedLocation == '/login';
    final isRegister = state.matchedLocation == '/register';

    // Se o utilizador NÃO estiver autenticado
    // e tentar aceder a ecrãs protegidos, é redirecionado para o login
    if (!isLoggedIn && !isLogin && !isRegister) {
      return '/login';
    }

    // Se o utilizador JÁ estiver autenticado
    // não deve voltar para login ou registo
    if (isLoggedIn && (isLogin || isRegister)) {
      return '/recipes';
    }

    // Sem redirecionamento
    return null;
  },

  // Lista de rotas da aplicação
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/recipes',
      builder: (context, state) => const RecipesScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      // Rota com parâmetros dinâmicos
      path: '/recipe/:id/steps',
      builder: (context, state) {
        // Obtém o ID da receita a partir da rota
        final recipeId = state.pathParameters['id']!;

        // Obtém o título passado por extra (opcional)
        final recipeTitle = state.extra as String? ?? 'Receita';

        return RecipeStepsScreen(
          recipeId: recipeId,
          recipeTitle: recipeTitle,
        );
      },
    ),
  ],
);
