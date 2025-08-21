import 'package:flutter/material.dart';

class PoliticaPrivacidadeScreen extends StatefulWidget {
  const PoliticaPrivacidadeScreen({super.key});

  @override
  State<PoliticaPrivacidadeScreen> createState() => _PoliticaPrivacidadeScreenState();
}

class _PoliticaPrivacidadeScreenState extends State<PoliticaPrivacidadeScreen> {
  // Cores da identidade visual Vello
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 100 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Política de Privacidade',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: _isScrolled ? 4 : 0,
        actions: [
          IconButton(
            onPressed: _baixarPolitica,
            icon: const Icon(Icons.download),
            tooltip: 'Baixar PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card de informações
            _buildInfoCard(),
            
            const SizedBox(height: 20),
            
            // Card da política
            _buildPoliticaCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
        children: [
          Icon(
            Icons.privacy_tip,
            color: velloOrange,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Política de Privacidade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: velloBlue,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Última atualização: 15 de Janeiro de 2025',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Color(0xFF10B981), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seus dados são protegidos e tratados com total segurança',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoliticaCard() {
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
          _buildSecao(
            '1. INTRODUÇÃO',
            'A Vello valoriza sua privacidade e está comprometida em proteger seus dados pessoais. Esta Política de Privacidade explica como coletamos, usamos, armazenamos e protegemos suas informações quando você usa nosso aplicativo e serviços.',
          ),
          
          _buildSecao(
            '2. INFORMAÇÕES QUE COLETAMOS',
            '''Coletamos diferentes tipos de informações para fornecer nossos serviços:

DADOS PESSOAIS:
• Nome completo e data de nascimento
• CPF e RG
• Endereço residencial
• Telefone e e-mail
• Foto do perfil

DADOS DO VEÍCULO:
• Marca, modelo, ano e cor
• Placa, RENAVAM e chassi
• Documentos do veículo (CRLV)
• Fotos do veículo

DADOS DE LOCALIZAÇÃO:
• Localização em tempo real durante corridas
• Histórico de rotas e destinos
• Pontos de partida e chegada

DADOS DE USO:
• Informações sobre como você usa o app
• Preferências e configurações
• Histórico de corridas e avaliações
• Dados de performance e estatísticas''',
          ),
          
          _buildSecao(
            '3. COMO COLETAMOS SUAS INFORMAÇÕES',
            '''Coletamos informações através de:

• Cadastro e verificação de conta
• Uso do aplicativo e serviços
• Interações com suporte ao cliente
• Dispositivos móveis e sensores
• Cookies e tecnologias similares
• Parceiros e fornecedores autorizados
• Fontes públicas quando permitido por lei''',
          ),
          
          _buildSecao(
            '4. COMO USAMOS SUAS INFORMAÇÕES',
            '''Usamos suas informações para:

PRESTAÇÃO DE SERVIÇOS:
• Conectar motoristas e passageiros
• Processar pagamentos e corridas
• Fornecer navegação e rotas
• Manter histórico de viagens

SEGURANÇA E VERIFICAÇÃO:
• Verificar identidade e documentos
• Prevenir fraudes e atividades suspeitas
• Garantir segurança de usuários
• Investigar incidentes quando necessário

MELHORIA DOS SERVIÇOS:
• Analisar padrões de uso
• Desenvolver novos recursos
• Otimizar performance do app
• Personalizar experiência do usuário

COMUNICAÇÃO:
• Enviar notificações importantes
• Fornecer suporte ao cliente
• Informar sobre atualizações
• Enviar comunicações promocionais (com consentimento)''',
          ),
          
          _buildSecao(
            '5. COMPARTILHAMENTO DE INFORMAÇÕES',
            '''Compartilhamos informações limitadas apenas quando necessário:

COM PASSAGEIROS:
• Nome e foto do motorista
• Informações do veículo
• Localização durante a corrida
• Avaliações e comentários

COM PARCEIROS DE SERVIÇO:
• Processadores de pagamento
• Serviços de verificação de antecedentes
• Provedores de mapas e navegação
• Serviços de análise e métricas

POR EXIGÊNCIA LEGAL:
• Autoridades competentes quando requerido
• Processos judiciais válidos
• Investigações de segurança pública
• Cumprimento de regulamentações

NUNCA VENDEMOS seus dados pessoais para terceiros.''',
          ),
          
          _buildSecao(
            '6. ARMAZENAMENTO E SEGURANÇA',
            '''MEDIDAS DE SEGURANÇA:
• Criptografia de dados sensíveis
• Servidores seguros e protegidos
• Controle de acesso restrito
• Monitoramento contínuo de segurança
• Auditorias regulares de segurança

RETENÇÃO DE DADOS:
• Dados são mantidos pelo tempo necessário
• Exclusão automática após período legal
• Backup seguro para recuperação
• Políticas de retenção específicas por tipo de dado''',
          ),
          
          _buildSecao(
            '7. SEUS DIREITOS',
            '''Você tem os seguintes direitos sobre seus dados:

ACESSO:
• Solicitar cópia dos seus dados
• Verificar como são processados
• Obter informações sobre compartilhamento

CORREÇÃO:
• Atualizar informações incorretas
• Completar dados incompletos
• Corrigir erros nos registros

EXCLUSÃO:
• Solicitar remoção de dados
• Cancelar conta permanentemente
• Exercer "direito ao esquecimento"

PORTABILIDADE:
• Receber dados em formato estruturado
• Transferir dados para outro serviço
• Exportar histórico e informações

OPOSIÇÃO:
• Opor-se ao processamento
• Retirar consentimento
• Limitar uso de dados''',
          ),
          
          _buildSecao(
            '8. COOKIES E TECNOLOGIAS',
            '''Usamos cookies e tecnologias similares para:
• Manter você logado no aplicativo
• Lembrar suas preferências
• Analisar uso e performance
• Personalizar conteúdo
• Melhorar segurança

Você pode gerenciar cookies através das configurações do seu dispositivo.''',
          ),
          
          _buildSecao(
            '9. TRANSFERÊNCIAS INTERNACIONAIS',
            '''Seus dados podem ser transferidos para outros países para:
• Processamento em servidores seguros
• Backup e recuperação de dados
• Serviços de parceiros globais
• Cumprimento de regulamentações

Garantimos proteção adequada em todas as transferências.''',
          ),
          
          _buildSecao(
            '10. MENORES DE IDADE',
            '''• Nossos serviços são destinados a maiores de 18 anos
• Não coletamos dados de menores intencionalmente
• Pais podem solicitar remoção de dados de menores
• Verificamos idade durante o cadastro''',
          ),
          
          _buildSecao(
            '11. ALTERAÇÕES NA POLÍTICA',
            '''• Podemos atualizar esta política periodicamente
• Alterações significativas serão notificadas
• Nova versão será disponibilizada no app
• Data de atualização sempre indicada
• Uso continuado implica aceitação das mudanças''',
          ),
          
          _buildSecao(
            '12. CONTATO E EXERCÍCIO DE DIREITOS',
            '''Para exercer seus direitos ou esclarecer dúvidas:

E-MAIL: privacidade@vello.com.br
TELEFONE: (11) 4000-0000
ENDEREÇO: Rua das Empresas, 123 - São Paulo/SP
HORÁRIO: Segunda a Sexta, 9h às 18h

ENCARREGADO DE DADOS (DPO):
E-mail: dpo@vello.com.br

Responderemos sua solicitação em até 15 dias úteis.''',
          ),
          
          const SizedBox(height: 20),
          
          // Card de resumo dos direitos
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withOpacity(0.1),
                  const Color(0xFF10B981).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_user,
                      color: const Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Seus Direitos em Resumo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDireitoItem('Acessar seus dados a qualquer momento'),
                _buildDireitoItem('Corrigir informações incorretas'),
                _buildDireitoItem('Solicitar exclusão de dados'),
                _buildDireitoItem('Exportar seus dados'),
                _buildDireitoItem('Retirar consentimento'),
                _buildDireitoItem('Entrar em contato com nosso DPO'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecao(String titulo, String conteudo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: velloBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            conteudo,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildDireitoItem(String direito) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              direito,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _baixarPolitica() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Baixando Política de Privacidade em PDF...'),
        backgroundColor: velloOrange,
      ),
    );
  }
}

