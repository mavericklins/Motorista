
import 'package:flutter/material.dart';
import '../../models/scheduled_ride.dart';
import '../../services/scheduled_rides_service.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';

class CorridasProgramadasScreen extends StatefulWidget {
  const CorridasProgramadasScreen({super.key});

  @override
  State<CorridasProgramadasScreen> createState() => _CorridasProgramadasScreenState();
}

class _CorridasProgramadasScreenState extends State<CorridasProgramadasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScheduledRidesService _scheduledRidesService = ScheduledRidesService();
  
  List<ScheduledRide> _corridasProgramadas = [];
  List<ScheduledRide> _corridasDisponveis = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCorridas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCorridas() async {
    setState(() => _isLoading = true);

    try {
      // Simular dados
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _corridasProgramadas = [
          ScheduledRide(
            id: '1',
            passengerName: 'Maria Silva',
            pickupAddress: 'Rua das Flores, 123 - Centro',
            destinationAddress: 'Shopping Center Norte',
            scheduledTime: DateTime.now().add(const Duration(hours: 2)),
            estimatedPrice: 25.50,
            distance: 8.2,
            estimatedDuration: 18,
            status: ScheduledRideStatus.confirmed,
            notes: 'Passageira preferencial',
          ),
          ScheduledRide(
            id: '2',
            passengerName: 'João Santos',
            pickupAddress: 'Av. Paulista, 1000',
            destinationAddress: 'Aeroporto de Congonhas',
            scheduledTime: DateTime.now().add(const Duration(hours: 4)),
            estimatedPrice: 45.80,
            distance: 15.7,
            estimatedDuration: 35,
            status: ScheduledRideStatus.pending,
            notes: 'Viagem ao aeroporto',
          ),
        ];

        _corridasDisponveis = [
          ScheduledRide(
            id: '3',
            passengerName: 'Ana Costa',
            pickupAddress: 'Terminal Rodoviário',
            destinationAddress: 'Bairro Jardins',
            scheduledTime: DateTime.now().add(const Duration(hours: 1)),
            estimatedPrice: 18.90,
            distance: 6.5,
            estimatedDuration: 15,
            status: ScheduledRideStatus.available,
            notes: 'Corrida recorrente',
          ),
          ScheduledRide(
            id: '4',
            passengerName: 'Carlos Oliveira',
            pickupAddress: 'Hospital Santa Casa',
            destinationAddress: 'Centro Comercial',
            scheduledTime: DateTime.now().add(const Duration(hours: 3)),
            estimatedPrice: 32.40,
            distance: 11.3,
            estimatedDuration: 25,
            status: ScheduledRideStatus.available,
            notes: 'Paciente em consulta',
          ),
        ];

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar corridas: $e'),
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
          'Corridas',
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
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showDatePicker(),
            tooltip: 'Filtrar por data',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCorridas,
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
                _buildDateFilter(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProgramadasTab(),
                      _buildInsightsTab(),
                      _buildAnalyticsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryHeader() {
    final totalProgramadas = _corridasProgramadas.length;
    final corridasHoje = _corridasProgramadas.where((corrida) {
      final hoje = DateTime.now();
      final agendamento = corrida.scheduledTime;
      return agendamento.year == hoje.year &&
             agendamento.month == hoje.month &&
             agendamento.day == hoje.day;
    }).length;

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
                  const Icon(
                    Icons.schedule,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Corridas Programadas',
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
                      'Hoje',
                      corridasHoje.toString(),
                      Icons.today,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Total',
                      totalProgramadas.toString(),
                      Icons.event_note,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryMetric(
                      'Disponíveis',
                      _corridasDisponveis.length.toString(),
                      Icons.add_circle_outline,
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
      margin: const EdgeInsets.symmetric(horizontal: 4),
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
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
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
          tabs: const [
            Tab(text: 'Programadas'),
            Tab(text: 'Insights'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: VelloButton.icon(
              onPressed: () => _showDatePicker(),
              icon: Icons.calendar_today,
              text: _formatSelectedDate(),
              type: VelloButtonType.secondary,
            ),
          ),
          const SizedBox(width: 12),
          VelloButton.icon(
            onPressed: () => _showFilterOptions(),
            icon: Icons.filter_list,
            text: 'Filtros',
            type: VelloButtonType.ghost,
          ),
        ],
      ),
    );
  }

  Widget _buildProgramadasTab() {
    if (_corridasProgramadas.isEmpty) {
      return _buildEmptyState(
        icon: Icons.schedule,
        title: 'Nenhuma corrida programada',
        subtitle: 'Aceite corridas programadas ou crie uma nova programação',
        actionText: 'Criar Programação',
        onAction: () => _showCreateScheduleDialog(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _corridasProgramadas.length,
      itemBuilder: (context, index) {
        final corrida = _corridasProgramadas[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCorridaCard(corrida),
        );
      },
    );
  }

  Widget _buildInsightsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInsightCard(
            'Melhor Horário',
            'Entre 07:00 e 09:00',
            'Maior demanda por corridas programadas',
            Icons.access_time,
            VelloTokens.success,
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Rotas Populares',
            'Centro ↔ Aeroporto',
            '65% das corridas programadas',
            Icons.trending_up,
            VelloTokens.info,
          ),
          const SizedBox(height: 16),
          _buildInsightCard(
            'Dias da Semana',
            'Segunda e Sexta',
            'Picos de agendamentos',
            Icons.calendar_view_week,
            VelloTokens.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAnalyticsCard(),
          const SizedBox(height: 16),
          _buildEarningsProjection(),
          const SizedBox(height: 16),
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: VelloTokens.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: VelloTokens.gray500,
              ),
            ),
            const SizedBox(height: 24),
            VelloButton(
              text: actionText,
              onPressed: onAction,
              type: VelloButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorridaCard(ScheduledRide corrida) {
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
                    color: _getStatusColor(corrida.status).withOpacity(0.1),
                    borderRadius: VelloTokens.radiusMedium,
                  ),
                  child: Icon(
                    Icons.person,
                    color: _getStatusColor(corrida.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        corrida.passengerName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: VelloTokens.gray800,
                        ),
                      ),
                      Text(
                        _formatScheduledTime(corrida.scheduledTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: VelloTokens.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  text: _getStatusText(corrida.status),
                  type: _getStatusChipType(corrida.status),
                  size: StatusChipSize.small,
                  status: DriverStatus.online,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLocationInfo(corrida),
            const SizedBox(height: 16),
            _buildRideDetails(corrida),
            if (corrida.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildNotesSection(corrida.notes),
            ],
            const SizedBox(height: 16),
            _buildActionButtons(corrida),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo(ScheduledRide corrida) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VelloTokens.gray50,
        borderRadius: VelloTokens.radiusMedium,
        border: Border.all(color: VelloTokens.gray200),
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
                  corrida.pickupAddress,
                  style: const TextStyle(
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
                  corrida.destinationAddress,
                  style: const TextStyle(
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
    );
  }

  Widget _buildRideDetails(ScheduledRide corrida) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem(
            'Preço Estimado',
            'R\$ ${corrida.estimatedPrice.toStringAsFixed(2).replaceAll('.', ',')}',
            Icons.attach_money,
            VelloTokens.success,
          ),
        ),
        Expanded(
          child: _buildDetailItem(
            'Distância',
            '${corrida.distance.toStringAsFixed(1)} km',
            Icons.straighten,
            VelloTokens.info,
          ),
        ),
        Expanded(
          child: _buildDetailItem(
            'Tempo',
            '${corrida.estimatedDuration} min',
            Icons.access_time,
            VelloTokens.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: VelloTokens.radiusSmall,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: VelloTokens.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String notes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: VelloTokens.info.withOpacity(0.1),
        borderRadius: VelloTokens.radiusMedium,
        border: Border.all(color: VelloTokens.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: VelloTokens.info,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              notes,
              style: TextStyle(
                fontSize: 12,
                color: VelloTokens.info,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ScheduledRide corrida) {
    if (corrida.status == ScheduledRideStatus.available) {
      return VelloButton(
        text: 'Aceitar Corrida',
        onPressed: () => _acceptRide(corrida),
        type: VelloButtonType.primary,
        isFullWidth: true,
      );
    }

    return Row(
      children: [
        Expanded(
          child: VelloButton(
            text: 'Detalhes',
            onPressed: () => _showRideDetails(corrida),
            type: VelloButtonType.secondary,
          ),
        ),
        const SizedBox(width: 12),
        if (corrida.status == ScheduledRideStatus.confirmed) ...[
          Expanded(
            child: VelloButton(
              text: 'Cancelar',
              onPressed: () => _cancelRide(corrida),
              type: VelloButtonType.ghost,
            ),
          ),
        ] else ...[
          Expanded(
            child: VelloButton(
              text: 'Navegação',
              onPressed: () => _startNavigation(corrida),
              type: VelloButtonType.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, String description, IconData icon, Color color) {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: VelloTokens.radiusMedium,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: VelloTokens.gray600,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: VelloTokens.gray500,
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

  Widget _buildAnalyticsCard() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estatísticas Semanais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('Aceitas', '8', VelloTokens.success),
                ),
                Expanded(
                  child: _buildStatItem('Pendentes', '3', VelloTokens.warning),
                ),
                Expanded(
                  child: _buildStatItem('Canceladas', '1', VelloTokens.danger),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: VelloTokens.radiusSmall,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: VelloTokens.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsProjection() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Projeção de Ganhos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Esta Semana',
                  style: TextStyle(
                    fontSize: 14,
                    color: VelloTokens.gray600,
                  ),
                ),
                Text(
                  'R\$ 245,80',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: VelloTokens.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: VelloTokens.radiusSmall,
              child: LinearProgressIndicator(
                value: 0.75,
                backgroundColor: VelloTokens.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(VelloTokens.success),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Baseado nas corridas programadas',
              style: TextStyle(
                fontSize: 12,
                color: VelloTokens.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow('Taxa de Aceitação', '88%', VelloTokens.success),
            const SizedBox(height: 12),
            _buildMetricRow('Pontualidade', '95%', VelloTokens.success),
            const SizedBox(height: 12),
            _buildMetricRow('Cancelamentos', '5%', VelloTokens.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: VelloTokens.gray700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ScheduledRideStatus status) {
    switch (status) {
      case ScheduledRideStatus.pending:
        return VelloTokens.warning;
      case ScheduledRideStatus.confirmed:
        return VelloTokens.success;
      case ScheduledRideStatus.cancelled:
        return VelloTokens.danger;
      case ScheduledRideStatus.completed:
        return VelloTokens.info;
      case ScheduledRideStatus.available:
        return VelloTokens.brand;
      case ScheduledRideStatus.accepted:
        return VelloTokens.success;
      case ScheduledRideStatus.inProgress:
        return VelloTokens.info;
    }
  }

  String _getStatusText(ScheduledRideStatus status) {
    switch (status) {
      case ScheduledRideStatus.pending:
        return 'Pendente';
      case ScheduledRideStatus.confirmed:
        return 'Confirmada';
      case ScheduledRideStatus.cancelled:
        return 'Cancelada';
      case ScheduledRideStatus.completed:
        return 'Concluída';
      case ScheduledRideStatus.available:
        return 'Disponível';
      case ScheduledRideStatus.accepted:
        return 'Aceita';
      case ScheduledRideStatus.inProgress:
        return 'Em Andamento';
    }
  }

  StatusChipType _getStatusChipType(ScheduledRideStatus status) {
    switch (status) {
      case ScheduledRideStatus.pending:
        return StatusChipType.warning;
      case ScheduledRideStatus.confirmed:
        return StatusChipType.success;
      case ScheduledRideStatus.cancelled:
        return StatusChipType.error;
      case ScheduledRideStatus.completed:
        return StatusChipType.info;
      case ScheduledRideStatus.available:
        return StatusChipType.info;
      case ScheduledRideStatus.accepted:
        return StatusChipType.success;
      case ScheduledRideStatus.inProgress:
        return StatusChipType.info;
    }
  }

  String _formatSelectedDate() {
    final now = DateTime.now();
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      return 'Hoje';
    }
    return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  String _formatScheduledTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$hour:$minute - $day/$month';
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: VelloTokens.brand,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadCorridas();
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Funcionalidade de filtros será implementada em breve.'),
            const SizedBox(height: 20),
            VelloButton(
              text: 'Entendi',
              onPressed: () => Navigator.pop(context),
              type: VelloButtonType.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateScheduleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Nova Programação'),
        content: const Text(
          'Funcionalidade de criação de programação personalizada será implementada em breve.',
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

  void _acceptRide(ScheduledRide corrida) {
    setState(() {
      corrida.status = ScheduledRideStatus.confirmed;
      _corridasDisponveis.remove(corrida);
      _corridasProgramadas.add(corrida);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Corrida de ${corrida.passengerName} aceita!'),
        backgroundColor: VelloTokens.success,
      ),
    );
  }

  void _cancelRide(ScheduledRide corrida) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Cancelar Corrida'),
        content: Text('Deseja cancelar a corrida de ${corrida.passengerName}?'),
        actions: [
          VelloButton(
            text: 'Não',
            onPressed: () => Navigator.pop(context),
            type: VelloButtonType.ghost,
          ),
          VelloButton(
            text: 'Sim, Cancelar',
            onPressed: () {
              setState(() {
                corrida.status = ScheduledRideStatus.cancelled;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Corrida cancelada'),
                  backgroundColor: VelloTokens.warning,
                ),
              );
            },
            type: VelloButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showRideDetails(ScheduledRide corrida) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes da Corrida',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Text('Passageiro: ${corrida.passengerName}'),
            const SizedBox(height: 8),
            Text('Origem: ${corrida.pickupAddress}'),
            const SizedBox(height: 8),
            Text('Destino: ${corrida.destinationAddress}'),
            const SizedBox(height: 8),
            Text('Horário: ${_formatScheduledTime(corrida.scheduledTime)}'),
            const SizedBox(height: 8),
            Text('Valor: R\$ ${corrida.estimatedPrice.toStringAsFixed(2)}'),
            if (corrida.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Observações: ${corrida.notes}'),
            ],
            const SizedBox(height: 20),
            VelloButton(
              text: 'Fechar',
              onPressed: () => Navigator.pop(context),
              type: VelloButtonType.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  void _startNavigation(ScheduledRide corrida) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando navegação para ${corrida.pickupAddress}'),
        backgroundColor: VelloTokens.info,
      ),
    );
  }
}
