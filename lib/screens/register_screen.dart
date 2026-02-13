import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../widgets/primary_button.dart';
import '../widgets/text_field_x.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;

  String? _validateName(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Nome obrigatório';
    if (s.length < 2) return 'Nome muito curto';
    return null;
  }

  String? _validateEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email obrigatório';
    if (!s.contains('@') || !s.contains('.')) return 'Email inválido';
    return null;
  }

  String? _validatePassword(String? v) {
    final s = (v ?? '');
    if (s.isEmpty) return 'Palavra-passe obrigatória';
    if (s.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _auth.signUp(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );

      if (!mounted) return;

      // Em alguns projetos, o email precisa de confirmação.
      // Então aqui mandamos para Login sempre, e mostramos uma mensagem.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta criada! Agora faz login (pode ser preciso confirmar o email).'),
        ),
      );

      context.go('/login');
    } catch (e, st) {
      debugPrint('SIGNUP ERROR: $e');
      debugPrint('SIGNUP STACK: $st');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no registo: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registo')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_add, size: 56),
                            const SizedBox(height: 12),
                            const Text(
                              'Criar conta',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 24),

                            TextFieldX(
                              controller: _name,
                              label: 'Nome',
                              keyboardType: TextInputType.name,
                              obscureText: false,
                              validator: _validateName,
                            ),
                            const SizedBox(height: 12),

                            TextFieldX(
                              controller: _email,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              obscureText: false,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 12),

                            TextFieldX(
                              controller: _password,
                              label: 'Palavra-passe',
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 16),

                            PrimaryButton(
                              text: 'Registar',
                              loading: _loading,
                              onPressed: _onRegister,
                            ),
                            const SizedBox(height: 12),

                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text('Já tenho conta'),
                            ),

                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
