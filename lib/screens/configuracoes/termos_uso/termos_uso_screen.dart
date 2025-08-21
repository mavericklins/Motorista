import 'package:flutter/material.dart';

class TermosUsoScreen extends StatefulWidget {
  const TermosUsoScreen({super.key});

  @override
  State<TermosUsoScreen> createState() => _TermosUsoScreenState();
}

class _TermosUsoScreenState extends State<TermosUsoScreen> {
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
          'Termos de Uso',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: _isScrolled ? 4 : 0,
        actions: [
          IconButton(
            onPressed: _compartilharTermos,
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar',
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
            
            // Card dos termos
            _buildTermosCard(),
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
            Icons.description,
            color: velloOrange,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Termos de Uso do Vello',
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
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Color(0xFF3B82F6), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ao usar o aplicativo Vello, você concorda com estes termos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3B82F6),
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

  Widget _buildTermosCard() {
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
            '1. ACEITAÇÃO DOS TERMOS',
            'Ao acessar e usar o aplicativo Vello, você aceita e concorda em ficar vinculado aos termos e condições deste Acordo. Se você não concordar com todos os termos e condições deste acordo, então você não pode acessar o aplicativo ou usar qualquer serviço.',
          ),
          
          _buildSecao(
            '2. DEFINIÇÕES',
            '''• "Vello" refere-se ao aplicativo de transporte e à empresa operadora
• "Motorista" refere-se ao usuário que oferece serviços de transporte
• "Passageiro" refere-se ao usuário que solicita serviços de transporte
• "Plataforma" refere-se ao aplicativo móvel e sistemas relacionados
• "Serviços" refere-se aos serviços de intermediação de transporte oferecidos''',
          ),
          
          _buildSecao(
            '3. ELEGIBILIDADE',
            '''Para usar os serviços como motorista, você deve:
• Ter pelo menos 21 anos de idade
• Possuir carteira de habilitação válida categoria B ou superior
• Ter veículo próprio em boas condições
• Fornecer documentação completa e válida
• Passar por processo de verificação e aprovação
• Não ter antecedentes criminais que impeçam a atividade''',
          ),
          
          _buildSecao(
            '4. CADASTRO E CONTA',
            '''• Você é responsável por manter a confidencialidade de sua conta
• Deve fornecer informações precisas e atualizadas
• É responsável por todas as atividades que ocorrem em sua conta
• Deve notificar imediatamente sobre uso não autorizado
• O Vello pode suspender ou encerrar contas que violem os termos''',
          ),
          
          _buildSecao(
            '5. SERVIÇOS OFERECIDOS',
            '''O Vello oferece uma plataforma tecnológica que:
• Conecta motoristas e passageiros
• Facilita o pagamento de corridas
• Fornece ferramentas de navegação
• Oferece suporte ao usuário
• Mantém histórico de viagens
• Processa avaliações e feedback''',
          ),
          
          _buildSecao(
            '6. OBRIGAÇÕES DO MOTORISTA',
            '''Como motorista, você deve:
• Manter veículo em boas condições de segurança
• Possuir seguro válido e documentação em dia
• Tratar passageiros com respeito e cortesia
• Seguir as leis de trânsito e regulamentações locais
• Manter higiene pessoal e do veículo
• Não discriminar passageiros por qualquer motivo
• Aceitar formas de pagamento disponíveis na plataforma''',
          ),
          
          _buildSecao(
            '7. PAGAMENTOS E TARIFAS',
            '''• As tarifas são calculadas automaticamente pela plataforma
• O Vello retém uma comissão sobre cada corrida
• Pagamentos são processados semanalmente
• Motoristas são responsáveis por suas obrigações fiscais
• Disputas de pagamento devem ser reportadas em até 7 dias
• Reembolsos seguem política específica da empresa''',
          ),
          
          _buildSecao(
            '8. AVALIAÇÕES E FEEDBACK',
            '''• Motoristas e passageiros podem avaliar uns aos outros
• Avaliações são importantes para manter qualidade do serviço
• Avaliações muito baixas podem resultar em suspensão
• Feedback falso ou malicioso é proibido
• O Vello pode remover avaliações inadequadas''',
          ),
          
          _buildSecao(
            '9. SUSPENSÃO E CANCELAMENTO',
            '''O Vello pode suspender ou cancelar sua conta se:
• Violar qualquer termo deste acordo
• Fornecer informações falsas
• Receber avaliações consistentemente baixas
• Envolver-se em atividades ilegais
• Não manter documentação válida
• Comportar-se de forma inadequada''',
          ),
          
          _buildSecao(
            '10. LIMITAÇÃO DE RESPONSABILIDADE',
            '''• O Vello atua apenas como intermediário
• Não é responsável por danos durante as corridas
• Motoristas são contratantes independentes
• Cada parte é responsável por seus próprios atos
• Limitamos nossa responsabilidade conforme permitido por lei''',
          ),
          
          _buildSecao(
            '11. PROPRIEDADE INTELECTUAL',
            '''• O aplicativo e conteúdo são propriedade do Vello
• Motoristas recebem licença limitada de uso
• É proibido copiar, modificar ou distribuir o aplicativo
• Marcas registradas pertencem aos respectivos proprietários
• Violações podem resultar em ação legal''',
          ),
          
          _buildSecao(
            '12. PRIVACIDADE E DADOS',
            '''• Coletamos dados conforme nossa Política de Privacidade
• Dados são usados para melhorar serviços
• Compartilhamos dados apenas quando necessário
• Você pode solicitar acesso aos seus dados
• Implementamos medidas de segurança adequadas''',
          ),
          
          _buildSecao(
            '13. ALTERAÇÕES DOS TERMOS',
            '''• Podemos modificar estes termos a qualquer momento
• Alterações serão notificadas através do aplicativo
• Uso continuado implica aceitação das mudanças
• Termos anteriores permanecem válidos até substituição
• Versão mais recente sempre prevalece''',
          ),
          
          _buildSecao(
            '14. LEI APLICÁVEL',
            '''• Estes termos são regidos pelas leis brasileiras
• Disputas serão resolvidas nos tribunais competentes
• Tentaremos resolver conflitos amigavelmente primeiro
• Mediação pode ser usada quando apropriada
• Jurisdição é da comarca da sede da empresa''',
          ),
          
          _buildSecao(
            '15. CONTATO',
            '''Para dúvidas sobre estes termos, entre em contato:
• E-mail: juridico@vello.com.br
• Telefone: (11) 4000-0000
• Endereço: Rua das Empresas, 123 - São Paulo/SP
• Horário: Segunda a Sexta, 9h às 18h''',
          ),
          
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: velloOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: velloOrange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Importante',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: velloOrange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estes termos constituem o acordo completo entre você e o Vello. Ao continuar usando nossos serviços, você confirma que leu, entendeu e concorda com todos os termos aqui estabelecidos.',
                  style: TextStyle(
                    fontSize: 14,
                    color: velloOrange,
                  ),
                ),
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

  void _compartilharTermos() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartilhando Termos de Uso...'),
        backgroundColor: velloOrange,
      ),
    );
  }
}

