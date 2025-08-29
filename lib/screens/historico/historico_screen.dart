
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_corridas_service.dart';
import '../../models/ride.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseCorridasService _corridasService = FirebaseCorridasService();
  
  bool _isLoading = false;
  List<Ride> _todasCorridas = [];
  List<Ride> _corridasCompletas = [];
  List<Ride> _corridasCanceladas = [];
  String _filtroSelecionado = 'todas';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadHistorico();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistorico() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _todasCorridas = [
          Ride(
            id: '1',
            passengerId: 'p1',
            driverId: 'd1',
            origin: 'Centro, São Paulo',
            destination: 'Shopping Ibirapuera',
            status: RideStatus.completed,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            price: 25.50,
            distance: 8.5,
            duration: Duration(minutes: 25),
            rating: 4.8,
            paymentMethod: 'PIX',
          ),
          Ride(
            id: '2',
            passengerId: 'p2',
            driverId: 'd1',
            origin: 'Aeroporto Congonhas',
            destination: 'Av. Paulista, 1000',
            status: RideStatus.completed,
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
            price: 42.75,
            distance: 15.2,
            duration: Duration(minutes: 35),
            rating: 5.0,
            paymentMethod: 'Cartão',
          ),
          Ride(
            id: '3',
            passengerId: 'p3',
            driverId: 'd1',
            origin: 'Vila Madalena',
            destination: 'Itaim Bibi',
            status: RideStatus.cancelled,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            price: 18.30,
            distance: 6.8,
            duration: Duration(minutes: 20),
            cancelReason: 'Passageiro cancelou',
          ),
          Ride(
            id: '4',
            passengerId: 'p4',
            driverId: 'd1',
            origin: 'Moema',
            destination: 'Brooklin',
            status: RideStatus.completed,
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            price: 15.80,
            distance: 4.2,
            duration: Duration(minutes: 18),
            rating: 4.5,
            paymentMethod: 'Dinheiro',
          ),
        ];
        
        _corridasCompletas = _todasCorridas.where((r) => r.status == RideStatus.completed).toList();
        _corridasCanceladas = _todasCorridas.where((r) => r.status == RideStatus.cancelled).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar histórico: $e'),
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
          'Histórico de Corridas',
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
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistorico,
            tooltip: 'Atualizar',
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
                      _buildCorridasList(_todasCorridas),
                      _buildCorridasList(_corridasCompletas),
                      _buildCorridasList(_corridasCanceladas),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader() {
    final totalCorridas = _todasCorridas.length;
    final totalGanhos = _corridasCompletas.fold<double>(0, (sum, r) => sum + (r.price ?? 0));
    final mediaAvaliacao = _corridasCompletas.where((r) => r.rating != null)
        .fold<double>(0, (sum, r) => sum + (r.rating ?? 0)) / 
        _corridasCompletas.where((r) => r.rating != null).length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: VelloCard.gradient(
        gradient: const LinearGradient(
          colors: [VelloTokens.info, Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Resumo Geral',
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
                      'Total de Corridas',
                      totalCorridas.toString(),
                      Icons.local_taxi,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Ganhos Totais',
                      'R\$ ${totalGanhos.toStringAsFixed(2).replaceAll('.', ',')}',
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryMetric(
                      'Avaliação Média',
                      mediaAvaliacao.isNaN ? 'N/A' : '${mediaAvaliacao.toStringAsFixed(1)} ⭐',
                      Icons.star,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Taxa Conclusão',
                      '${((_corridasCompletas.length / _todasCorridas.length) * 100).toStringAsFixed(1)}%',
                      Icons.check_circle,
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

  Widget _buildSummaryMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: VelloTokens.radiusMedium,
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
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
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
            Tab(text: 'Todas (${_todasCorridas.length})'),
            Tab(text: 'Completas (${_corridasCompletas.length})'),
            Tab(text: 'Canceladas (${_corridasCanceladas.length})'),
          ],
        ),
      ),
    );
  }

  Widget _buildCorridasList(List<Ride> corridas) {
    if (corridas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: VelloTokens.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma corrida encontrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas corridas aparecerão aqui',
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
      itemCount: corridas.length,
      itemBuilder: (context, index) {
        final corrida = corridas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCorridaCard(corrida),
        );
      },
    );
  }

  Widget _buildCorridaCard(Ride corrida) {
    final isCompleted = corrida.status == RideStatus.completed;
    final statusColor = isCompleted ? VelloTokens.success : VelloTokens.danger;

    return VelloCard(
      borderRadius: VelloTokens.radiusXLarge,
      onTap: () => _showCorridaDetails(corrida),
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: VelloTokens.radiusMedium,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.cancel,
                    color: statusColor,
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
                              _formatDateTime(corrida.createdAt),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: VelloTokens.gray700,
                              ),
                            ),
                          ),
                          StatusChip(
                            label: isCompleted ? 'Concluída' : 'Cancelada',
                            type: isCompleted ? StatusChipType.success : StatusChipType.error,
                            size: StatusChipSize.small,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (isCompleted && corrida.rating != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: VelloTokens.warning,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              corrida.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 12,
                                color: VelloTokens.gray500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Rota
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: VelloTokens.success,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          corrida.origin,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: VelloTokens.gray700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 1,
                    height: 20,
                    color: VelloTokens.gray300,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: VelloTokens.danger,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          corrida.destination,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: VelloTokens.gray700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Informações da corrida
            Row(
              children: [
                Expanded(
                  child: _buildCorridaInfo(
                    'Valor',
                    corrida.price != null 
                        ? 'R\$ ${corrida.price!.toStringAsFixed(2).replaceAll('.', ',')}'
                        : 'N/A',
                    Icons.attach_money,
                    VelloTokens.success,
                  ),
                ),
                Expanded(
                  child: _buildCorridaInfo(
                    'Distância',
                    corrida.distance != null 
                        ? '${corrida.distance!.toStringAsFixed(1)} km'
                        : 'N/A',
                    Icons.route,
                    VelloTokens.info,
                  ),
                ),
                Expanded(
                  child: _buildCorridaInfo(
                    'Duração',
                    corrida.duration != null 
                        ? '${corrida.duration!.inMinutes}min'
                        : 'N/A',
                    Icons.schedule,
                    VelloTokens.warning,
                  ),
                ),
              ],
            ),
            
            if (!isCompleted && corrida.cancelReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: VelloTokens.danger.withOpacity(0.1),
                  borderRadius: VelloTokens.radiusMedium,
                  border: Border.all(
                    color: VelloTokens.danger.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: VelloTokens.danger,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Motivo: ${corrida.cancelReason}',
                        style: TextStyle(
                          fontSize: 12,
                          color: VelloTokens.danger,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCorridaInfo(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: VelloTokens.radiusMedium,
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: VelloTokens.gray700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: VelloTokens.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}min atrás';
      }
      return '${difference.inHours}h atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem às ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    }
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filtros avançados de histórico serão implementados em breve.'),
            const SizedBox(height: 16),
            const Text('Por enquanto, use as abas para filtrar por status.'),
          ],
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

  void _showCorridaDetails(Ride corrida) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: Text('Corrida ${corrida.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Origem: ${corrida.origin}'),
              const SizedBox(height: 8),
              Text('Destino: ${corrida.destination}'),
              const SizedBox(height: 8),
              Text('Status: ${corrida.status == RideStatus.completed ? 'Concluída' : 'Cancelada'}'),
              if (corrida.price != null) ...[
                const SizedBox(height: 8),
                Text('Valor: R\$ ${corrida.price!.toStringAsFixed(2).replaceAll('.', ',')}'),
              ],
              if (corrida.distance != null) ...[
                const SizedBox(height: 8),
                Text('Distância: ${corrida.distance!.toStringAsFixed(1)} km'),
              ],
              if (corrida.duration != null) ...[
                const SizedBox(height: 8),
                Text('Duração: ${corrida.duration!.inMinutes} minutos'),
              ],
              if (corrida.rating != null) ...[
                const SizedBox(height: 8),
                Text('Avaliação: ${corrida.rating!.toStringAsFixed(1)} ⭐'),
              ],
              if (corrida.paymentMethod != null) ...[
                const SizedBox(height: 8),
                Text('Pagamento: ${corrida.paymentMethod}'),
              ],
              if (corrida.cancelReason != null) ...[
                const SizedBox(height: 8),
                Text('Motivo do cancelamento: ${corrida.cancelReason}'),
              ],
            ],
          ),
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
