import 'package:flutter/material.dart';
import '../../services/demand_prediction_service.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';

class DemandPredictionScreen extends StatefulWidget {
  const DemandPredictionScreen({super.key});

  @override
  State<DemandPredictionScreen> createState() => _DemandPredictionScreenState();
}

class _DemandPredictionScreenState extends State<DemandPredictionScreen> {
  final DemandPredictionService _service = DemandPredictionService();
  bool _isLoading = false;
  Map<String, dynamic>? _predictionData;

  @override
  void initState() {
    super.initState();
    if (FeatureFlags.enableDemandPrediction) {
      _loadPredictions();
    }
  }

  Future<void> _loadPredictions() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getPredictions();
      setState(() => _predictionData = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar previsões: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.gray50,
      appBar: AppBar(
        title: const Text(
          'Previsão de Demanda',
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
            onPressed: _loadPredictions,
            tooltip: 'Atualizar previsões',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelloTokens.brand,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCurrentPrediction(),
                  const SizedBox(height: 20),
                  _buildHourlyPredictions(),
                  const SizedBox(height: 20),
                  _buildRecommendations(),
                ],
              ),
            ),
    );
  }

  Widget _buildPredictionContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Previsões para hoje',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: const Text('Demanda Alta'),
                    subtitle: Text('Centro: ${_predictionData?['centro'] ?? 'N/A'}'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.trending_down),
                    title: const Text('Demanda Baixa'),
                    subtitle: Text('Periferia: ${_predictionData?['periferia'] ?? 'N/A'}'),
                  ),
                ),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Versão Mock'),
                    subtitle: Text('Dados simulados para desenvolvimento'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPrediction() {
    return VelloCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Previsão Atual',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: VelloTokens.gray900,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPredictionItem(
                icon: Icons.home,
                label: 'Centro',
                value: _predictionData?['centro']?.toString() ?? 'N/A',
                color: VelloTokens.brand,
              ),
              _buildPredictionItem(
                icon: Icons.apartment,
                label: 'Periferia',
                value: _predictionData?['periferia']?.toString() ?? 'N/A',
                color: VelloTokens.brand,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyPredictions() {
    return VelloCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Previsão por Hora',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: VelloTokens.gray900,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          // Placeholder for hourly predictions, assuming data structure
          // This part would be expanded based on actual API response
          const Text('Dados de previsão por hora em breve...'),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return VelloCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recomendações',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: VelloTokens.gray900,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          VelloButton(
            text: 'Ver Recomendações Detalhadas',
            onPressed: () {
              // TODO: Implement navigation to detailed recommendations
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Navegação para detalhes não implementada')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: VelloTokens.gray700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: VelloTokens.gray900,
          ),
        ),
      ],
    );
  }
}