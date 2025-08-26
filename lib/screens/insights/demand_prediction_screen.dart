import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/demand_prediction_service.dart';
import '../../constants/app_colors.dart';

class DemandPredictionScreen extends StatefulWidget {
  const DemandPredictionScreen({Key? key}) : super(key: key);

  @override
  State<DemandPredictionScreen> createState() => _DemandPredictionScreenState();
}

class _DemandPredictionScreenState extends State<DemandPredictionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DemandPredictionService>().loadPredictions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsão de Demanda'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DemandPredictionService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card de zona quente atual
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_fire_department,
                                 color: AppColors.accent),
                            const SizedBox(width: 8),
                            const Text(
                              'Zona Quente Atual',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (service.currentHotZone != null) ...[
                          Text(
                            service.currentHotZone!.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Demanda: ${service.currentHotZone!.demandLevel}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _getDemandColor(service.currentHotZone!.demandLevel),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estimativa: ${service.currentHotZone!.estimatedRides} corridas',
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                        ] else
                          const Text('Nenhuma zona quente identificada no momento'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de previsões
                const Text(
                  'Previsões por Horário',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: service.predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = service.predictions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getDemandColor(prediction.demandLevel),
                          child: Text(
                            prediction.hour.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(prediction.location),
                        subtitle: Text(
                          'Demanda: ${prediction.demandLevel} • ${prediction.estimatedRides} corridas',
                        ),
                        trailing: prediction.demandLevel == 'Alta'
                            ? const Icon(Icons.trending_up, color: AppColors.success)
                            : prediction.demandLevel == 'Baixa'
                                ? const Icon(Icons.trending_down, color: AppColors.error)
                                : const Icon(Icons.trending_flat, color: AppColors.warning),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Dicas
                Card(
                  color: AppColors.surfaceVariant,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: AppColors.accent),
                            const SizedBox(width: 8),
                            const Text(
                              'Dicas Inteligentes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...service.tips.map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                         size: 16, color: AppColors.success),
                              const SizedBox(width: 8),
                              Expanded(child: Text(tip)),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getDemandColor(String demandLevel) {
    switch (demandLevel) {
      case 'Alta':
        return AppColors.success;
      case 'Média':
        return AppColors.warning;
      case 'Baixa':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}