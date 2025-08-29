
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
  final CoachingInteligenteService _coachingService = CoachingInteligenteService();
  
  late TabController _tabController;
  bool _isLoading = false;
  List<CoachingTip> _tips = [];
  PerformanceAnalysis? _analysis;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCoachingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCoachingData() async {
    setState(() => _isLoading = true);

    try {
      // Simular dados de coaching
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _tips = [
          CoachingTip(
            id: '1',
            titulo: 'Otimize suas rotas',
            descricao: 'Use apps de navegação para encontrar caminhos mais eficientes',
            categoria: 'Eficiência',
            prioridade: PrioridadeTip.alta,
            impactoEstimado: 'Economia de 15% no combustível',
            implementacao: 'Configure alertas de trânsito no app',
          ),
          CoachingTip(
            id: '2',
            titulo: 'Horários de pico',
            descricao: 'Trabalhe nos horários com maior demanda para maximizar ganhos',
            categoria: 'Estratégia',
            prioridade: PrioridadeTip.alta,
            impactoEstimado: 'Aumento de 25% nos ganhos',
            implementacao: 'Foque nos períodos: 7-9h e 17-19h',
          ),
          CoachingTip(
            id: '3',
            titulo: 'Manutenção preventiva',
            descricao: 'Mantenha seu veículo sempre em ordem para evitar problemas',
            categoria: 'Manutenção',
            prioridade: PrioridadeTip.media,
            impactoEstimado: 'Redução de 30% em custos de reparo',
            implementacao: 'Revisão a cada 10.000 km',
          ),
        ];

        _analysis = PerformanceAnalysis(
          pontuacaoGeral: 8.2,
          eficienciaCombustivel: 7.8,
          avaliacaoClientes: 9.1,
          pontualidade: 8.5,
          areasParaMelhoria: [
            'Planejamento de rotas',
            'Gestão de combustível',
          ],
          pontosFortes: [
            'Excelente atendimento',
            'Alta pontualidade',
          ],
        );

        _isLoading = false;
      });
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
            tooltip: 'Atualizar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Dicas', icon: Icon(Icons.lightbulb)),
            Tab(text: 'Análise', icon: Icon(Icons.analytics)),
            Tab(text: 'Progresso', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelloTokens.brand,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTipsView(),
                _buildAnalysisView(),
                _buildProgressView(),
              ],
            ),
    );
  }

  Widget _buildTipsView() {
    if (_tips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 64,
              color: VelloTokens.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma dica disponível',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas dicas personalizadas aparecerão aqui',
              style: TextStyle(
                fontSize: 14,
                color: VelloTokens.gray500,
              ),
            ),
          ],
        ),
      );
    }

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

  Widget _buildAnalysisView() {
    if (_analysis == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: VelloTokens.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              'Análise indisponível',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceScore(),
          const SizedBox(height: 20),
          _buildDetailedMetrics(),
          const SizedBox(height: 20),
          _buildImprovementAreas(),
          const SizedBox(height: 20),
          _buildStrengths(),
        ],
      ),
    );
  }

  Widget _buildProgressView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressHeader(),
          const SizedBox(height: 20),
          _buildProgressChart(),
          const SizedBox(height: 20),
          _buildGoals(),
        ],
      ),
    );
  }

  Widget _buildTipCard(CoachingTip tip) {
    final priorityColor = _getPriorityColor(tip.prioridade);
    
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
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
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: VelloTokens.radiusMedium,
                  ),
                  child: Icon(
                    Icons.lightbulb,
                    color: priorityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.titulo,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: VelloTokens.gray700,
                        ),
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
                StatusChip(
                  text: _getPriorityLabel(tip.prioridade),
                  type: _getPriorityChipType(tip.prioridade),
                  size: StatusChipSize.small,
                  status: DriverStatus.online,
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VelloTokens.success.withOpacity(0.1),
                borderRadius: VelloTokens.radiusMedium,
                border: Border.all(
                  color: VelloTokens.success.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: VelloTokens.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Impacto: ${tip.impactoEstimado}',
                      style: TextStyle(
                        fontSize: 12,
                        color: VelloTokens.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceScore() {
    final score = _analysis!.pontuacaoGeral;
    final scoreColor = score >= 8.0 ? VelloTokens.success : 
                     score >= 6.0 ? VelloTokens.warning : VelloTokens.danger;

    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Pontuação Geral',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: scoreColor,
                  width: 8,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: scoreColor,
                      ),
                    ),
                    Text(
                      '/ 10.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: VelloTokens.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getScoreDescription(score),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: VelloTokens.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedMetrics() {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métricas Detalhadas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 20),
            _buildMetricRow('Eficiência Combustível', _analysis!.eficienciaCombustivel),
            const SizedBox(height: 12),
            _buildMetricRow('Avaliação Clientes', _analysis!.avaliacaoClientes),
            const SizedBox(height: 12),
            _buildMetricRow('Pontualidade', _analysis!.pontualidade),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, double value) {
    final percentage = (value / 10.0);
    final color = value >= 8.0 ? VelloTokens.success :
                 value >= 6.0 ? VelloTokens.warning : VelloTokens.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: VelloTokens.gray600,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: VelloTokens.gray200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildImprovementAreas() {
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
                  Icons.trending_up,
                  color: VelloTokens.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Áreas para Melhoria',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._analysis!.areasParaMelhoria.map((area) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: VelloTokens.warning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    area,
                    style: TextStyle(
                      fontSize: 14,
                      color: VelloTokens.gray600,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengths() {
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
                  Icons.star,
                  color: VelloTokens.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pontos Fortes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._analysis!.pontosFortes.map((ponto) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: VelloTokens.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    ponto,
                    style: TextStyle(
                      fontSize: 14,
                      color: VelloTokens.gray600,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seu Progresso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Acompanhe sua evolução ao longo do tempo',
              style: TextStyle(
                fontSize: 14,
                color: VelloTokens.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart() {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolução da Pontuação',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: VelloTokens.gray100,
                borderRadius: VelloTokens.radiusMedium,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48,
                      color: VelloTokens.gray400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gráfico em desenvolvimento',
                      style: TextStyle(
                        color: VelloTokens.gray500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoals() {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metas de Melhoria',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalItem('Aumentar eficiência para 8.5', 7.8, 8.5),
            const SizedBox(height: 12),
            _buildGoalItem('Manter avaliação acima de 9.0', 9.1, 9.0),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(String goal, double current, double target) {
    final progress = current / target;
    final isCompleted = current >= target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? VelloTokens.success : VelloTokens.gray400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                goal,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: VelloTokens.gray600,
                ),
              ),
            ),
            Text(
              '${current.toStringAsFixed(1)}/${target.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 12,
                color: VelloTokens.gray500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: VelloTokens.gray200,
          valueColor: AlwaysStoppedAnimation<Color>(
            isCompleted ? VelloTokens.success : VelloTokens.brand,
          ),
        ),
      ],
    );
  }

  Color _getPriorityColor(PrioridadeTip prioridade) {
    switch (prioridade) {
      case PrioridadeTip.alta:
        return VelloTokens.danger;
      case PrioridadeTip.media:
        return VelloTokens.warning;
      case PrioridadeTip.baixa:
        return VelloTokens.info;
    }
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

  String _getScoreDescription(double score) {
    if (score >= 9.0) return 'Excelente performance! Continue assim!';
    if (score >= 7.5) return 'Boa performance, com algumas oportunidades de melhoria';
    if (score >= 6.0) return 'Performance regular, há várias áreas para melhorar';
    return 'Performance abaixo do esperado, foque nas dicas de melhoria';
  }

  void _showTipDetails(CoachingTip tip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: Text(tip.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tip.descricao),
            const SizedBox(height: 16),
            Text(
              'Como implementar:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(tip.implementacao),
            const SizedBox(height: 16),
            Text(
              'Impacto esperado:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(tip.impactoEstimado),
          ],
        ),
        actions: [
          VelloButton(
            text: 'Fechar',
            onPressed: () => Navigator.pop(context),
            type: VelloButtonType.primary,
          ),
        ],
      ),
    );
  }
}

class CoachingTip {
  final String id;
  final String titulo;
  final String descricao;
  final String categoria;
  final PrioridadeTip prioridade;
  final String impactoEstimado;
  final String implementacao;

  CoachingTip({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.impactoEstimado,
    required this.implementacao,
  });
}

class PerformanceAnalysis {
  final double pontuacaoGeral;
  final double eficienciaCombustivel;
  final double avaliacaoClientes;
  final double pontualidade;
  final List<String> areasParaMelhoria;
  final List<String> pontosFortes;

  PerformanceAnalysis({
    required this.pontuacaoGeral,
    required this.eficienciaCombustivel,
    required this.avaliacaoClientes,
    required this.pontualidade,
    required this.areasParaMelhoria,
    required this.pontosFortes,
  });
}

enum PrioridadeTip { alta, media, baixa }
