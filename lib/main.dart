import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_theme.dart';
import 'router.dart';

/// Função principal da aplicação.
/// É o primeiro código executado quando a app arranca.
Future<void> main() async {
  // Garante que o Flutter está corretamente inicializado
  // antes de executar qualquer código assíncrono.
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente a partir do ficheiro .env
  // Este ficheiro contém dados sensíveis (URL e chave do Supabase)
  await dotenv.load(fileName: ".env");

  // Obtém o URL e a chave anónima do Supabase a partir do .env
  final url = dotenv.env['SUPABASE_URL'];
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

  // Validação defensiva: garante que as variáveis existem
  // Se não existirem, a app não pode arrancar corretamente
  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    throw Exception('Faltam SUPABASE_URL e/ou SUPABASE_ANON_KEY no .env');
  }

  // Inicializa o cliente Supabase
  // A partir deste momento, a app pode comunicar com o backend
  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
  );

  // Arranca a aplicação Flutter
  runApp(const ReceitApps());
}

/// Widget raiz da aplicação.
/// Define o tema global e o sistema de navegação.
class ReceitApps extends StatelessWidget {
  const ReceitApps({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Título da aplicação (usado pelo sistema)
      title: 'ReceitApps',

      // Remove a faixa "DEBUG" no canto superior direito
      debugShowCheckedModeBanner: false,

      // Tema global da aplicação
      theme: appTheme(),

      // Configuração das rotas (go_router)
      routerConfig: router,
    );
  }
}
