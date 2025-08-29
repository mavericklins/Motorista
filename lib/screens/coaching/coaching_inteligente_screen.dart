
import 'package:flutter/material.dart';
import '../../services/coaching_inteligente_service.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';

class CoachingInteligenteScreen extends StatefulWidget {
  const CoachingInteligenteScreen({super.key});

  @override
  State<CoachingInteligenteScreen> createState() => _CoachingInteligenteScreenState();
}

class _CoachingInteligenteScreenState extends State<CoachingInteligenteScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final CoachingInteligenteService _coachingService = CoachingInteligenteService();
  
  bool _isLoading = false;
  List<CoachingTip> _tips = [];
  PerformanceAnalysis? _analysis;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: VelloTokens.animationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _loadCoachingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadCoachingData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _tips = [
          CoachingTip(
            id: '1',
            categoria: 'Eficiência',
            titulo: 'Otimize seus Horários',
            descricao: 'Trabalhe nos horários de pico para maximizar seus ganhos',
            detalhes: 'Dados mostram que 18h-22h tem 40% mais demanda na sua região.',
            prioridade: PrioridadeTip.alta,
            icon: Icons.schedule,
            color: VelloTokens.warning,
            progresso: 0.6,
          ),
          CoachingTip(
            id: '2',
            categoria: 'Satisfação',
            titulo: 'Melhore a Experiência',
            descricao: 'Pequenos gestos podem aumentar sua avaliação',
            detalhes: 'Ofereça água, mantenha o carro limpo e seja cordial.',
            prioridade: PrioridadeTip.media,
            icon: Icons.star,
            color: VelloTokens.success,
            progresso: 0.8,
          ),
          CoachingTip(
            id: '3',
            categoria: 'Economia',
            titulo: 'Reduza Combustível',
            descricao: 'Dicas para economizar até 20% em combustível',
            detalhes: 'Acelere suavemente, mantenha velocidade constante.',
            prioridade: PrioridadeTip.baixa,
            icon: Icons.local_gas_station,
            color: VelloTokens.info,
            progresso: 0.3,
          ),
        ];
        
        _analysis = PerformanceAnalysis(
          pontuacaoGeral: 87,
          areas: {
            'Pontualidade': 92,
            'Satisfação': 85,
            'Eficiência': 84,
            'Segurança': 90,
          },
          melhorias: [
            'Aceite mais corridas durante horários de pico',
            'Mantenha conversas amigáveis com passageiros',
            'Use rotas mais eficientes',
          ],
          conquistas: [
            'Top 10% em pontualidade',
            '500+ corridas concluídas',
            'Avaliação 4.8+ por 30 dias',
          ],
        );
        
        _isLoading = false;
      });
      
      _fadeController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: VelloTokens.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.gray50,
      appBar: AppBar(
        title: const Text(
          'Coaching Inteligente',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: VelloTokens.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCoachingData,
            tooltip: 'Atualizar análise',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelloTokens.brand,
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildPerformanceHeader(),
                  _buildTabsSection(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTipsView(),
                        _buildAnalysisView(),
                        _buildAchievementsView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPerformanceHeader() {
    if (_analysis == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: VelloCard.gradient(
        gradient: const LinearGradient(
          colors: [VelloTokens.brand, VelloTokens.brandLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: VelloTokens.radiusLarge,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_analysis!.pontuacaoGeral}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Text(
                            'SCORE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Performance Geral',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getPerformanceMessage(_analysis!.pontuacaoGeral),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              _getPerformanceIcon(_analysis!.pontuacaoGeral),
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getPerformanceLevel(_analysis!.pontuacaoGeral),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: VelloCard(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: VelloTokens.brand,
            borderRadius: VelloTokens.radiusMedium,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: VelloTokens.gray600,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Dicas'),
            Tab(text: 'Análise'),
            Tab(text: 'Conquistas'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tips.length,
      itemBuilder: (context, index) {
        final tip = _tips[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildTipCard(tip),
        );
      },
    );
  }

  Widget _buildTipCard(CoachingTip tip) {
    return VelloCard(
      borderRadius: VelloTokens.radiusXLarge,
      onTap: () => _showTipDetails(tip),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tip.color.withOpacity(0.1),
                    borderRadius: VelloTokens.radiusMedium,
                  ),
                  child: Icon(
                    tip.icon,
                    color: tip.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tip.titulo,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: VelloTokens.gray700,
                              ),
                            ),
                          ),
                          StatusChip(
                            label: _getPriorityLabel(tip.prioridade),
                            type: _getPriorityChipType(tip.prioridade),
                            size: StatusChipSize.small,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip.categoria,
                        style: TextStyle(
                          fontSize: 12,
                          color: VelloTokens.gray500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tip.descricao,
              style: TextStyle(
                fontSize: 14,
                color: VelloTokens.gray600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso de Implementação',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: VelloTokens.gray600,
                      ),
                    ),
                    Text(
                      '${(tip.progresso * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: tip.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: VelloTokens.radiusSmall,
                  child: LinearProgressIndicator(
                    value: tip.progresso,
                    backgroundColor: VelloTokens.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(tip.color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisView() {
    if (_analysis == null) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAreasAnalysis(),
          const SizedBox(height: 16),
          _buildImprovementSuggestions(),
        ],
      ),
    );
  }

  Widget _buildAreasAnalysis() {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Análise por Área',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 20),
            ..._analysis!.areas.entries.map((entry) => _buildAreaScore(
              entry.key,
              entry.value,
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaScore(String area, int score) {
    final color = score >= 90 
        ? VelloTokens.success 
        : score >= 75 
            ? VelloTokens.warning 
            : VelloTokens.danger;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              area,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: VelloTokens.gray600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: VelloTokens.radiusSmall,
              child: LinearProgressIndicator(
                value: score / 100,
                backgroundColor: VelloTokens.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            alignment: Alignment.centerRight,
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementSuggestions() {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: VelloTokens.warning,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Sugestões de Melhoria',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._analysis!.melhorias.asMap().entries.map((entry) => 
              _buildSuggestionItem(entry.key + 1, entry.value)
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(int number, String suggestion) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: VelloTokens.brand,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestion,
              style: TextStyle(
                fontSize: 14,
                color: VelloTokens.gray600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ..._analysis!.conquistas.map((achievement) => 
            _buildAchievementCard(achievement)
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: VelloCard(
        borderRadius: VelloTokens.radiusLarge,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: VelloTokens.warning.withOpacity(0.1),
                  borderRadius: VelloTokens.radiusMedium,
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: VelloTokens.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  achievement,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray700,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle,
                color: VelloTokens.success,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPriorityLabel(PrioridadeTip prioridade) {
    switch (prioridade) {
      case PrioridadeTip.alta:
        return 'Alta';
      case PrioridadeTip.media:
        return 'Média';
      case PrioridadeTip.baixa:
        return 'Baixa';
    }
  }

  StatusChipType _getPriorityChipType(PrioridadeTip prioridade) {
    switch (prioridade) {
      case PrioridadeTip.alta:
        return StatusChipType.error;
      case PrioridadeTip.media:
        return StatusChipType.warning;
      case PrioridadeTip.baixa:
        return StatusChipType.info;
    }
  }

  String _getPerformanceMessage(int score) {
    if (score >= 90) return 'Performance excepcional! Continue assim.';
    if (score >= 75) return 'Boa performance! Algumas melhorias podem ajudar.';
    if (score >= 60) return 'Performance média. Vamos trabalhar juntos.';
    return 'Há muito espaço para crescimento!';
  }

  IconData _getPerformanceIcon(int score) {
    if (score >= 90) return Icons.trending_up;
    if (score >= 75) return Icons.thumb_up;
    if (score >= 60) return Icons.trending_flat;
    return Icons.trending_down;
  }

  String _getPerformanceLevel(int score) {
    if (score >= 90) return 'EXPERT';
    if (score >= 75) return 'AVANÇADO';
    if (score >= 60) return 'INTERMEDIÁRIO';
    return 'INICIANTE';
  }

  void _showTipDetails(CoachingTip tip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: Row(
          children: [
            Icon(tip.icon, color: tip.color),
            const SizedBox(width: 8),
            Expanded(child: Text(tip.titulo)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tip.detalhes,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'Categoria: ${tip.categoria}',
              style: TextStyle(
                fontSize: 14,
                color: VelloTokens.gray600,
              ),
            ),
          ],
        ),
        actions: [
          VelloButton(
            text: 'Marcar como Implementado',
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implementar marcação
            },
            type: VelloButtonType.success,
          ),
          VelloButton(
            text: 'Fechar',
            onPressed: () => Navigator.pop(context),
            type: VelloButtonType.ghost,
          ),
        ],
      ),
    );
  }
}

// Models para o coaching
class CoachingTip {
  final String id;
  final String categoria;
  final String titulo;
  final String descricao;
  final String detalhes;
  final PrioridadeTip prioridade;
  final IconData icon;
  final Color color;
  final double progresso;

  CoachingTip({
    required this.id,
    required this.categoria,
    required this.titulo,
    required this.descricao,
    required this.detalhes,
    required this.prioridade,
    required this.icon,
    required this.color,
    required this.progresso,
  });
}

class PerformanceAnalysis {
  final int pontuacaoGeral;
  final Map<String, int> areas;
  final List<String> melhorias;
  final List<String> conquistas;

  PerformanceAnalysis({
    required this.pontuacaoGeral,
    required this.areas,
    required this.melhorias,
    required this.conquistas,
  });
}

enum PrioridadeTip { alta, media, baixa }
