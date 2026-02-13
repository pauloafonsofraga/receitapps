import '../models/app_user.dart';
import '../supabase_client.dart';

class AuthService {
  /// Efetua login com email e palavra-passe usando Supabase Auth.
  ///
  /// - Se as credenciais estiverem erradas, o Supabase lança AuthApiException
  ///   (ex.: code = "invalid_credentials").
  /// - Se estiver tudo certo, o Supabase cria uma sessão e a app considera
  ///   o utilizador autenticado.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    // Chamada direta ao Supabase para login por password.
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  /// Cria uma nova conta no Supabase Auth.
  ///
  /// O campo `data: {'name': name}` guarda o nome como metadata do utilizador.
  /// Além disso, se tiveres o trigger SQL (handle_new_user) no Supabase,
  /// ele pode criar automaticamente a linha correspondente na tabela `profiles`.
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    // Cria utilizador no Supabase Auth.
    // A metadata "name" fica associada ao utilizador em `user.userMetadata`.
    await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  /// Termina a sessão do utilizador autenticado (logout).
  ///
  /// Após isto, `supabase.auth.currentSession` passa a ser null
  /// e o router normalmente redireciona para /login.
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Vai buscar o perfil do utilizador à tabela `profiles`.
  ///
  /// Regras:
  /// - Tem de existir um utilizador autenticado (`currentUser`).
  /// - A tabela `profiles` deve conter uma linha com `id = auth.users.id`.
  /// - O método `.single()` assume que existe exatamente 1 resultado.
  Future<AppUser> fetchProfile() async {
    // Obtém o utilizador autenticado na sessão atual.
    final user = supabase.auth.currentUser;

    // Se não existir utilizador autenticado, é erro lógico do fluxo.
    if (user == null) throw Exception('Sem utilizador autenticado.');

    // Consulta à tabela `profiles` para obter os campos necessários.
    // `.eq('id', user.id)` garante que estamos a obter apenas o perfil do dono.
    // `.single()` devolve 1 registo (Map) em vez de uma lista.
    final data = await supabase
        .from('profiles')
        .select('id, name, email')
        .eq('id', user.id)
        .single();

    // Converte Map (JSON) num objeto AppUser.
    return AppUser.fromMap(data);
  }

  /// Versão “robusta” do fetch de perfil.
  ///
  /// Objetivo:
  /// - Se a tabela `profiles` falhar (ex.: trigger não correu, linha não existe,
  ///   permissões/RLS), a app ainda consegue mostrar dados básicos do utilizador
  ///   usando a informação do Auth (email e metadata "name").
  ///
  /// Isto melhora a resiliência do projeto para demonstrações.
  Future<AppUser> fetchProfileFallbackToAuth() async {
    // Obtém o utilizador autenticado na sessão atual.
    final user = supabase.auth.currentUser;

    // Se não existir utilizador autenticado, não há perfil para mostrar.
    if (user == null) throw Exception('Sem utilizador autenticado.');

    try {
      // Primeiro tenta buscar o perfil “oficial” na tabela profiles.
      return await fetchProfile();
    } catch (_) {
      // Se falhar, usa valores do Auth como fallback.

      // Email pode ser null em alguns cenários, por isso usamos '' como default.
      final email = user.email ?? '';

      // O nome foi guardado no signUp como metadata: data: {'name': name}.
      // Se não existir, cai para string vazia.
      final name = (user.userMetadata?['name'] ?? '') as String;

      // Cria um AppUser local com a informação mínima.
      return AppUser(id: user.id, name: name, email: email);
    }
  }
}
