import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Serviço de autenticação (usado para obter perfil e fazer logout)
  final _auth = AuthService();

  // Future que irá conter os dados do perfil do utilizador
  late Future<AppUser> _futureProfile;

  @override
  void initState() {
    super.initState();

    // Inicia o carregamento do perfil do utilizador autenticado
    // Usa a versão com fallback para garantir robustez
    _futureProfile = _auth.fetchProfileFallbackToAuth();
  }

  /// Efetua logout do utilizador.
  ///
  /// Após o logout:
  /// - a sessão no Supabase é terminada
  /// - o router redireciona automaticamente para o ecrã de login
  Future<void> _logout() async {
    await _auth.signOut();

    if (!mounted) return;

    // Redireciona explicitamente para o login
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<AppUser>(
            future: _futureProfile,
            builder: (context, snapshot) {
              // Enquanto os dados do perfil estão a ser carregados
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Caso ocorra erro ao carregar o perfil
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar perfil: ${snapshot.error}'),
                );
              }

              // Dados do utilizador obtidos com sucesso
              final user = snapshot.data!;

              return Column(
                children: [
                  // Avatar do utilizador (placeholder)
                  const CircleAvatar(
                    radius: 48,
                    child: Icon(Icons.person, size: 48),
                  ),

                  const SizedBox(height: 16),

                  // Nome do utilizador
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Email do utilizador
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 32),

                  // Botão de logout
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _logout,
                      child: const Text('Logout'),
                    ),
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
