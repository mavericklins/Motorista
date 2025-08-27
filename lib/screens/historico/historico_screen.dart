import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dados simulados de corridas
  final List<Map<String, dynamic>> corridas = [
    {
      'id': '001',
      'data': '22/01/2025',
      'hora': '14:30',
      'origem': 'Shopping Center Norte',
      'destino': 'Aeroporto Internacional',
      'distancia': '25.4 km',
      'tempo': '35 min',
      'valor': 45.80,
      'status': 'Concluída',
      'passageiro': 'Maria Silva',
      'avaliacao': 5.0,
      'formaPagamento': 'Cartão',
    },
    {
      'id': '002',
      'data': '22/01/2025',
      'hora': '10:15',
      'origem': 'Rua das Flores, 123',
      'destino': 'Centro Empresarial',
      'distancia': '8.2 km',
      'tempo': '18 min',
      'valor': 18.50,
      'status': 'Concluída',
      'passageiro': 'João Santos',
      'avaliacao': 4.8,
      'formaPagamento': 'Dinheiro',
    },
    {
      'id': '003',
      'data': '21/01/2025',
      'hora': '20:45',
      'origem': 'Restaurante Bella Vista',
      'destino': 'Residencial Jardim',
      'distancia': '12.1 km',
      'tempo': '22 min',
      'valor': 28.90,
      'status': 'Concluída',
      'passageiro': 'Ana Costa',
      'avaliacao': 5.0,
      'formaPagamento': 'PIX',
    },
    {
      'id': '004',
      'data': '21/01/2025',
      'hora': '16:20',
      'origem': 'Hospital São Lucas',
      'destino': 'Farmácia Central',
      'distancia': '3.5 km',
      'tempo': '12 min',
      'valor': 12.00,
      'status': 'Cancelada',
      'passageiro': 'Carlos Oliveira',
      'avaliacao': 0.0,
      'formaPagamento': 'Cartão',
    },
    {
      'id': '005',
      'data': '20/01/2025',
      'hora': '08:30',
      'origem': 'Estação de Metrô',
      'destino': 'Universidade Federal',
      'distancia': '15.8 km',
      'tempo': '28 min',
      'valor': 32.40,
      'status': 'Concluída',
      'passageiro': 'Beatriz Lima',
      'avaliacao': 4.9,
      'formaPagamento': 'Cartão',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Histórico de Corridas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _abrirFiltros,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtros',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Esta Semana'),
            Tab(text: 'Todas'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Card de resumo
          _buildResumoCard(),
          
          // Lista de corridas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListaCorridas(_filtrarCorridasHoje()),
                _buildListaCorridas(_filtrarCorridasSemana()),
                _buildListaCorridas(corridas),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoCard() {
    double totalHoje = _filtrarCorridasHoje()
        .where((c) => c['status'] == 'Concluída')
        .fold(0.0, (sum, c) => sum + c['valor']);
    
    int corridasHoje = _filtrarCorridasHoje()
        .where((c) => c['status'] == 'Concluída')
        .length;

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumo de Hoje',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${totalHoje.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$corridasHoje corridas realizadas',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: velloOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_up,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaCorridas(List<Map<String, dynamic>> corridasFiltradas) {
    if (corridasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma corrida encontrada',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas corridas aparecerão aqui',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: corridasFiltradas.length,
      itemBuilder: (context, index) {
        final corrida = corridasFiltradas[index];
        return _buildCorridaCard(corrida);
      },
    );
  }

  Widget _buildCorridaCard(Map<String, dynamic> corrida) {
    Color statusColor;
    IconData statusIcon;
    
    switch (corrida['status']) {
      case 'Concluída':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle;
        break;
      case 'Cancelada':
        statusColor = Colors.red.shade600;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange.shade600;
        statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: velloCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _mostrarDetalhes(corrida),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Cabeçalho da corrida
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          statusIcon,
                          color: statusColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${corrida['data']} - ${corrida['hora']}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: velloBlue,
                            ),
                          ),
                          Text(
                            corrida['status'],
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    'R\$ ${corrida['valor'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: velloOrange,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Rota da corrida
              Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 30,
                        color: Colors.grey.shade300,
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          corrida['origem'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: velloBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          corrida['destino'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: velloBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Informações adicionais
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(Icons.straighten, corrida['distancia']),
                  _buildInfoChip(Icons.schedule, corrida['tempo']),
                  if (corrida['avaliacao'] > 0)
                    _buildInfoChip(Icons.star, corrida['avaliacao'].toString()),
                  _buildInfoChip(Icons.payment, corrida['formaPagamento']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: velloLightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filtrarCorridasHoje() {
    final hoje = DateTime.now();
    return corridas.where((corrida) {
      // Simulação: considerando que todas as corridas de hoje têm data '22/01/2025'
      return corrida['data'] == '22/01/2025';
    }).toList();
  }

  List<Map<String, dynamic>> _filtrarCorridasSemana() {
    // Simulação: considerando corridas dos últimos 7 dias
    return corridas.where((corrida) {
      final dataCorrida = corrida['data'];
      return ['22/01/2025', '21/01/2025', '20/01/2025'].contains(dataCorrida);
    }).toList();
  }

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrar Corridas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: velloBlue,
                ),
              ),
              const SizedBox(height: 20),
              _buildFiltroOption('Todos', Icons.list),
              _buildFiltroOption('Concluídas', Icons.check_circle),
              _buildFiltroOption('Canceladas', Icons.cancel),
              _buildFiltroOption('Maior Valor', Icons.trending_up),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltroOption(String titulo, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: velloOrange),
      title: Text(titulo),
      onTap: () {
        setState(() {
          filtroSelecionado = titulo;
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Filtro aplicado: $titulo')),
        );
      },
    );
  }

  void _mostrarDetalhes(Map<String, dynamic> corrida) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Corrida #${corrida['id']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetalheItem('Passageiro', corrida['passageiro']),
                _buildDetalheItem('Data/Hora', '${corrida['data']} às ${corrida['hora']}'),
                _buildDetalheItem('Origem', corrida['origem']),
                _buildDetalheItem('Destino', corrida['destino']),
                _buildDetalheItem('Distância', corrida['distancia']),
                _buildDetalheItem('Tempo', corrida['tempo']),
                _buildDetalheItem('Valor', 'R\$ ${corrida['valor'].toStringAsFixed(2)}'),
                _buildDetalheItem('Pagamento', corrida['formaPagamento']),
                _buildDetalheItem('Status', corrida['status']),
                if (corrida['avaliacao'] > 0)
                  _buildDetalheItem('Avaliação', '${corrida['avaliacao']} ⭐'),
              ],
            ),
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

  Widget _buildDetalheItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: velloBlue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class HistoricoScreen extends StatelessWidget {
  const HistoricoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Histórico de Corridas',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: VelloColors.laranja,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: VelloColors.laranja,
            ),
            SizedBox(height: 16),
            Text(
              'Histórico de Corridas',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: VelloColors.azul,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Suas corridas aparecerão aqui',
              style: TextStyle(
                fontSize: 16,
                color: VelloColors.cinza,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
