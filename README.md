ReceitApps

A ReceitApps é uma aplicação móvel criada em Flutter e com backend em Supabase.
Peermite aos utilizadores explorar receitas culinárias, para isso têm que criar uma conta, autenticar-se e podem depois seguir receitas passo a passo.

O projecto inclui prototipagem em Figma.

Aplicação móvel desenvolvida em Flutter, com backend em Supabase, que permite aos utilizadores explorar receitas culinárias, criar conta, autenticar-se e seguir receitas passo a passo.
O projeto inclui prototipagem visual em Figma e integração completa com autenticação e base de dados.



Tecnologias Utilizadas

Flutter: desenvolvimento da aplicação móvel
Dart: linguagem de programação
Supabase: backend (autenticação + base de dados PostgreSQL)
Figma: protótipo visual da aplicação
GitHub: distribuição do código


------------------------

A estrutura da aplicacação é distribuida com os seguntes elementos:

lib/models/  -> Onde estão as classes que representam entidades da app e defindas as estruturas da app: User, Passos das receitas e receitas
lib/services/ -> Aqui fica a lógica de acesso ao backend e a leitura das receitas
lib/screens/ -> Os diferentes ecrãs da aplicação.
lib/widgets/ -> Localização dos componentes usados pelos vários ecrãs
app_theme.dart -> Onde é defenido o tema "look" da aplicação
router.dart -> Contém a lógica da navegação entre os vários ecrãs
main.dart -> Onde iniciamos todos os componebtes da aplicação


------------------------

Supabase

Autenticação:
- Gerida através do Supabase Auth
- Utilizadores autenticam-se por email e palavra-passe

Base de Dados:
Tabelas principais:
 -profiles
   -id
   -name
   -email

 -recipes
   -id
   -title
   -category
   -thumbnail_url

 -recipe_steps
   -id
   -recipe_id
   -step_number
   -title
   -description
   -image_url

Segurança:
 -Row Level Security (RLS) ativa
 -Apenas utilizadores autenticados podem ler receitas e passos
 -Cada utilizador só pode aceder ao seu próprio perfil


------------------------

Figma

O protótipo inclui os seguintes ecrãs:
-Login
-Registo
-Receitas
-Passo-a-Passo
-Perfil

Com navegação entre os 5 ecrãs

https://www.figma.com/proto/44zq9Y2qzYgMzaHl1h31L6/ReceitApps-%E2%80%93-Prot%C3%B3tipo?node-id=0-1&t=QBhqW8o6O7WHn2JD-1


------------------------

Como Executar o Projeto Localmente

1 - Instalar Flutter

2 - Instalar Emulador Android

3 - Conta no Supabase

4 - Clonar o repositório
git clone https://github.com/pauloafonsofraga/receitapps.git
cd receitapps

5 - Criar ficheiro .env na raíz do projecto

SUPABASE_URL=https://TEU-PROJECT-REF.supabase.co
SUPABASE_ANON_KEY=TUA-CHAVE-ANON

(Por questões de segurança o ficheiro .env não pode ser incluído no GitHub.)

6 - Instalar dependências
flutter pub get

7 - Executar a aplicação
flutter run


************* NOTA PARA O PROFESSOR FERNANDO PINHO MARSON **************

Apenas a primeira receita está completa. Julgo que estar a desenvolver passo-a-passo todas a diferentes receitas é um exercício com pouco retorno, visto que estamos essencialmente a copiar/colar. Obrigado Professor.





Paulo Fraga
