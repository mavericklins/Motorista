
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/metas_inteligentes_service.dart';
import '../../models/meta_inteligente.dart';
import '../../constants/app_colors.dart';

class MetasInteligentesScreen extends StatefulWidget {
  const MetasInteligentesScreen({super.key});

  @override
  State<MetasInteligentesScreen> createState() => _MetasInteligentesScreenState();
}

class _MetasInteligentesScreenState extends State<MetasInteligentesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _inicializarMetas();
  }

  Future<void> _inicializarMetas() async {
    final service = Provider.of<MetasInteligentesService>(context, listen: false);
    await service.gerarMetasPersonalizadas();
    await service.gerarInsightsPersonalizados();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Metas Inteligentes',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _atualizarMetas,
          ),
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: () => _mostrarInsights(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Ativas'),
            Tab(text: 'Concluídas'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Consumer<MetasInteligentesService>(
              builder: (context, service, child) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMetasAtivas(service.metas),
                    _buildMetasConcluidas(service.metas),
                    _buildInsights(service.performance, service.previsoes),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _criarMetaPersonalizada,
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Meta',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Analisando seu perfil...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Gerando metas personalizadas',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetasAtivas(List<MetaInteligente> metas) {
    final metasAtivas = metas.where((m) => m.ativa && !m.completada && !m.expirada).toList();
    
    if (metasAtivas.isEmpty) {
      return _buildEmptyState(
        'Nenhuma meta ativa',
        'Suas metas personalizadas aparecerão aqui',
        Icons.target,
      );
    }

    return RefreshIndicator(
      onRefresh: _atualizarMetas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: metasAtivas.length,
        itemBuilder: (context, index) {
          return _buildMetaCard(metasAtivas[index]);
        },
      ),
    );
  }

  Widget _buildMetasConcluidas(List<MetaInteligente> metas) {
    final metasConcluidas = metas.where((m) => m.completada).toList();
    
    if (metasConcluidas.isEmpty) {
      return _buildEmptyState(
        'Nenhuma meta concluída',
        'Complete suas primeiras metas para vê-las aqui',
        Icons.emoji_events,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: metasConcluidas.length,
      itemBuilder: (context, index) {
        return _buildMetaCard(metasConcluidas[index]);
      },
    );
  }

  Widget _buildMetaCard(MetaInteligente meta) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: meta.completada
            ? Border.all(color: Colors.green.shade300, width: 2)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCorCategoria(meta.categoria).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconeTipoMeta(meta.tipo),
                    color: _getCorCategoria(meta.categoria),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        meta.descricao,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (meta.completada)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Barra de progresso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progresso: ${meta.progressoPorcentagem}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _formatarValor(meta.valorAtual, meta.tipo) + ' / ' + _formatarValor(meta.valorObjetivo, meta.tipo),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: meta.progresso,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    meta.completada ? Colors.green : _getCorCategoria(meta.categoria),
                  ),
                  minHeight: 6,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Informações adicionais
            Row(
              children: [
                _buildInfoChip(
                  Icons.schedule,
                  _formatarTempoRestante(meta),
                  meta.expirada ? Colors.red : Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.star,
                  'R\$ ${meta.recompensa.toStringAsFixed(2)}',
                  Colors.amber,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.trending_up,
                  _formatarDificuldade(meta.dificuldade),
                  _getCorDificuldade(meta.dificuldade),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(Map<String, dynamic> performance, Map<String, dynamic> previsoes) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInsightCard(
            'Performance Atual',
            Icons.analytics,
            Colors.blue,
            'Baseado nos últimos 30 dias',
            [
              'Ganho médio diário: R\$ ${(performance['ganho_medio'] ?? 0).toStringAsFixed(2)}',
              'Corridas por dia: ${(performance['corridas_media'] ?? 0).toStringAsFixed(1)}',
              'Eficiência: ${(performance['eficiencia'] ?? 0).toStringAsFixed(1)}%',
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInsightCard(
            'Recomendações',
            Icons.lightbulb,
            Colors.orange,
            'Ações para melhorar seus resultados',
            [
              'Trabalhe mais entre 18h-20h (+40% ganhos)',
              'Foque na região Centro (+60% demanda)',
              'Use pontos estratégicos (-50% tempo espera)',
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInsightCard(
            'Previsões',
            Icons.trending_up,
            Colors.green,
            'Projeções baseadas em IA',
            [
              'Ganho estimado esta semana: R\$ ${(previsoes['ganho_semanal'] ?? 0).toStringAsFixed(2)}',
              'Melhor dia para trabalhar: ${previsoes['melhor_dia'] ?? 'Sábado'}',
              'Crescimento esperado: +${(previsoes['crescimento'] ?? 0).toStringAsFixed(1)}%',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String titulo, IconData icon, Color cor, String subtitulo, List<String> itens) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  color: cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: cor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          ...itens.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: cor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String titulo, String descricao, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            descricao,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _atualizarMetas() async {
    final service = Provider.of<MetasInteligentesService>(context, listen: false);
    await service.atualizarProgressoMetas();
  }

  void _mostrarInsights() {
    _tabController.animateTo(2);
  }

  void _criarMetaPersonalizada() {
    // Implementar criação de meta personalizada
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Meta'),
        content: const Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Métodos utilitários
  Color _getCorCategoria(CategoriaMeta categoria) {
    switch (categoria) {
      case CategoriaMeta.produtividade:
        return Colors.blue;
      case CategoriaMeta.crescimento:
        return Colors.green;
      case CategoriaMeta.habito:
        return Colors.purple;
      case CategoriaMeta.estrategia:
        return Colors.orange;
      case CategoriaMeta.social:
        return Colors.pink;
    }
  }

  IconData _getIconeTipoMeta(TipoMeta tipo) {
    switch (tipo) {
      case TipoMeta.ganhos:
        return Icons.attach_money;
      case TipoMeta.corridas:
        return Icons.directions_car;
      case TipoMeta.eficiencia:
        return Icons.speed;
      case TipoMeta.consistencia:
        return Icons.timeline;
      case TipoMeta.crescimento:
        return Icons.trending_up;
      case TipoMeta.estrategico:
        return Icons.psychology;
    }
  }

  String _formatarValor(double valor, TipoMeta tipo) {
    switch (tipo) {
      case TipoMeta.ganhos:
        return 'R\$ ${valor.toStringAsFixed(2)}';
      case TipoMeta.corridas:
        return '${valor.toInt()} corridas';
      case TipoMeta.eficiencia:
        return '${valor.toStringAsFixed(1)}/h';
      case TipoMeta.consistencia:
        return '${valor.toInt()} dias';
      case TipoMeta.crescimento:
        return 'R\$ ${valor.toStringAsFixed(2)}';
      case TipoMeta.estrategico:
        return '${(valor * 100).toInt()}%';
    }
  }

  String _formatarTempoRestante(MetaInteligente meta) {
    if (meta.expirada) return 'Expirada';
    if (meta.completada) return 'Concluída';
    
    final tempo = meta.tempoRestante;
    if (tempo.inDays > 0) {
      return '${tempo.inDays}d restantes';
    } else if (tempo.inHours > 0) {
      return '${tempo.inHours}h restantes';
    } else {
      return '${tempo.inMinutes}min restantes';
    }
  }

  String _formatarDificuldade(DificuldadeMeta dificuldade) {
    switch (dificuldade) {
      case DificuldadeMeta.facil:
        return 'Fácil';
      case DificuldadeMeta.media:
        return 'Médio';
      case DificuldadeMeta.dificil:
        return 'Difícil';
    }
  }

  Color _getCorDificuldade(DificuldadeMeta dificuldade) {
    switch (dificuldade) {
      case DificuldadeMeta.facil:
        return Colors.green;
      case DificuldadeMeta.media:
        return Colors.orange;
      case DificuldadeMeta.dificil:
        return Colors.red;
    }
  }
}
