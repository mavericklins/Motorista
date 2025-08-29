import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:vello_motorista/constants/app_colors.dart';
import 'package:vello_motorista/services/auth_service.dart';

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

  Future<String> _uploadImage(String uid, File file, String path) async {
    final ref = FirebaseStorage.instance.ref('motoristas_aguardando/$uid/$path');
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  String? _validateCPF(String? value) {
    if (value == null || value.length != 11) return 'CPF inválido';
    final numbers = value.split('').map(int.parse).toList();
    int calc(int base) => List.generate(base, (i) => numbers[i] * (base + 1 - i)).reduce((a, b) => a + b) % 11 < 2 ? 0 : 11 - (List.generate(base, (i) => numbers[i] * (base + 1 - i)).reduce((a, b) => a + b) % 11);
    return numbers[9] == calc(9) && numbers[10] == calc(10) ? null : 'CPF inválido';
  }

  String? _validateEmail(String? value) {
    return value != null && RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}\$').hasMatch(value) ? null : 'Email inválido';
  }

  String? _validateSenha(String? value) {
    if (value == null || value.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return '1 letra maiúscula';
    if (!RegExp(r'[0-9]').hasMatch(value)) return '1 número';
    return null;
  }

  String? _validateAno(String? value) {
    if (value == null) return 'Ano inválido';
    final int? ano = int.tryParse(value);
    final int currentYear = DateTime.now().year;
    return (ano != null && ano >= 1980 && ano <= currentYear) ? null : 'Ano inválido';
  }

  String? _validatePlaca(String? value) {
    return value != null && RegExp(r'^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}\$').hasMatch(value.toUpperCase()) ? null : 'Placa inválida';
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _cnh == null || _selfie == null || _carro == null) return;
    final authService = Provider.of<AuthService>(context, listen: false);

    final success = await authService.createAccount(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted || !success) return;

    final user = authService.currentUser;
    if (user != null) {
      final uid = user.uid;
      final cnhUrl = await _uploadImage(uid, _cnh!, 'cnh.jpg');
      final selfieUrl = await _uploadImage(uid, _selfie!, 'selfie.jpg');
      final carroUrl = await _uploadImage(uid, _carro!, 'carro.jpg');

      await authService.salvarMotoristaParaAprovacao(
        uid: uid,
        nome: _nameController.text.trim(),
        email: _emailController.text.trim(),
        cpf: _cpfController.text.trim(),
        modelo: _modeloController.text.trim(),
        ano: _anoController.text.trim(),
        placa: _placaController.text.trim(),
        cnhUrl: cnhUrl,
        selfieUrl: selfieUrl,
        carroUrl: carroUrl,
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Cadastro enviado'),
          content: const Text('Recebemos seus dados e documentos. A equipe da Vello irá analisá-los e você será notificado por e-mail.'),
          actions: [TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/login'), child: const Text('OK'))],
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: VelloColors.creme,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      backgroundColor: VelloColors.branco,
      appBar: AppBar(
        title: const Text('Cadastro de Motorista'),
        backgroundColor: VelloColors.laranja,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _nameController, decoration: _inputDecoration('Nome completo')),
              const SizedBox(height: 12),
              TextFormField(controller: _cpfController, decoration: _inputDecoration('CPF'), keyboardType: TextInputType.number, validator: _validateCPF),
              const SizedBox(height: 12),
              TextFormField(controller: _emailController, decoration: _inputDecoration('Email'), validator: _validateEmail),
              const SizedBox(height: 12),
              TextFormField(controller: _passwordController, obscureText: true, decoration: _inputDecoration('Senha'), validator: _validateSenha),
              const SizedBox(height: 12),
              TextFormField(controller: _modeloController, decoration: _inputDecoration('Modelo do carro')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: TextFormField(controller: _anoController, decoration: _inputDecoration('Ano'), keyboardType: TextInputType.number, validator: _validateAno)),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(controller: _placaController, decoration: _inputDecoration('Placa'), validator: _validatePlaca)),
              ]),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _pickImage((file) => setState(() => _cnh = file)),
                style: ElevatedButton.styleFrom(backgroundColor: VelloColors.laranja),
                child: Text(_cnh == null ? 'Enviar CNH' : 'CNH enviada'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickImage((file) => setState(() => _selfie = file)),
                style: ElevatedButton.styleFrom(backgroundColor: VelloColors.laranja),
                child: Text(_selfie == null ? 'Enviar selfie com CNH' : 'Selfie enviada'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickImage((file) => setState(() => _carro = file)),
                style: ElevatedButton.styleFrom(backgroundColor: VelloColors.laranja),
                child: Text(_carro == null ? 'Enviar foto do carro' : 'Foto do carro enviada'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: authService.isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: VelloColors.azul,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: authService.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Finalizar cadastro', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
