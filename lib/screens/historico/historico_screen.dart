import 'package:flutter/material.dart';
import '../../services/firebase_corridas_service.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';

// Define DriverStatus enum if it's indeed intended and not provided
// For the purpose of generating runnable code based on the prompt's intent,
// we will assume a simple String can be passed if DriverStatus is not available.
// If StatusChip truly requires a specific DriverStatus enum, this part would need clarification.
// For now, we adapt the change to use the existing status string.

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> with TickerProviderStateMixin {
  // Cores da identidade visual Vello
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

  late TabController _tabController;
  String filtroSelecionado = 'Todos';

  // Dummy data and loading state (replace with actual data fetching)
  bool _isLoading = false;
  List<dynamic> _corridas = []; // Replace with your actual corrida model

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize with dummy data for demonstration
    _corridas = [
      _Corrida(
        id: '001',
        dataHora: DateTime(2025, 1, 22, 14, 30),
        origem: 'Shopping Center Norte',
        destino: 'Aeroporto Internacional',
        distancia: 25.4,
        valor: 45.80,
        status: 'concluida',
        passageiro: 'Maria Silva',
        formaPagamento: 'Cartão',
      ),
      _Corrida(
        id: '002',
        dataHora: DateTime(2025, 1, 22, 10, 15),
        origem: 'Rua das Flores, 123',
        destino: 'Centro Empresarial',
        distancia: 8.2,
        valor: 18.50,
        status: 'cancelada',
        passageiro: 'João Santos',
        formaPagamento: 'Dinheiro',
      ),
      _Corrida(
        id: '003',
        dataHora: DateTime(2025, 1, 21, 20, 45),
        origem: 'Restaurante Bella Vista',
        destino: 'Residencial Jardim',
        distancia: 12.1,
        valor: 28.90,
        status: 'em_andamento',
        passageiro: 'Ana Costa',
        formaPagamento: 'PIX',
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            onPressed: _showFilterOptions,
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelloTokens.brand,
              ),
            )
          : _corridas.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildSummaryHeader(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _corridas.length,
                        itemBuilder: (context, index) {
                          final corrida = _corridas[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCorridaCard(corrida),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
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
            'Suas corridas aparecerão aqui após serem concluídas',
            style: TextStyle(
              fontSize: 14,
              color: VelloTokens.gray500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final totalCorridas = _corridas.length;
    final totalGanhos = _corridas.fold(0.0, (sum, corrida) => sum + corrida.valor);
    final corridasCompletas = _corridas.where((c) => c.status == 'concluida').length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: VelloCard(
        borderRadius: VelloTokens.radiusLarge,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total de Corridas',
                  totalCorridas.toString(),
                  Icons.local_taxi,
                  VelloTokens.brand,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: VelloTokens.gray300,
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Ganhos Totais',
                  'R\$ ${totalGanhos.toStringAsFixed(2)}',
                  Icons.attach_money,
                  VelloTokens.success,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: VelloTokens.gray300,
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Concluídas',
                  corridasCompletas.toString(),
                  Icons.check_circle,
                  VelloTokens.warning,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: VelloTokens.gray700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: VelloTokens.gray500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCorridaCard(dynamic corrida) {
    final statusColor = _getStatusColor(corrida.status);
    final statusType = _getStatusChipType(corrida.status);

    return VelloCard(
      borderRadius: VelloTokens.radiusXLarge,
      onTap: () => _showRideDetails(corrida),
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
                    Icons.location_on,
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
                              corrida.destino,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: VelloTokens.gray700,
                              ),
                            ),
                          ),
                          StatusChip(
                            label: corrida.status, // Original label
                            type: statusType,
                            size: StatusChipSize.small,
                            status: corrida.status, // Added as per intention and adapted value
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'De: ${corrida.origem}',
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
            const SizedBox(height: 16),

            // Info row
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
                    child: _buildInfoItem(
                      'Data',
                      '${corrida.dataHora.day}/${corrida.dataHora.month}/${corrida.dataHora.year}',
                      Icons.calendar_today,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Distância',
                      '${corrida.distancia.toStringAsFixed(1)}km',
                      Icons.route,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Valor',
                      'R\$ ${corrida.valor.toStringAsFixed(2)}',
                      Icons.attach_money,
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: VelloTokens.gray600,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: VelloTokens.gray700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: VelloTokens.gray500,
          ),
        ),
      ],
    );
  }

  StatusChipType _getStatusChipType(String status) {
    switch (status.toLowerCase()) {
      case 'concluida':
        return StatusChipType.success;
      case 'cancelada':
        return StatusChipType.error;
      case 'em_andamento':
        return StatusChipType.warning;
      default:
        return StatusChipType.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'concluida':
        return VelloTokens.success;
      case 'cancelada':
        return VelloTokens.error;
      case 'em_andamento':
        return VelloTokens.warning;
      default:
        return VelloTokens.info;
    }
  }

  void _showFilterOptions() {
    // TODO: Implementar filtros
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Filtros serão implementados em breve'),
        backgroundColor: VelloTokens.info,
      ),
    );
  }

  void _showRideDetails(dynamic corrida) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalhes da Corrida #${corrida.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passageiro: ${corrida.passageiro}'),
              Text('Origem: ${corrida.origem}'),
              Text('Destino: ${corrida.destino}'),
              Text('Valor: R\$ ${corrida.valor.toStringAsFixed(2)}'),
              Text('Distância: ${corrida.distancia.toStringAsFixed(1)} km'),
              Text('Data/Hora: ${corrida.dataHora.toLocal()}'),
              Text('Forma de Pagamento: ${corrida.formaPagamento}'),
              Text('Status: ${corrida.status}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

// Dummy _Corrida class for demonstration purposes
class _Corrida {
  final String id;
  final DateTime dataHora;
  final String origem;
  final String destino;
  final double distancia;
  final double valor;
  final String status;
  final String passageiro;
  final String formaPagamento;

  _Corrida({
    required this.id,
    required this.dataHora,
    required this.origem,
    required this.destino,
    required this.distancia,
    required this.valor,
    required this.status,
    required this.passageiro,
    required this.formaPagamento,
  });
}