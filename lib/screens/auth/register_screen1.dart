import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:vello_motorista/constants/app_colors.dart';
import 'package:vello_motorista/services/auth_service.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cpfController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anoController = TextEditingController();
  final _placaController = TextEditingController();

  File? _cnh;
  File? _selfie;
  File? _carro;

  final picker = ImagePicker();

  Future<void> _pickImage(Function(File) setImage) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setImage(File(picked.path));
    }
  }

  // ========== UPLOAD PARA IMGUR ==========
  
  Future<String> _uploadToImgur(File imageFile) async {
    try {
      // Ler arquivo como bytes
      Uint8List imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // API do Imgur (cliente público - sem necessidade de chave)
      final response = await http.post(
        Uri.parse('https://api.imgur.com/3/image'),
        headers: {
          'Authorization': 'Client-ID 546c25a59c58ad7', // Cliente público do Imgur
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Image,
          'type': 'base64',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['link']; // URL da imagem
      } else {
        print('Erro no upload: ${response.body}');
        return '';
      }
    } catch (e) {
      print('Erro no upload para Imgur: $e');
      return '';
    }
  }

  // ========== VALIDAÇÕES RIGOROSAS ==========

  String? _validateCPF(String? value) {
    if (value == null || value.isEmpty) return 'CPF é obrigatório';
    
    String cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cpf.length != 11) return 'CPF deve ter 11 dígitos';
    
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return 'CPF inválido';
    
    List<int> numbers = cpf.split('').map(int.parse).toList();
    
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += numbers[i] * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;
    
    if (numbers[9] != firstDigit) return 'CPF inválido';
    
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += numbers[i] * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;
    
    if (numbers[10] != secondDigit) return 'CPF inválido';
    
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email é obrigatório';
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }

  String? _validateSenha(String? value) {
    if (value == null || value.isEmpty) return 'Senha é obrigatória';
    
    if (value.length < 8) return 'Mínimo 8 caracteres';
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Deve conter pelo menos 1 letra maiúscula';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Deve conter pelo menos 1 letra minúscula';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Deve conter pelo menos 1 número';
    }
    
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Deve conter pelo menos 1 caractere especial (@#\$%&*)';
    }
    
    return null;
  }

  String? _validateAno(String? value) {
    if (value == null || value.isEmpty) return 'Ano é obrigatório';
    
    final int? ano = int.tryParse(value);
    if (ano == null) return 'Ano deve ser um número';
    
    final int currentYear = DateTime.now().year;
    
    if (ano < 1960) return 'Ano deve ser a partir de 1960';
    if (ano > currentYear) return 'Ano não pode ser maior que $currentYear';
    
    return null;
  }

  String? _validatePlaca(String? value) {
    if (value == null || value.isEmpty) return 'Placa é obrigatória';
    
    String placa = value.toUpperCase().replaceAll('-', '');
    
    final placaRegex = RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$');
    
    if (!placaRegex.hasMatch(placa)) {
      return 'Placa inválida (formato: ABC1234 ou ABC1D23)';
    }
    
    return null;
  }

  String? _validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field é obrigatório';
    }
    return null;
  }

  Future<void> _register() async {
    // Validar formulário
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Corrija os erros no formulário'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar imagens
    if (_cnh == null || _selfie == null || _carro == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Envie todas as fotos obrigatórias'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Criando conta...'),
            ],
          ),
        ),
      );

      // Criar conta no Firebase Auth
      final success = await authService.createAccount(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar conta: ${authService.errorMessage ?? "Erro desconhecido"}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Atualizar loading
      Navigator.pop(context);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Enviando fotos...'),
            ],
          ),
        ),
      );

      final user = authService.currentUser;
      if (user != null) {
        final uid = user.uid;

        // Upload das imagens para Imgur
        String cnhUrl = '';
        String selfieUrl = '';
        String carroUrl = '';

        try {
          cnhUrl = await _uploadToImgur(_cnh!);
          selfieUrl = await _uploadToImgur(_selfie!);
          carroUrl = await _uploadToImgur(_carro!);
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro no upload das fotos: $e'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Atualizar loading
        Navigator.pop(context);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Salvando dados...'),
              ],
            ),
          ),
        );

        // Salvar dados no Firestore
        await authService.salvarMotoristaParaAprovacao(
          uid: uid,
          nome: _nameController.text.trim(),
          email: _emailController.text.trim(),
          cpf: _cpfController.text.trim(),
          modelo: _modeloController.text.trim(),
          ano: _anoController.text.trim(),
          placa: _placaController.text.trim().toUpperCase(),
          cnhUrl: cnhUrl,
          selfieUrl: selfieUrl,
          carroUrl: carroUrl,
        );

        Navigator.pop(context);

        // Sucesso
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sucesso!'),
            content: Text('Cadastro realizado com sucesso!\n\nSeus dados e fotos foram enviados para análise.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no cadastro: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloColors.creme,
      appBar: AppBar(
        title: Text('Cadastro de Motorista'),
        backgroundColor: VelloColors.laranja,
        foregroundColor: VelloColors.branco,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nome
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => _validateRequired(value, 'Nome'),
              ),
              SizedBox(height: 16),

              // CPF
              TextFormField(
                controller: _cpfController,
                decoration: InputDecoration(
                  labelText: 'CPF (somente números)',
                  prefixIcon: Icon(Icons.credit_card),
                  helperText: 'Digite apenas os números do CPF',
                ),
                keyboardType: TextInputType.number,
                validator: _validateCPF,
              ),
              SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  helperText: 'exemplo@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              SizedBox(height: 16),

              // Senha
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock),
                  helperText: '8+ chars, maiúscula, minúscula, número, especial',
                ),
                obscureText: true,
                validator: _validateSenha,
              ),
              SizedBox(height: 16),

              // Modelo do carro
              TextFormField(
                controller: _modeloController,
                decoration: InputDecoration(
                  labelText: 'Modelo do carro',
                  prefixIcon: Icon(Icons.directions_car),
                ),
                validator: (value) => _validateRequired(value, 'Modelo'),
              ),
              SizedBox(height: 16),

              // Ano
              TextFormField(
                controller: _anoController,
                decoration: InputDecoration(
                  labelText: 'Ano (a partir de 1960)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: _validateAno,
              ),
              SizedBox(height: 16),

              // Placa
              TextFormField(
                controller: _placaController,
                decoration: InputDecoration(
                  labelText: 'Placa',
                  prefixIcon: Icon(Icons.confirmation_number),
                  helperText: 'Formato: ABC1234 ou ABC1D23',
                ),
                validator: _validatePlaca,
              ),
              SizedBox(height: 24),

              // Botões de imagem
              _buildImageButton(
                'CNH enviada',
                _cnh != null,
                () => _pickImage((file) => setState(() => _cnh = file)),
              ),
              SizedBox(height: 12),

              _buildImageButton(
                'Selfie enviada',
                _selfie != null,
                () => _pickImage((file) => setState(() => _selfie = file)),
              ),
              SizedBox(height: 12),

              _buildImageButton(
                'Foto do carro enviada',
                _carro != null,
                () => _pickImage((file) => setState(() => _carro = file)),
              ),
              SizedBox(height: 32),

              // Botão de cadastro
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VelloColors.azul,
                    foregroundColor: VelloColors.branco,
                  ),
                  child: Text(
                    'Finalizar cadastro',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Info sobre Imgur
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fotos são enviadas para Imgur (gratuito e seguro)',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageButton(String text, bool uploaded, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: uploaded ? Colors.green : VelloColors.laranja,
          foregroundColor: VelloColors.branco,
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

