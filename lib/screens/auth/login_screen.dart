// Importações necessárias para a tela de login
import 'package:flutter/material.dart'; // Framework Flutter para widgets
import 'package:provider/provider.dart'; // Gerenciamento de estado
import 'register_screen.dart'; // Tela de cadastro
import 'package:vello_motorista/constants/app_colors.dart'; // Cores do app
import 'package:vello_motorista/services/auth_service.dart'; // Serviço de autenticação

// Classe da tela de login (StatefulWidget porque tem estado que muda)
class LoginScreen extends StatefulWidget {
  // Construtor da classe com chave opcional
  const LoginScreen({super.key});

  // Cria o estado da tela
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Estado da tela de login
class _LoginScreenState extends State<LoginScreen> {
  
  // ========== CONTROLADORES DOS CAMPOS DE TEXTO ==========
  
  // Controlador para o campo de email (gerencia o texto digitado)
  final _emailController = TextEditingController();
  
  // Controlador para o campo de senha (gerencia o texto digitado)
  final _passwordController = TextEditingController();

  // ========== LIMPEZA DE RECURSOS ==========
  
  // Função chamada quando a tela é destruída
  @override
  void dispose() {
    // Libera a memória dos controladores para evitar vazamentos
    _emailController.dispose();
    _passwordController.dispose();
    // Chama o dispose da classe pai
    super.dispose();
  }

  // ========== FUNÇÃO DE LOGIN ==========
  
  // Função assíncrona que executa o processo de login
  Future<void> _login() async {
    // Obtém o serviço de autenticação sem escutar mudanças
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Tenta fazer login com email e senha
    final success = await authService.signInWithEmailAndPassword(
      _emailController.text.trim(), // Remove espaços em branco do email
      _passwordController.text, // Senha sem modificação
    );

    // Verifica se o widget ainda está montado e se o login foi bem-sucedido
    if (mounted && success) {
      // Login bem-sucedido: navega para a tela principal
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      // Login falhou: mostra mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email ou senha inválidos'), // Mensagem de erro
          backgroundColor: VelloColors.erro, // Cor vermelha para erro
          behavior: SnackBarBehavior.floating, // SnackBar flutuante
        ),
      );
    }
  }

  // ========== CONSTRUÇÃO DA INTERFACE ==========
  
  // Método que constrói a interface da tela
  @override
  Widget build(BuildContext context) {
    // Scaffold fornece a estrutura básica da tela
    return Scaffold(
      // Cor de fundo da tela (creme suave)
      backgroundColor: VelloColors.creme,
      
      // SafeArea garante que o conteúdo não seja coberto pela barra de status
      body: SafeArea(
        // SingleChildScrollView permite rolar a tela se o conteúdo for muito grande
        child: SingleChildScrollView(
          // Padding adiciona espaçamento em todas as direções
          padding: const EdgeInsets.all(24),
          
          // Column organiza os widgets verticalmente
          child: Column(
            children: [
              // Espaçamento no topo
              const SizedBox(height: 50),
              
              // ========== LOGO DO APLICATIVO ==========
              Container(
                width: 100, // Largura do container do logo
                height: 100, // Altura do container do logo
                decoration: BoxDecoration(
                  color: VelloColors.branco, // Fundo branco
                  borderRadius: BorderRadius.circular(25), // Bordas arredondadas
                  boxShadow: [
                    BoxShadow(
                      color: VelloColors.pretoTransparente, // Cor da sombra
                      blurRadius: 15, // Desfoque da sombra
                      offset: const Offset(0, 5), // Posição da sombra (x, y)
                    ),
                  ],
                ),
                // Ícone de táxi dentro do container
                child: const Icon(
                  Icons.local_taxi, // Ícone de táxi
                  size: 50, // Tamanho do ícone
                  color: VelloColors.laranja, // Cor laranja da Vello
                ),
              ),
              
              // Espaçamento após o logo
              const SizedBox(height: 30),
              
              // ========== TÍTULO DO APLICATIVO ==========
              const Text(
                'VELLO MOTORISTA', // Texto do título
                style: TextStyle(
                  fontSize: 28, // Tamanho da fonte
                  fontWeight: FontWeight.bold, // Texto em negrito
                  color: VelloColors.azul, // Cor azul da Vello
                ),
              ),
              
              // Espaçamento pequeno
              const SizedBox(height: 8),
              
              // ========== SUBTÍTULO ==========
              const Text(
                'Faça login para começar a dirigir', // Texto explicativo
                style: TextStyle(
                  fontSize: 16, // Tamanho menor da fonte
                  color: VelloColors.cinza, // Cor cinza para texto secundário
                ),
              ),
              
              // Espaçamento antes dos campos
              const SizedBox(height: 50),
              
              // ========== CAMPO DE EMAIL ==========
              TextFormField(
                controller: _emailController, // Conecta com o controlador
                keyboardType: TextInputType.emailAddress, // Teclado otimizado para email
                decoration: const InputDecoration(
                  labelText: 'Email', // Rótulo do campo
                  hintText: 'Digite seu email', // Texto de dica
                  prefixIcon: Icon(Icons.email_outlined, color: VelloColors.laranja), // Ícone à esquerda
                ),
              ),
              
              // Espaçamento entre os campos
              const SizedBox(height: 20),
              
              // ========== CAMPO DE SENHA ==========
              TextFormField(
                controller: _passwordController, // Conecta com o controlador
                obscureText: true, // Oculta o texto digitado (para senhas)
                decoration: const InputDecoration(
                  labelText: 'Senha', // Rótulo do campo
                  hintText: 'Digite sua senha', // Texto de dica
                  prefixIcon: Icon(Icons.lock_outline, color: VelloColors.laranja), // Ícone de cadeado
                ),
              ),
              
              // Espaçamento antes do botão
              const SizedBox(height: 30),
              
              // ========== BOTÃO DE LOGIN ==========
              // Consumer escuta mudanças no AuthService
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  return Container(
                    width: double.infinity, // Largura total disponível
                    height: 56, // Altura fixa do botão
                    decoration: BoxDecoration(
                      gradient: VelloColors.gradienteLaranja, // Gradiente laranja
                      borderRadius: BorderRadius.circular(12), // Bordas arredondadas
                      boxShadow: [
                        BoxShadow(
                          color: VelloColors.laranjaTransparente, // Sombra laranja
                          blurRadius: 10, // Desfoque da sombra
                          offset: const Offset(0, 5), // Posição da sombra
                        ),
                      ],
                    ),
                    // Material para efeitos de toque
                    child: Material(
                      color: Colors.transparent, // Fundo transparente
                      // InkWell adiciona efeito de toque
                      child: InkWell(
                        // Se está carregando, desabilita o toque
                        onTap: authService.isLoading ? null : _login,
                        borderRadius: BorderRadius.circular(12), // Bordas do efeito
                        child: Center(
                          // Se está carregando, mostra indicador, senão mostra texto
                          child: authService.isLoading
                              ? const CircularProgressIndicator(color: VelloColors.branco) // Indicador de carregamento
                              : const Text(
                                  'ENTRAR', // Texto do botão
                                  style: TextStyle(
                                    color: VelloColors.branco, // Texto branco
                                    fontSize: 16, // Tamanho da fonte
                                    fontWeight: FontWeight.w600, // Peso da fonte
                                  ),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // ========== BOTÃO DE CADASTRO ==========
              TextButton(
                // Função executada quando o botão é pressionado
                onPressed: () {
                  // Navega para a tela de cadastro
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                // Texto do botão
                child: const Text(
                  'Cadastre-se', // Texto do botão
                  style: TextStyle(
                    color: VelloColors.azul, // Cor azul da Vello
                    fontWeight: FontWeight.bold, // Texto em negrito
                    fontSize: 16, // Tamanho da fonte
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

