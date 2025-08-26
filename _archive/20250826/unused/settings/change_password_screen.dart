import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Identidade visual (mesmas cores do perfil)
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();

  bool _obOld = true, _obNew = true, _obConfirm = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'Usuário não autenticado.');
      return;
    }
    final email = user.email;
    if (email == null || email.isEmpty) {
      setState(() => _error =
      'Sua conta não possui e-mail/senha. Use “Esqueci minha senha”/relogin.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Reautenticar com a senha atual
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _old.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // 2) Atualizar senha
      await user.updatePassword(_new.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada com sucesso.')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = 'Falha ao alterar senha.';
      switch (e.code) {
        case 'wrong-password':
          msg = 'Senha atual incorreta.';
          break;
        case 'requires-recent-login':
          msg =
          'Sessão antiga. Faça login novamente ou use “Esqueci minha senha”.';
          break;
        case 'weak-password':
          msg = 'Nova senha muito fraca.';
          break;
        default:
          msg = e.message ?? msg;
      }
      setState(() => _error = msg);
    } catch (e) {
      setState(() => _error = 'Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateNew(String? v) {
    final s = (v ?? '').trim();
    if (s.length < 8) return 'Mínimo 8 caracteres';
    // opcional: força pelo menos 1 letra e 1 número
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(s);
    final hasDigit = RegExp(r'\d').hasMatch(s);
    if (!hasLetter || !hasDigit) {
      return 'Use letras e números';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text('Alterar Senha'),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Conteúdo
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _card(
                      child: Column(
                        children: [
                          _passwordField(
                            label: 'Senha atual',
                            controller: _old,
                            obscure: _obOld,
                            toggle: () => setState(() => _obOld = !_obOld),
                          ),
                          const SizedBox(height: 12),
                          _passwordField(
                            label: 'Nova senha',
                            controller: _new,
                            obscure: _obNew,
                            toggle: () => setState(() => _obNew = !_obNew),
                            validator: _validateNew,
                          ),
                          const SizedBox(height: 12),
                          _passwordField(
                            label: 'Confirmar nova senha',
                            controller: _confirm,
                            obscure: _obConfirm,
                            toggle: () =>
                                setState(() => _obConfirm = !_obConfirm),
                            validator: (v) => (v ?? '').trim() !=
                                _new.text.trim()
                                ? 'Senhas não conferem'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _card(
                        color: Colors.red.withOpacity(.06),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Botão fixo
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: velloOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Text(
                    'Salvar nova senha',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _card({required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? velloCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator ??
              (v) => (v ?? '').trim().isEmpty ? 'Informe $label' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: velloBlue),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}