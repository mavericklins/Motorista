import 'package:flutter/material.dart';
import 'alterar_senha/alterar_senha_screen.dart';
import 'dados_pessoais/dados_pessoais_screen.dart';
// ... outros imports

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  // Cores da identidade visual Vello
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

  // Estados das configurações
  bool notificacoesPush = true;
  bool notificacoesSom = true;
  bool notificacoesVibracao = true;
  bool modoEconomiaEnergia = false;
  bool compartilharLocalizacao = true;
  bool aceitarCorridasAutomaticamente = false;
  String idiomaApp = 'Português';
  String temaApp = 'Claro';
  double raioAceitacao = 5.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Configurações',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Seção de Notificações
            _buildSectionCard(
              'Notificações',
              Icons.notifications,
              [
                _buildSwitchItem(
                  'Notificações Push',
                  'Receber notificações de novas corridas',
                  notificacoesPush,
                  (value) => setState(() => notificacoesPush = value),
                ),
                _buildSwitchItem(
                  'Som das Notificações',
                  'Reproduzir som ao receber notificações',
                  notificacoesSom,
                  (value) => setState(() => notificacoesSom = value),
                ),
                _buildSwitchItem(
                  'Vibração',
                  'Vibrar ao receber notificações',
                  notificacoesVibracao,
                  (value) => setState(() => notificacoesVibracao = value),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Seção de Corridas
            _buildSectionCard(
              'Corridas',
              Icons.directions_car,
              [
                _buildSwitchItem(
                  'Aceitar Automaticamente',
                  'Aceitar corridas automaticamente dentro do raio',
                  aceitarCorridasAutomaticamente,
                  (value) => setState(() => aceitarCorridasAutomaticamente = value),
                ),
                _buildSliderItem(
                  'Raio de Aceitação',
                  'Distância máxima para aceitar corridas',
                  raioAceitacao,
                  1.0,
                  20.0,
                  '${raioAceitacao.toStringAsFixed(1)} km',
                  (value) => setState(() => raioAceitacao = value),
                ),
                _buildSwitchItem(
                  'Compartilhar Localização',
                  'Permitir que passageiros vejam sua localização',
                  compartilharLocalizacao,
                  (value) => setState(() => compartilharLocalizacao = value),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Seção de Aplicativo
            _buildSectionCard(
              'Aplicativo',
              Icons.smartphone,
              [
                _buildDropdownItem(
                  'Idioma',
                  'Idioma do aplicativo',
                  idiomaApp,
                  ['Português', 'English', 'Español'],
                  (value) => setState(() => idiomaApp = value!),
                ),
                _buildDropdownItem(
                  'Tema',
                  'Aparência do aplicativo',
                  temaApp,
                  ['Claro', 'Escuro', 'Automático'],
                  (value) => setState(() => temaApp = value!),
                ),
                _buildSwitchItem(
                  'Modo Economia de Energia',
                  'Reduzir consumo de bateria',
                  modoEconomiaEnergia,
                  (value) => setState(() => modoEconomiaEnergia = value),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Seção de Conta
            _buildSectionCard(
              'Conta',
              Icons.account_circle,
              [
                _buildActionItem(
                  'Alterar Senha',
                  'Modificar sua senha de acesso',
                  Icons.lock,
                  () => _alterarSenha(),
                ),
                _buildActionItem(
                  'Dados Pessoais',
                  'Editar informações do perfil',
                  Icons.person,
                  () => _editarDadosPessoais(),
                ),
                _buildActionItem(
                  'Informações do Veículo',
                  'Atualizar dados do seu veículo',
                  Icons.directions_car,
                  () => _editarVeiculo(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Seção de Suporte
            _buildSectionCard(
              'Suporte',
              Icons.help,
              [
                _buildActionItem(
                  'Central de Ajuda',
                  'Perguntas frequentes e tutoriais',
                  Icons.help_outline,
                  () => _abrirCentralAjuda(),
                ),
                _buildActionItem(
                  'Falar com Suporte',
                  'Entre em contato conosco',
                  Icons.chat,
                  () => _falarComSuporte(),
                ),
                _buildActionItem(
                  'Reportar Problema',
                  'Relate bugs ou problemas técnicos',
                  Icons.bug_report,
                  () => _reportarProblema(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Seção de Informações
            _buildSectionCard(
              'Informações',
              Icons.info,
              [
                _buildActionItem(
                  'Termos de Uso',
                  'Leia os termos e condições',
                  Icons.description,
                  () => _abrirTermos(),
                ),
                _buildActionItem(
                  'Política de Privacidade',
                  'Como tratamos seus dados',
                  Icons.privacy_tip,
                  () => _abrirPrivacidade(),
                ),
                _buildActionItem(
                  'Sobre o App',
                  'Versão e informações técnicas',
                  Icons.info_outline,
                  () => _abrirSobre(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Botão de salvar configurações
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _salvarConfiguracoes,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Salvar Configurações',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: velloOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: velloCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: velloOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: velloOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: velloBlue,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: velloOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(String title, String subtitle, double value, double min, double max, String displayValue, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: velloBlue,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              Text(
                displayValue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: velloOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: velloOrange,
              thumbColor: velloOrange,
              overlayColor: velloOrange.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(String title, String subtitle, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: velloBlue,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: velloOrange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: velloBlue,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  // Funções de ação
  void _alterarSenha() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo alteração de senha...')),
    );
  }

  void _editarDadosPessoais() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo edição de dados pessoais...')),
    );
  }

  void _editarVeiculo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo edição de veículo...')),
    );
  }

  void _abrirCentralAjuda() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo central de ajuda...')),
    );
  }

  void _falarComSuporte() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo chat com suporte...')),
    );
  }

  void _reportarProblema() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo formulário de problema...')),
    );
  }

  void _abrirTermos() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo termos de uso...')),
    );
  }

  void _abrirPrivacidade() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo política de privacidade...')),
    );
  }

  void _abrirSobre() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo informações do app...')),
    );
  }

  void _salvarConfiguracoes() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configurações salvas com sucesso!'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

