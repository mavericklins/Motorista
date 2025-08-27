import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';
import 'package:vello_motorista/constants/app_colors.dart';
import 'package:vello_motorista/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final success = await authService.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted && success) {
      Navigator.pushReplacementNamed(context, '/main');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email ou senha inválidos'),
          backgroundColor: VelloColors.erro,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloColors.creme,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 50),
              
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: VelloColors.branco,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: VelloColors.pretoTransparente,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_taxi,
                  size: 50,
                  color: VelloColors.laranja,
                ),
              ),
              
              const SizedBox(height: 30),
              
              const Text(
                'VELLO MOTORISTA',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: VelloColors.azul,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Faça login para começar a dirigir',
                style: TextStyle(
                  fontSize: 16,
                  color: VelloColors.cinza,
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Digite seu email',
                  prefixIcon: Icon(Icons.email_outlined, color: VelloColors.laranja),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Senha
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  prefixIcon: Icon(Icons.lock_outline, color: VelloColors.laranja),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Botão Login
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  return Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: VelloColors.gradienteLaranja,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: VelloColors.laranjaTransparente,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: authService.isLoading ? null : _login,
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: authService.isLoading
                              ? const CircularProgressIndicator(color: VelloColors.branco)
                              : const Text(
                                  'ENTRAR',
                                  style: TextStyle(
                                    color: VelloColors.branco,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                        ),
                      ),
                    ),
                  );
                },
              ),   TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          },
          child: const Text(
            'Cadastre-se',
            style: TextStyle(
              color: VelloColors.azul,
              fontWeight: FontWeight.bold,
              fontSize: 16,
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

