
import 'package:flutter/material.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../theme/vello_tokens.dart';

class CarteiraDigitalScreen extends StatefulWidget {
  const CarteiraDigitalScreen({super.key});

  @override
  State<CarteiraDigitalScreen> createState() => _CarteiraDigitalScreenState();
}

class _CarteiraDigitalScreenState extends State<CarteiraDigitalScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Dados simulados
  final double _saldoTotal = 89.40;
  final int _corridasHoje = 12;
  final String _metaAnual = "R\$ 45.000";
  final double _progressoMeta = 0.68;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.gray50,
      appBar: AppBar(
        title: const Text(
          'Ganhos',
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
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/historico'),
            tooltip: 'Histórico',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeaderCard(),
          _buildTabsSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCreditosTab(),
                _buildCarteiraTab(),
                _buildMetasTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo Disponível',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'R\$ 89,40',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: VelloTokens.radiusMedium,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Corridas Hoje',
                      '$_corridasHoje',
                      Icons.directions_car,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      'Meta Anual',
                      _metaAnual,
                      Icons.flag,
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: VelloTokens.radiusMedium,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
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
              fontSize: 18,
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
            Tab(text: 'Créditos'),
            Tab(text: 'Carteira'),
            Tab(text: 'Metas'),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildGanhosCard(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 24),
          _buildTransacoesList(),
        ],
      ),
    );
  }

  Widget _buildCarteiraTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSaldoCard(),
          const SizedBox(height: 16),
          _buildPaymentMethods(),
          const SizedBox(height: 16),
          _buildWithdrawOptions(),
        ],
      ),
    );
  }

  Widget _buildMetasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMetaAnualCard(),
          const SizedBox(height: 16),
          _buildMetasSemana(),
        ],
      ),
    );
  }

  Widget _buildGanhosCard() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: VelloTokens.success.withOpacity(0.1),
                    borderRadius: VelloTokens.radiusMedium,
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: VelloTokens.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ganhos de Hoje',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: VelloTokens.gray600,
                        ),
                      ),
                      Text(
                        '12 corridas realizadas',
                        style: TextStyle(
                          fontSize: 12,
                          color: VelloTokens.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'R\$ ${_saldoTotal.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: VelloTokens.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: VelloButton.icon(
            onPressed: () => _showSacarDialog(),
            icon: Icons.monetization_on,
            text: 'Sacar',
            type: VelloButtonType.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VelloButton.icon(
            onPressed: () => _showAdicionarDialog(),
            icon: Icons.add_card,
            text: 'Adicionar',
            type: VelloButtonType.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: VelloButton.icon(
            onPressed: () => _showExtratoDialog(),
            icon: Icons.receipt_long,
            text: 'Extrato',
            type: VelloButtonType.ghost,
          ),
        ),
      ],
    );
  }

  Widget _buildSaldoCard() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Saldo em Carteira',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: VelloTokens.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${_saldoTotal.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: VelloTokens.gray50,
                borderRadius: VelloTokens.radiusMedium,
                border: Border.all(color: VelloTokens.gray200),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: VelloTokens.info,
                    size: 20,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Seu saldo está protegido e pode ser sacado a qualquer momento',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: VelloTokens.gray600,
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

  Widget _buildPaymentMethods() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Formas de Pagamento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodItem(
              'PIX',
              'Receba na hora',
              Icons.pix,
              VelloTokens.brand,
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodItem(
              'Conta Bancária',
              'Receba em 1 dia útil',
              Icons.account_balance,
              VelloTokens.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: VelloTokens.radiusMedium,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: VelloTokens.radiusSmall,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: VelloTokens.gray600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: VelloTokens.gray400,
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawOptions() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saque Rápido',
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
                  child: _buildQuickWithdrawButton('R\$ 20'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickWithdrawButton('R\$ 50'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickWithdrawButton('Tudo'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickWithdrawButton(String value) {
    return VelloButton(
      text: value,
      onPressed: () => _showSacarDialog(),
      type: VelloButtonType.secondary,
      size: VelloButtonSize.small,
    );
  }

  Widget _buildMetaAnualCard() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meta Anual',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.gray800,
                  ),
                ),
                Text(
                  '${(_progressoMeta * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: VelloTokens.brand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _metaAnual,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: VelloTokens.radiusSmall,
              child: LinearProgressIndicator(
                value: _progressoMeta,
                backgroundColor: VelloTokens.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(VelloTokens.brand),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'R\$ ${(45000 * _progressoMeta).toStringAsFixed(0)} de R\$ 45.000',
              style: const TextStyle(
                fontSize: 12,
                color: VelloTokens.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetasSemana() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metas da Semana',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetaItem('40 Corridas', 32, 40),
            const SizedBox(height: 12),
            _buildMetaItem('R\$ 800 em Ganhos', 650, 800),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(String title, double atual, double meta) {
    final progress = (atual / meta).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: VelloTokens.gray700,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: progress >= 1.0 ? VelloTokens.success : VelloTokens.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: VelloTokens.radiusSmall,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: VelloTokens.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? VelloTokens.success : VelloTokens.warning
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${atual.toStringAsFixed(0)} de ${meta.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 12,
            color: VelloTokens.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildTransacoesList() {
    return VelloCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Últimas Transações',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray800,
              ),
            ),
            const SizedBox(height: 16),
            _buildTransactionItem(
              'Corrida #1234',
              'Hoje às 14:30',
              '+ R\$ 15,40',
              VelloTokens.success,
              Icons.directions_car,
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              'Corrida #1233',
              'Hoje às 13:45',
              '+ R\$ 22,80',
              VelloTokens.success,
              Icons.directions_car,
            ),
            const SizedBox(height: 12),
            _buildTransactionItem(
              'Saque PIX',
              'Ontem às 18:00',
              '- R\$ 100,00',
              VelloTokens.danger,
              Icons.pix,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(String title, String subtitle, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: VelloTokens.radiusSmall,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: VelloTokens.gray800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: VelloTokens.gray500,
                ),
              ),
            ],
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

  void _showSacarDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Sacar Dinheiro'),
        content: const Text('Funcionalidade de saque será implementada em breve.'),
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

  void _showAdicionarDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Adicionar Crédito'),
        content: const Text('Funcionalidade de adicionar crédito será implementada em breve.'),
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

  void _showExtratoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Extrato Detalhado'),
        content: const Text('Funcionalidade de extrato detalhado será implementada em breve.'),
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
}
