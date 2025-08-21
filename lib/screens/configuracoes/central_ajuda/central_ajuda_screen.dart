import 'package:flutter/material.dart';

class CentralAjudaScreen extends StatefulWidget {
  const CentralAjudaScreen({super.key});

  @override
  State<CentralAjudaScreen> createState() => _CentralAjudaScreenState();
}

class _CentralAjudaScreenState extends State<CentralAjudaScreen> {
  // Cores da identidade visual Vello
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqItems = [
    {
      'categoria': 'Conta',
      'pergunta': 'Como alterar minha senha?',
      'resposta': 'Vá em Configurações > Alterar Senha. Digite sua senha atual e a nova senha duas vezes para confirmar.',
      'tags': ['senha', 'conta', 'segurança'],
    },
    {
      'categoria': 'Corridas',
      'pergunta': 'Como aceitar uma corrida?',
      'resposta': 'Quando receber uma notificação de corrida, toque em "Aceitar" na tela. Você tem 30 segundos para responder.',
      'tags': ['corrida', 'aceitar', 'notificação'],
    },
    {
      'categoria': 'Corridas',
      'pergunta': 'Posso cancelar uma corrida após aceitar?',
      'resposta': 'Sim, mas evite cancelamentos frequentes. Toque no botão "Cancelar Corrida" e selecione o motivo.',
      'tags': ['cancelar', 'corrida', 'motivo'],
    },
    {
      'categoria': 'Pagamentos',
      'pergunta': 'Quando recebo o pagamento das corridas?',
      'resposta': 'Os pagamentos são processados semanalmente, toda segunda-feira, para corridas da semana anterior.',
      'tags': ['pagamento', 'semanal', 'transferência'],
    },
    {
      'categoria': 'Pagamentos',
      'pergunta': 'Como alterar minha conta bancária?',
      'resposta': 'Vá em Perfil > Dados Bancários e atualize suas informações. A alteração será validada em até 2 dias úteis.',
      'tags': ['conta', 'bancária', 'dados'],
    },
    {
      'categoria': 'Veículo',
      'pergunta': 'Preciso atualizar os documentos do veículo?',
      'resposta': 'Sim, mantenha sempre atualizados: CRLV, seguro obrigatório e documentos pessoais.',
      'tags': ['documentos', 'veículo', 'crlv'],
    },
    {
      'categoria': 'App',
      'pergunta': 'O app não está funcionando corretamente',
      'resposta': 'Tente fechar e abrir o app novamente. Se persistir, reinicie o celular ou entre em contato conosco.',
      'tags': ['app', 'problema', 'bug'],
    },
    {
      'categoria': 'Avaliação',
      'pergunta': 'Como melhorar minha avaliação?',
      'resposta': 'Seja pontual, mantenha o veículo limpo, seja educado e siga as rotas sugeridas pelo GPS.',
      'tags': ['avaliação', 'nota', 'dicas'],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaq = _filterFaq();
    final categorias = _getCategorias();

    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Central de Ajuda',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          _buildSearchBar(),
          
          // Lista de conteúdo
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_searchQuery.isEmpty) ...[
                    // Card de contato rápido
                    _buildQuickContactCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Categorias
                    _buildCategoriesSection(categorias),
                    
                    const SizedBox(height: 20),
                  ],
                  
                  // FAQ
                  _buildFaqSection(filteredFaq),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: velloOrange,
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Pesquisar ajuda...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(Icons.clear, color: Color(0xFF6B7280)),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildQuickContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B3A57), Color(0xFF2A4A6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.headset_mic,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          const Text(
            'Precisa de Ajuda?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nossa equipe está pronta para ajudar você',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _falarComSuporte,
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Chat'),
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
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _ligarSuporte,
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Ligar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: velloBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(List<String> categorias) {
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
          const Text(
            'Categorias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: velloBlue,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categorias.map((categoria) {
              return InkWell(
                onTap: () => _filtrarPorCategoria(categoria),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: velloOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: velloOrange.withOpacity(0.3)),
                  ),
                  child: Text(
                    categoria,
                    style: const TextStyle(
                      color: velloOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(List<Map<String, dynamic>> faqItems) {
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
          Text(
            _searchQuery.isNotEmpty 
                ? 'Resultados da Pesquisa (${faqItems.length})'
                : 'Perguntas Frequentes',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: velloBlue,
            ),
          ),
          const SizedBox(height: 16),
          if (faqItems.isEmpty)
            _buildEmptyState()
          else
            ...faqItems.map((item) => _buildFaqItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          item['pergunta'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: velloBlue,
          ),
        ),
        subtitle: Text(
          item['categoria'],
          style: TextStyle(
            fontSize: 12,
            color: velloOrange,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['resposta'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _avaliarResposta(item, true),
                      icon: const Icon(Icons.thumb_up, size: 16),
                      label: const Text('Útil'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF10B981),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _avaliarResposta(item, false),
                      icon: const Icon(Icons.thumb_down, size: 16),
                      label: const Text('Não útil'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente pesquisar com outras palavras',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _falarComSuporte,
            icon: const Icon(Icons.chat),
            label: const Text('Falar com Suporte'),
            style: ElevatedButton.styleFrom(
              backgroundColor: velloOrange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterFaq() {
    if (_searchQuery.isEmpty) return _faqItems;
    
    return _faqItems.where((item) {
      final pergunta = item['pergunta'].toString().toLowerCase();
      final resposta = item['resposta'].toString().toLowerCase();
      final categoria = item['categoria'].toString().toLowerCase();
      final tags = (item['tags'] as List<String>).join(' ').toLowerCase();
      
      return pergunta.contains(_searchQuery) ||
             resposta.contains(_searchQuery) ||
             categoria.contains(_searchQuery) ||
             tags.contains(_searchQuery);
    }).toList();
  }

  List<String> _getCategorias() {
    return _faqItems
        .map((item) => item['categoria'] as String)
        .toSet()
        .toList()
        ..sort();
  }

  void _filtrarPorCategoria(String categoria) {
    setState(() {
      _searchQuery = categoria.toLowerCase();
      _searchController.text = categoria;
    });
  }

  void _falarComSuporte() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo chat com suporte...')),
    );
  }

  void _ligarSuporte() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ligando para (11) 4000-0000...')),
    );
  }

  void _avaliarResposta(Map<String, dynamic> item, bool util) {
    final feedback = util ? 'útil' : 'não útil';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Obrigado! Sua avaliação como "$feedback" foi registrada.'),
        backgroundColor: util ? const Color(0xFF10B981) : Colors.orange.shade600,
      ),
    );
  }
}

