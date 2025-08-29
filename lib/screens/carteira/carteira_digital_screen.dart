import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/financial_service.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';

class CarteiraDigitalScreen extends StatefulWidget {
  const CarteiraDigitalScreen({super.key});

  @override
  State<CarteiraDigitalScreen> createState() => _CarteiraDigitalScreenState();
}

class _CarteiraDigitalScreenState extends State<CarteiraDigitalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FinancialService _financialService = FinancialService();

  double _saldoAtual = 1247.50;
  double _ganhosDia = 89.40;
  double _ganhosOntem = 125.60;
  double _ganhosSemana = 623.80;
  double _ganhosMes = 2749.20;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFinancialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFinancialData() async {
    setState(() => _isLoading = true);

    try {
      // Simular carregamento de dados
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados financeiros: $e'),
            backgroundColor: VelloTokens.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: VelloTokens.gray50,
      appBar: AppBar(
        title: const Text(
          'Carteira Digital',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: VelloTokens.brand,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFinancialData,
            tooltip: 'Atualizar dados',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/historico'),
            tooltip: 'Histórico completo',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelloTokens.brand,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadFinancialData,
              color: VelloTokens.brand,
              child: CustomScrollView(
                slivers: [
                  // Header com saldo principal
                  SliverToBoxAdapter(
                    child: _buildBalanceHeader(),
                  ),

                  // Cards de ações rápidas
                  SliverToBoxAdapter(
                    child: _buildQuickActions(),
                  ),

                  // Tabs de períodos
                  SliverToBoxAdapter(
                    child: _buildTabsSection(),
                  ),

                  // Conteúdo das tabs
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDailyView(),
                        _buildWeeklyView(),
                        _buildMonthlyView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: VelloCard(
        borderRadius: VelloTokens.radiusXLarge,
        gradient: const LinearGradient(
          colors: [VelloTokens.brand, VelloTokens.brandLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saldo Disponível',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: VelloTokens.radiusSmall,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Vello Pay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'R\$ ${_saldoAtual.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _ganhosDia > _ganhosOntem
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: _ganhosDia > _ganhosOntem
                        ? VelloTokens.success
                        : VelloTokens.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _ganhosDia > _ganhosOntem
                        ? '+${(_ganhosDia - _ganhosOntem).toStringAsFixed(2)}'
                        : '${(_ganhosDia - _ganhosOntem).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: _ganhosDia > _ganhosOntem
                          ? VelloTokens.success
                          : VelloTokens.warning,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'vs. ontem',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
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

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: VelloButton.primary(
              onPressed: () => _showSacarDialog(),
              icon: const Icon(Icons.account_balance),
              text: 'Sacar',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: VelloButton.primary(
              onPressed: () => _showAdicionarCreditoDialog(),
              icon: const Icon(Icons.add_card),
              text: 'Adicionar',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: VelloButton.primary(
              onPressed: () => Navigator.pushNamed(context, '/historico'),
              icon: const Icon(Icons.receipt_long),
              text: 'Extrato',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          tabs: const [
            Tab(text: 'Hoje'),
            Tab(text: 'Semana'),
            Tab(text: 'Mês'),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEarningsCard(
            'Ganhos de Hoje',
            _ganhosDia,
            VelloTokens.success,
            Icons.today,
            '12 corridas realizadas',
          ),
          const SizedBox(height: 16),
          _buildComparisonCard(
            'Comparação com Ontem',
            _ganhosOntem,
            _ganhosDia - _ganhosOntem,
          ),
          const SizedBox(height: 16),
          _buildGoalProgressCard(),
        ],
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEarningsCard(
            'Ganhos da Semana',
            _ganhosSemana,
            VelloTokens.info,
            Icons.date_range,
            '47 corridas realizadas',
          ),
          const SizedBox(height: 16),
          _buildWeeklyBreakdown(),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEarningsCard(
            'Ganhos do Mês',
            _ganhosMes,
            VelloTokens.brand,
            Icons.calendar_month,
            '187 corridas realizadas',
          ),
          const SizedBox(height: 16),
          _buildMonthlyStats(),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(
    String title,
    double amount,
    Color color,
    IconData icon,
    String subtitle,
  ) {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
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
                    color: color.withOpacity(0.1),
                    borderRadius: VelloTokens.radiusMedium,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: VelloTokens.gray700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
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
            Text(
              'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(String title, double yesterday, double difference) {
    final isPositive = difference >= 0;

    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ontem',
                      style: TextStyle(
                        fontSize: 12,
                        color: VelloTokens.gray500,
                      ),
                    ),
                    Text(
                      'R\$ ${yesterday.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: VelloTokens.gray700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: isPositive ? VelloTokens.success : VelloTokens.danger,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositive ? '+' : ''}${difference.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isPositive ? VelloTokens.success : VelloTokens.danger,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${((difference / yesterday) * 100).abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: VelloTokens.gray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgressCard() {
    const dailyGoal = 150.0;
    final progress = _ganhosDia / dailyGoal;

    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Meta Diária',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray700,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: progress >= 1.0 ? VelloTokens.success : VelloTokens.brand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: VelloTokens.radiusSmall,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: VelloTokens.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? VelloTokens.success : VelloTokens.brand,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${_ganhosDia.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray600,
                  ),
                ),
                Text(
                  'R\$ ${dailyGoal.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBreakdown() {
    final weekData = [
      {'day': 'Seg', 'amount': 95.40},
      {'day': 'Ter', 'amount': 125.60},
      {'day': 'Qua', 'amount': 89.20},
      {'day': 'Qui', 'amount': 156.80},
      {'day': 'Sex', 'amount': 67.40},
      {'day': 'Sáb', 'amount': 89.40},
      {'day': 'Dom', 'amount': 0.0},
    ];

    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breakdown Semanal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 20),
            ...weekData.map((data) => _buildDayEarnings(
                  data['day'] as String,
                  data['amount'] as double,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDayEarnings(String day, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: VelloTokens.gray600,
            ),
          ),
          Text(
            amount > 0
                ? 'R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}'
                : 'Folga',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: amount > 0 ? VelloTokens.gray700 : VelloTokens.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return Column(
      children: [
        _buildStatCard(
          'Média Diária',
          'R\$ ${(_ganhosMes / 30).toStringAsFixed(2).replaceAll('.', ',')}',
          Icons.trending_up,
          VelloTokens.success,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Melhor Dia',
          'R\$ 234,80',
          Icons.star,
          VelloTokens.warning,
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Total de Corridas',
          '187 corridas',
          Icons.local_taxi,
          VelloTokens.info,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: VelloTokens.radiusSmall,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: VelloTokens.gray500,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: VelloTokens.gray700,
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

  void _showSacarDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Sacar Dinheiro'),
        content: const Text(
          'Funcionalidade de saque será implementada em breve.\n\nVocê receberá uma notificação quando estiver disponível.',
        ),
        actions: [
          VelloButton.primary(
            onPressed: () => Navigator.pop(context),
            text: 'Entendi',
          ),
        ],
      ),
    );
  }

  void _showAdicionarCreditoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Adicionar Crédito'),
        content: const Text(
          'Para adicionar créditos à sua carteira, complete mais corridas ou participe de promoções especiais.',
        ),
        actions: [
          VelloButton.primary(
            onPressed: () => Navigator.pop(context),
            text: 'Ok',
          ),
        ],
      ),
    );
  }

  void _addCredit() {}
  void _transferMoney() {}
  void _payBill() {}
}