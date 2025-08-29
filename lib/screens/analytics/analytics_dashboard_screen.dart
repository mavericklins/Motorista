import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/analytics_service.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsAnalyticsDashboardScreenState>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'semana';
  bool _isLoading = true; // Assume loading initially
  var _analyticsData; // Placeholder for fetched analytics data

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics(); // Load data when the widget is initialized
  }

  // Placeholder for the actual data loading logic
  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });
    // Simulate fetching data
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _analyticsData = {
        'totalEarnings': 'R\$ 1.247,80',
        'totalEarningsChange': '+12%',
        'totalRides': '187',
        'totalRidesChange': '+8%',
        'rating': '4.8',
        'ratingChange': '+0.2',
        'earningsChartData': [
          FlSpot(0, 45), FlSpot(1, 78), FlSpot(2, 120), FlSpot(3, 89),
          FlSpot(4, 156), FlSpot(5, 198), FlSpot(6, 167),
        ],
        'hourlyRidesData': List.generate(24, (index) {
          final values = [2, 1, 0, 0, 1, 3, 8, 12, 15, 18, 16, 14,
                          13, 15, 17, 19, 22, 25, 20, 18, 15, 12, 8, 4];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index].toDouble(),
                color: VelloTokens.brand,
                width: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        'performance': [
          {'title': 'Tempo médio por corrida', 'value': '18 min', 'icon': Icons.access_time, 'color': Colors.blue},
          {'title': 'Taxa de cancelamento', 'value': '3.2%', 'icon': Icons.cancel, 'color': Colors.red},
          {'title': 'Distância média', 'value': '12.5 km', 'icon': Icons.route, 'color': Colors.green},
          {'title': 'Hora mais produtiva', 'value': '18:00 - 19:00', 'icon': Icons.trending_up, 'color': VelloTokens.brand},
        ],
        'scenarios': [
          {'title': 'E se eu trabalhasse +2h por dia?', 'daily': '+R\$ 45,60/dia', 'monthly': '+R\$ 1.368/mês', 'icon': Icons.schedule, 'color': Colors.blue},
          {'title': 'E se eu focasse apenas em horários de pico?', 'daily': '+35% ganho/hora', 'monthly': '+R\$ 892/mês', 'icon': Icons.trending_up, 'color': Colors.green},
          {'title': 'E se eu trabalhasse fins de semana?', 'daily': '+R\$ 280/fim de semana', 'monthly': '+R\$ 1.120/mês', 'icon': Icons.weekend, 'color': Color(0xFFFF6B35)},
          {'title': 'E se eu fizesse 30% menos cancelamentos?', 'daily': '+4.2 corridas/dia', 'monthly': '+R\$ 672/mês', 'icon': Icons.check_circle, 'color': Colors.purple},
        ],
      };
      _isLoading = false;
    });
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
          'Analytics Dashboard',
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
            onPressed: _loadAnalytics,
            tooltip: 'Atualizar dados',
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewCards(),
                  const SizedBox(height: 20),
                  _buildMetricsCards(),
                  const SizedBox(height: 20),
                  _buildInsightsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: VelloCard(
            padding: const EdgeInsets.all(16),
            child: _buildSummaryCard(
              'Total Ganhos',
              _analyticsData?['totalEarnings'] ?? 'R\$ ---',
              Icons.attach_money,
              VelloTokens.green500,
              _analyticsData?['totalEarningsChange'] ?? '+0%',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VelloCard(
            padding: const EdgeInsets.all(16),
            child: _buildSummaryCard(
              'Corridas',
              _analyticsData?['totalRides'] ?? '0',
              Icons.directions_car,
              const Color(0xFFFF6B35),
              _analyticsData?['totalRidesChange'] ?? '+0%',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VelloCard(
            padding: const EdgeInsets.all(16),
            child: _buildSummaryCard(
              'Avaliação',
              _analyticsData?['rating'] ?? '0.0',
              Icons.star,
              Colors.amber,
              _analyticsData?['ratingChange'] ?? '+0.0',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, String change) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const Spacer(),
            Text(
              change,
              style: TextStyle(
                color: change.startsWith('+') ? VelloTokens.green500 : VelloTokens.red500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: VelloTokens.gray900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: VelloTokens.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return VelloCard(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildPeriodButton('Semana', 'semana'),
          _buildPeriodButton('Mês', 'mes'),
          _buildPeriodButton('Ano', 'ano'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = period),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? VelloTokens.brand : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : VelloTokens.gray600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsChart() {
    return VelloCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ganhos ao Longo do Tempo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text('R\$ ${value.toInt()}', style: TextStyle(fontSize: 10, color: VelloTokens.gray600));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(days[value.toInt()], style: TextStyle(fontSize: 10, color: VelloTokens.gray600));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _analyticsData?['earningsChartData'] ?? [],
                    isCurved: true,
                    color: VelloTokens.brand,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: VelloTokens.brand.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyRidesChart() {
    return VelloCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Corridas por Horário',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}', style: TextStyle(fontSize: 10, color: VelloTokens.gray600));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text('${value.toInt()}h', style: TextStyle(fontSize: 10, color: VelloTokens.gray600));
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _analyticsData?['hourlyRidesData'] ?? [],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Column(
      children: [
        _buildPeriodSelector(),
        const SizedBox(height: 20),
        _buildEarningsChart(),
        const SizedBox(height: 20),
        _buildHourlyRidesChart(),
        const SizedBox(height: 20),
        _buildPerformanceAnalysis(),
        const SizedBox(height: 20),
        _buildScenarioSimulator(),
      ],
    );
  }

  Widget _buildPerformanceAnalysis() {
    return VelloCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Análise de Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_analyticsData?['performance'] as List<Map<String, dynamic>>? ?? []).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildPerformanceItem(
              item['title'],
              item['value'],
              item['icon'],
              item['color'],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(String title, String value, IconData icon, Color color) {
    return Row(
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
            style: TextStyle(fontSize: 14, color: VelloTokens.gray700),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: VelloTokens.gray900,
          ),
        ),
      ],
    );
  }

  Widget _buildScenarioSimulator() {
    return VelloCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulador de Cenários',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_analyticsData?['scenarios'] as List<Map<String, dynamic>>? ?? []).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildScenarioOption(
              item['title'],
              item['daily'],
              item['monthly'],
              item['icon'],
              item['color'],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildScenarioOption(String title, String dailyImpact, String monthlyImpact, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dailyImpact,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      monthlyImpact,
                      style: TextStyle(
                        fontSize: 11,
                        color: VelloTokens.gray600,
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