
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/gamification_service.dart';

class EcoScoreScreen extends StatefulWidget {
  const EcoScoreScreen({super.key});

  @override
  State<EcoScoreScreen> createState() => _EcoScoreScreenState();
}

class _EcoScoreScreenState extends State<EcoScoreScreen> {
  Map<String, dynamic> _ecoData = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarEcoScore();
  }

  Future<void> _carregarEcoScore() async {
    final gamificationService = Provider.of<GamificationService>(context, listen: false);
    final ecoData = await gamificationService.calcularEcoScore('motorista_id');
    
    setState(() {
      _ecoData = ecoData;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Eco Score'),
        backgroundColor: Colors.green[600],
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildEcoScoreCard(),
                  const SizedBox(height: 20),
                  _buildEcoMetrics(),
                  const SizedBox(height: 20),
                  _buildEcoTips(),
                  const SizedBox(height: 20),
                  _buildEcoRanking(),
                ],
              ),
            ),
    );
  }

  Widget _buildEcoScoreCard() {
    final score = _ecoData['ecoScore'] ?? 0;
    final nivel = _ecoData['nivel'] ?? 'Iniciante';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.eco,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nivel,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _ecoData['proximaMeta'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEcoMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas Ambientais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricItem(
            Icons.local_gas_station,
            'Eficiência Combustível',
            '${(_ecoData['eficienciaCombustivel'] ?? 0).toStringAsFixed(1)} km/L',
            Colors.blue,
          ),
          _buildMetricItem(
            Icons.co2,
            'CO₂ Emitido este Mês',
            '${(_ecoData['emissaoCO2'] ?? 0).toStringAsFixed(1)} kg',
            Colors.orange,
          ),
          _buildMetricItem(
            Icons.park,
            'Árvores para Compensar',
            '${_ecoData['arvoresCompensadas'] ?? 0} árvores',
            Colors.green,
          ),
          _buildMetricItem(
            Icons.trending_up,
            'Condução Eficiente',
            '${(_ecoData['porcentagemEficiente'] ?? 0).toStringAsFixed(1)}%',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoTips() {
    final dicas = (_ecoData['dicas'] as List?) ?? [];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dicas Eco',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...dicas.map((dica) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.eco,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dica,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEcoRanking() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seu Ranking Eco',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _ecoData['ranking'] ?? 'Top 50%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'dos motoristas mais eco-friendly',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
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
}
