import 'package:flutter/material.dart';
import '../../services/demand_prediction_service.dart';
import '../../core/feature_flags.dart';

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
      appBar: AppBar(title: const Text('Previsão de Demanda')),
      body: !FeatureFlags.enableDemandPrediction
          ? const Center(
              child: Text(
                'Funcionalidade não disponível',
                style: TextStyle(fontSize: 16),
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _predictionData == null
                  ? const Center(child: Text('Nenhuma previsão disponível'))
                  : _buildPredictionContent(),
      floatingActionButton: FeatureFlags.enableDemandPrediction
          ? FloatingActionButton(
              onPressed: _loadPredictions,
              child: const Icon(Icons.refresh),
            )
          : null,
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
}