import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _auth = AuthService();

  bool _loading = false;

  Future<void> _onLogin() async {
    // 1) Validar formulário
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 2) Tentar autenticar no Supabase
      await _auth.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      // 3) Se login OK, navegar para receitas
      if (!mounted) return;
      context.go('/recipes');
    } on AuthApiException catch (e) {
      // Erros do Supabase Auth (ex.: credenciais inválidas)
      String msg = 'Erro no login. Tenta novamente.';

      if (e.code == 'invalid_credentials') {
        msg = 'Email ou palavra-passe incorretos';
      } else if (e.code == 'email_not_confirmed') {
        msg = 'Confirma o teu email antes de entrar';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      // Qualquer outro erro (rede/config)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.soup_kitchen, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Introduz o email';
                    if (!s.contains('@') || !s.contains('.')) return 'Email inválido';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Palavra-passe'),
                  validator: (v) {
                    final s = (v ?? '');
                    if (s.isEmpty) return 'Introduz a palavra-passe';
                    if (s.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _onLogin,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Entrar'),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => context.go('/register'),
                  child: const Text('Criar conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
