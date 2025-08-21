import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SobreAppScreen extends StatefulWidget {
  const SobreAppScreen({super.key});

  @override
  State<SobreAppScreen> createState() => _SobreAppScreenState();
}

class _SobreAppScreenState extends State<SobreAppScreen> with TickerProviderStateMixin {
  // Cores da identidade visual Vello
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Sobre o App',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _compartilharApp,
            icon: const Icon(Icons.share),
            tooltip: 'Compartilhar App',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Card principal do app
              _buildAppCard(),
              
              const SizedBox(height: 20),
              
              // Card de informações técnicas
              _buildInfoTecnicaCard(),
              
              const SizedBox(height: 20),
              
              // Card da equipe
              _buildEquipeCard(),
              
              const SizedBox(height: 20),
              
              // Card de recursos
              _buildRecursosCard(),
              
              const SizedBox(height: 20),
              
              // Card de contato
              _buildContatoCard(),
              
              const SizedBox(height: 20),
              
              // Card de agradecimentos
              _buildAgradecimentosCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B3A57), Color(0xFF2A4A6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo do app
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: velloOrange,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: velloOrange.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Vello Motorista',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Versão 2.1.0 (Build 210)',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Conectando motoristas e passageiros com tecnologia, segurança e praticidade.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('50K+', 'Motoristas'),
              _buildStatItem('1M+', 'Corridas'),
              _buildStatItem('4.8★', 'Avaliação'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String numero, String label) {
    return Column(
      children: [
        Text(
          numero,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: velloOrange,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTecnicaCard() {
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
              Icon(Icons.info, color: velloOrange),
              const SizedBox(width: 8),
              const Text(
                'Informações Técnicas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoItem('Versão do App', '2.1.0'),
          _buildInfoItem('Build', '210'),
          _buildInfoItem('Última Atualização', '15 de Janeiro de 2025'),
          _buildInfoItem('Tamanho', '45.2 MB'),
          _buildInfoItem('Compatibilidade', 'Android 7.0+ / iOS 12.0+'),
          _buildInfoItem('Desenvolvido com', 'Flutter 3.16'),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _verificarAtualizacoes,
                  icon: const Icon(Icons.system_update, size: 18),
                  label: const Text('Verificar Atualizações'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: velloOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _copiarInfoSistema,
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar Info'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: velloOrange,
                  side: const BorderSide(color: velloOrange),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: velloBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipeCard() {
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
              Icon(Icons.group, color: velloOrange),
              const SizedBox(width: 8),
              const Text(
                'Nossa Equipe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          const Text(
            'O Vello foi criado por uma equipe apaixonada por tecnologia e mobilidade urbana. Nosso objetivo é revolucionar o transporte, conectando pessoas de forma segura, eficiente e sustentável.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildEquipeMembro('Desenvolvimento', 'Time Tech'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEquipeMembro('Design', 'Time UX/UI'),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildEquipeMembro('Produto', 'Time Product'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEquipeMembro('Suporte', 'Time Customer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipeMembro(String area, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: velloLightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            area,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: velloBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecursosCard() {
    final recursos = [
      {'icon': Icons.gps_fixed, 'title': 'GPS Preciso', 'desc': 'Navegação em tempo real'},
      {'icon': Icons.payment, 'title': 'Pagamentos', 'desc': 'Múltiplas formas de pagamento'},
      {'icon': Icons.security, 'title': 'Segurança', 'desc': 'Verificação completa'},
      {'icon': Icons.support_agent, 'title': 'Suporte 24h', 'desc': 'Atendimento sempre disponível'},
      {'icon': Icons.analytics, 'title': 'Relatórios', 'desc': 'Acompanhe seus ganhos'},
      {'icon': Icons.star, 'title': 'Avaliações', 'desc': 'Sistema de feedback'},
    ];

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
              Icon(Icons.featured_play_list, color: velloOrange),
              const SizedBox(width: 8),
              const Text(
                'Principais Recursos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: recursos.length,
            itemBuilder: (context, index) {
              final recurso = recursos[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: velloLightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      recurso['icon'] as IconData,
                      color: velloOrange,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recurso['title'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: velloBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recurso['desc'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContatoCard() {
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
              Icon(Icons.contact_support, color: velloOrange),
              const SizedBox(width: 8),
              const Text(
                'Entre em Contato',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildContatoItem(
            Icons.email,
            'E-mail',
            'contato@vello.com.br',
            () => _abrirEmail('contato@vello.com.br'),
          ),
          
          _buildContatoItem(
            Icons.phone,
            'Telefone',
            '(11) 4000-0000',
            () => _ligar('(11) 4000-0000'),
          ),
          
          _buildContatoItem(
            Icons.language,
            'Website',
            'www.vello.com.br',
            () => _abrirSite('https://www.vello.com.br'),
          ),
          
          _buildContatoItem(
            Icons.location_on,
            'Endereço',
            'São Paulo, SP - Brasil',
            () => _mostrarEndereco(),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Redes Sociais',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: velloBlue,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(Icons.facebook, 'Facebook'),
              _buildSocialButton(Icons.camera_alt, 'Instagram'),
              _buildSocialButton(Icons.alternate_email, 'Twitter'),
              _buildSocialButton(Icons.video_library, 'YouTube'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContatoItem(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: velloOrange, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: velloBlue,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String platform) {
    return InkWell(
      onTap: () => _abrirRedeSocial(platform),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: velloLightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: velloOrange, size: 20),
            const SizedBox(height: 4),
            Text(
              platform,
              style: const TextStyle(
                fontSize: 10,
                color: velloBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgradecimentosCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            velloOrange.withOpacity(0.1),
            velloOrange.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: velloOrange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.favorite,
            color: velloOrange,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Obrigado!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: velloOrange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agradecemos por fazer parte da família Vello. Juntos, estamos transformando a mobilidade urbana e criando um futuro melhor para todos.',
            style: TextStyle(
              fontSize: 14,
              color: velloOrange,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '© 2025 Vello. Todos os direitos reservados.',
            style: TextStyle(
              fontSize: 12,
              color: velloOrange.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _compartilharApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartilhando Vello Motorista...'),
        backgroundColor: velloOrange,
      ),
    );
  }

  void _verificarAtualizacoes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verificando atualizações...'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _copiarInfoSistema() {
    const info = '''Vello Motorista
Versão: 2.1.0 (Build 210)
Última Atualização: 15 de Janeiro de 2025
Tamanho: 45.2 MB
Compatibilidade: Android 7.0+ / iOS 12.0+
Desenvolvido com: Flutter 3.16''';
    
    Clipboard.setData(const ClipboardData(text: info));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informações copiadas!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _abrirEmail(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo e-mail para $email...')),
    );
  }

  void _ligar(String telefone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ligando para $telefone...')),
    );
  }

  void _abrirSite(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo $url...')),
    );
  }

  void _mostrarEndereco() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo localização...')),
    );
  }

  void _abrirRedeSocial(String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo $platform...')),
    );
  }
}

