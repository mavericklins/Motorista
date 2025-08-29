import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/metas_inteligentes_service.dart';
import '../../models/meta_inteligente.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';

class MetasInteligentesScreen extends StatefulWidget {
  const MetasInteligentesScreen({super.key});

  @override
  State<MetasInteligentesScreen> createState() => _MetasInteligentesScreenState();
}

class _MetasInteligentesScreenState extends State<MetasInteligentesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MetasInteligentesService _metasService = MetasInteligentesService();

  List<MetaInteligente> _metasAtivas = [];
  List<MetaInteligente> _metasConcluidas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMetas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMetas() async {
    setState(() => _isLoading = true);

    try {
      // Simular dados de metas
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _metasAtivas = [
          MetaInteligente(
            id: '1',
            titulo: 'Meta Semanal Premium',
            descricao: 'Complete 50 corridas esta semana',
            tipo: TipoMeta.corridas,
            categoria: CategoriaMeta.produtividade,
            valorObjetivo: 50,
            valorAlvo: 50,
            valorAtual: 32,
            dataInicio: DateTime.now().subtract(const Duration(days: 4)),
            dataFim: DateTime.now().add(const Duration(days: 3)),
            prazo: DateTime.now().add(const Duration(days: 3)),
            recompensa: 'Bônus de R\$ 150',
            dificuldade: DificuldadeMeta.media,
            isAtiva: true,
            status: StatusMeta.ativa,
          ),
          MetaInteligente(
            id: '2',
            titulo: 'Ganhos do Mês',
            descricao: 'Alcance R\$ 3.500 em ganhos este mês',
            tipo: TipoMeta.ganhos,
            categoria: CategoriaMeta.crescimento,
            valorObjetivo: 3500,
            valorAlvo: 3500,
            valorAtual: 2247.50,
            dataInicio: DateTime.now().subtract(const Duration(days: 18)),
            dataFim: DateTime.now().add(const Duration(days: 12)),
            prazo: DateTime.now().add(const Duration(days: 12)),
            recompensa: 'Cashback de 5%',
            dificuldade: DificuldadeMeta.dificil,
            isAtiva: true,
            status: StatusMeta.ativa,
          ),
          MetaInteligente(
            id: '3',
            titulo: 'Avaliação 5 Estrelas',
            descricao: 'Mantenha avaliação média acima de 4.8',
            tipo: TipoMeta.avaliacao,
            categoria: CategoriaMeta.habito,
            valorObjetivo: 4.8,
            valorAlvo: 4.8,
            valorAtual: 4.9,
            dataInicio: DateTime.now().subtract(const Duration(days: 3)),
            dataFim: DateTime.now().add(const Duration(days: 7)),
            prazo: DateTime.now().add(const Duration(days: 7)),
            recompensa: 'Badge Premium',
            dificuldade: DificuldadeMeta.facil,
            isAtiva: true,
            status: StatusMeta.ativa,
          ),
        ];

        _metasConcluidas = [
          MetaInteligente(
            id: '4',
            titulo: 'Primeira Semana',
            descricao: 'Complete 20 corridas na primeira semana',
            tipo: TipoMeta.corridas,
            categoria: CategoriaMeta.produtividade,
            valorObjetivo: 20,
            valorAlvo: 20,
            valorAtual: 20,
            dataInicio: DateTime.now().subtract(const Duration(days: 12)),
            dataFim: DateTime.now().subtract(const Duration(days: 5)),
            prazo: DateTime.now().subtract(const Duration(days: 5)),
            recompensa: 'Bônus de R\$ 50',
            dificuldade: DificuldadeMeta.facil,
            isAtiva: false,
            completada: true,
            status: StatusMeta.concluida,
          ),
          MetaInteligente(
            id: '5',
            titulo: 'Meta de Eficiência',
            descricao: 'Mantenha uma eficiência acima de 15 pontos',
            tipo: TipoMeta.eficiencia,
            categoria: CategoriaMeta.estrategia,
            valorObjetivo: 15.0,
            valorAlvo: 15.0,
            valorAtual: 15.0,
            dataInicio: DateTime.now().subtract(const Duration(days: 8)),
            dataFim: DateTime.now().subtract(const Duration(days: 1)),
            prazo: DateTime.now().subtract(const Duration(days: 1)),
            recompensa: 'Badge bronze',
            isAtiva: false,
            completada: true,
            status: StatusMeta.concluida,
          ),
          MetaInteligente(
            id: '6',
            titulo: 'Meta de Avaliação Diária',
            descricao: 'Mantenha uma avaliação média diária de 4.5',
            tipo: TipoMeta.avaliacao,
            categoria: CategoriaMeta.habito,
            valorObjetivo: 4.5,
            valorAlvo: 4.5,
            valorAtual: 4.5,
            dataInicio: DateTime.now().subtract(const Duration(days: 10)),
            dataFim: DateTime.now().subtract(const Duration(days: 3)),
            prazo: DateTime.now().subtract(const Duration(days: 3)),
            recompensa: 'Estrela de qualidade',
            isAtiva: false,
            completada: true,
            status: StatusMeta.concluida,
          ),
        ];

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar metas: $e'),
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
          'Metas Inteligentes',
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
            onPressed: _loadMetas,
            tooltip: 'Atualizar metas',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateMetaDialog(),
            tooltip: 'Nova meta',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelloTokens.brand,
              ),
            )
          : Column(
              children: [
                _buildSummaryHeader(),
                _buildTabsSection(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActiveMetas(),
                      _buildCompletedMetas(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader() {
    final metasCompletas = _metasConcluidas.length;
    final metasAndamento = _metasAtivas.length;
    final proximaPremio = _metasAtivas.isNotEmpty
        ? _metasAtivas.first.recompensa
        : 'Nenhuma meta ativa';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Progresso Geral',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryMetric(
                      'Completas',
                      metasCompletas.toString(),
                      Icons.check_circle,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Em Andamento',
                      metasAndamento.toString(),
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: VelloTokens.radiusMedium,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Próximo Prêmio',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      proximaPremio,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: VelloTokens.radiusSmall,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
          tabs: [
            Tab(
              text: 'Ativas (${_metasAtivas.length})',
            ),
            Tab(
              text: 'Concluídas (${_metasConcluidas.length})',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveMetas() {
    if (_metasAtivas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: VelloTokens.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma meta ativa',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie uma nova meta para começar',
              style: TextStyle(
                fontSize: 14,
                color: VelloTokens.gray500,
              ),
            ),
            const SizedBox(height: 24),
            VelloButton(
              text: 'Criar Meta',
              onPressed: () => _showCreateMetaDialog(),
              type: VelloButtonType.primary,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _metasAtivas.length,
      itemBuilder: (context, index) {
        final meta = _metasAtivas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMetaCard(meta),
        );
      },
    );
  }

  Widget _buildCompletedMetas() {
    if (_metasConcluidas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: VelloTokens.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma meta concluída',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete suas metas para vê-las aqui',
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
      itemCount: _metasConcluidas.length,
      itemBuilder: (context, index) {
        final meta = _metasConcluidas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMetaCard(meta, isCompleted: true),
        );
      },
    );
  }

  Widget _buildMetaCard(MetaInteligente meta, {bool isCompleted = false}) {
    final progress = meta.valorAlvo == 0 ? 0 : (meta.valorAtual / meta.valorAlvo).clamp(0.0, 1.0);
    final progressColor = isCompleted
        ? VelloTokens.success
        : progress >= 0.8
            ? VelloTokens.success
            : progress >= 0.5
                ? VelloTokens.warning
                : VelloTokens.brand;

    return VelloCard(
      borderRadius: VelloTokens.radiusXLarge,
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
                    color: progressColor.withOpacity(0.1),
                    borderRadius: VelloTokens.radiusMedium,
                  ),
                  child: Icon(
                    _getMetaIcon(meta.tipo),
                    color: progressColor,
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
                              meta.titulo,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: VelloTokens.gray700,
                              ),
                            ),
                          ),
                          StatusChip(
                            text: _getDifficultyLabel(meta.dificuldade),
                            type: _getDifficultyChipType(meta.dificuldade),
                            size: StatusChipSize.small,
                            status: DriverStatus.online,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta.descricao,
                        style: TextStyle(
                          fontSize: 12,
                          color: VelloTokens.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: VelloTokens.gray600,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: VelloTokens.radiusSmall,
                  child: LinearProgressIndicator(
                    value: progress.toDouble(),
                    backgroundColor: VelloTokens.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatMetaValue(meta.tipo, meta.valorAtual),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: VelloTokens.gray700,
                      ),
                    ),
                    Text(
                      _formatMetaValue(meta.tipo, meta.valorAlvo),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: VelloTokens.gray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Reward and deadline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VelloTokens.gray50,
                borderRadius: VelloTokens.radiusMedium,
                border: Border.all(
                  color: VelloTokens.gray200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              color: VelloTokens.warning,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Recompensa',
                              style: TextStyle(
                                fontSize: 12,
                                color: VelloTokens.gray600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meta.recompensa,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: VelloTokens.gray700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: VelloTokens.info,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Prazo',
                            style: TextStyle(
                              fontSize: 12,
                              color: VelloTokens.gray600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDeadline(meta.prazo),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: VelloTokens.gray700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Check if meta is completed to display StatusChip
            if (meta.isAtiva == false) ...[
              const SizedBox(height: 16),
              StatusChip(
                text: _getStatusText(meta.status),
                type: _getStatusChipType(meta.status),
                size: StatusChipSize.small,
                status: DriverStatus.online,
              ),
            ]
          ],
        ),
      ),
    );
  }

  IconData _getMetaIcon(TipoMeta tipo) {
    switch (tipo) {
      case TipoMeta.corridas:
        return Icons.local_taxi;
      case TipoMeta.ganhos:
        return Icons.attach_money;
      case TipoMeta.avaliacao:
        return Icons.star;
      case TipoMeta.tempo:
        return Icons.schedule;
      case TipoMeta.distancia:
        return Icons.route;
      case TipoMeta.eficiencia:
        return Icons.bolt;
      case TipoMeta.ganhosDiarios:
        return Icons.attach_money;
      case TipoMeta.corridasCompletadas:
        return Icons.directions_run;
      case TipoMeta.avaliacaoMedia:
        return Icons.star_half;
      case TipoMeta.economiaGeral:
        return Icons.savings;
      case TipoMeta.tempoOnline:
        return Icons.timer;
      case TipoMeta.distanciaPercorrida:
        return Icons.map;
    }
  }

  String _getDifficultyLabel(DificuldadeMeta dificuldade) {
    switch (dificuldade) {
      case DificuldadeMeta.facil:
        return 'Fácil';
      case DificuldadeMeta.media:
        return 'Média';
      case DificuldadeMeta.dificil:
        return 'Difícil';
    }
  }

  StatusChipType _getDifficultyChipType(DificuldadeMeta dificuldade) {
    switch (dificuldade) {
      case DificuldadeMeta.facil:
        return StatusChipType.success;
      case DificuldadeMeta.media:
        return StatusChipType.warning;
      case DificuldadeMeta.dificil:
        return StatusChipType.error;
    }
  }

  String _getStatusText(StatusMeta status) {
    switch (status) {
      case StatusMeta.ativa:
        return 'Ativa';
      case StatusMeta.concluida:
        return 'Concluída';
      case StatusMeta.pausada:
        return 'Pausada';
    }
  }

  StatusChipType _getStatusChipType(StatusMeta status) {
    switch (status) {
      case StatusMeta.ativa:
        return StatusChipType.info;
      case StatusMeta.concluida:
        return StatusChipType.success;
      case StatusMeta.pausada:
        return StatusChipType.warning;
    }
  }

  String _formatMetaValue(TipoMeta tipo, double valor) {
    switch (tipo) {
      case TipoMeta.corridas:
      case TipoMeta.corridasCompletadas:
        return '${valor.toInt()} corridas';
      case TipoMeta.ganhos:
      case TipoMeta.ganhosDiarios:
        return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
      case TipoMeta.avaliacao:
      case TipoMeta.avaliacaoMedia:
        return '${valor.toStringAsFixed(1)} ⭐';
      case TipoMeta.tempo:
      case TipoMeta.tempoOnline:
        return '${valor.toInt()}h';
      case TipoMeta.distancia:
      case TipoMeta.distanciaPercorrida:
        return '${valor.toInt()}km';
      case TipoMeta.eficiencia:
        return '${valor.toStringAsFixed(0)} pontos de eficiência';
      case TipoMeta.economiaGeral:
        return '${valor.toStringAsFixed(1)}% de economia';
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return 'Expirado';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dias';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inMinutes}min';
    }
  }

  void _showCreateMetaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Nova Meta'),
        content: const Text(
          'Funcionalidade de criação de metas personalizadas será implementada em breve.\n\nAs metas inteligentes são geradas automaticamente baseadas no seu desempenho.',
        ),
        actions: [
          VelloButton(
            text: 'Entendi',
            onPressed: () => Navigator.pop(context),
            type: VelloButtonType.primary,
          ),
        ],
      ),
    );
  }
}