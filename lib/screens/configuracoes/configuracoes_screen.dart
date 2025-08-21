import 'package:flutter/material.dart';

// Imports das sub-páginas
import 'alterar_senha/alterar_senha_screen.dart';
import 'dados_pessoais/dados_pessoais_screen.dart';
import 'informacoes_veiculo/informacoes_veiculo_screen.dart';
import 'central_ajuda/central_ajuda_screen.dart';
import 'falar_suporte/falar_suporte_screen.dart';
import 'reportar_problema/reportar_problema_screen.dart';
import 'termos_uso/termos_uso_screen.dart';
import 'politica_privacidade/politica_privacidade_screen.dart';
import 'sobre_app/sobre_app_screen.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  // Cores da identidade visual Vello
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SEÇÃO CONTA
          _buildSectionCard(
            title: 'Conta',
            icon: Icons.person,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.lock,
                title: 'Alterar Senha',
                subtitle: 'Modificar sua senha de acesso',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AlterarSenhaScreen()),
                ),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.person_outline,
                title: 'Dados Pessoais',
                subtitle: 'Editar informações do perfil',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DadosPessoaisScreen()),
                ),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.directions_car,
                title: 'Informações do Veículo',
                subtitle: 'Atualizar dados do seu veículo',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InformacoesVeiculoScreen()),
                ),
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SEÇÃO SUPORTE
          _buildSectionCard(
            title: 'Suporte',
            icon: Icons.support_agent,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.help_outline,
                title: 'Central de Ajuda',
                subtitle: 'Perguntas frequentes e tutoriais',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CentralAjudaScreen()),
                ),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.chat_outlined,
                title: 'Falar com Suporte',
                subtitle: 'Entre em contato conosco',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FalarSuporteScreen()),
                ),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.bug_report_outlined,
                title: 'Reportar Problema',
                subtitle: 'Relate bugs ou problemas técnicos',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportarProblemaScreen()),
                ),
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SEÇÃO INFORMAÇÕES
          _buildSectionCard(
            title: 'Informações',
            icon: Icons.info_outline,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.description_outlined,
                title: 'Termos de Uso',
                subtitle: 'Leia os termos e condições',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermosUsoScreen()),
                ),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.privacy_tip_outlined,
                title: 'Política de Privacidade',
                subtitle: 'Como tratamos seus dados',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PoliticaPrivacidadeScreen()),
                ),
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.info_outlined,
                title: 'Sobre o App',
                subtitle: 'Versão e informações técnicas',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SobreAppScreen()),
                ),
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
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
          // Cabeçalho da seção
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: velloOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: velloOrange,
                    size: 20,
                  ),
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
          ),
          
          // Itens da seção
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: velloOrange,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: velloBlue,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF6B7280),
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        if (isLast) const SizedBox(height: 12),
      ],
    );
  }
}

