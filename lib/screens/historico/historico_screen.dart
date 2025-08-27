
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
          _buildResumoCard(),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    'R\$ ${corrida['valor'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: velloOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${corrida['origem']} → ${corrida['destino']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  List<Map<String, dynamic>> _filtrarCorridasHoje() {
    return corridas.where((corrida) => corrida['data'] == '22/01/2025').toList();
  }

  List<Map<String, dynamic>> _filtrarCorridasSemana() {
    return corridas.where((corrida) {
      final dataCorrida = corrida['data'];
      return ['22/01/2025', '21/01/2025'].contains(dataCorrida);
    }).toList();
  }

  void _abrirFiltros() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtros em desenvolvimento')),
    );
  }

  void _mostrarDetalhes(Map<String, dynamic> corrida) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Corrida #${corrida['id']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passageiro: ${corrida['passageiro']}'),
              Text('Origem: ${corrida['origem']}'),
              Text('Destino: ${corrida['destino']}'),
              Text('Valor: R\$ ${corrida['valor'].toStringAsFixed(2)}'),
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
