
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/financial_service.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';

class MeusCreditosScreen extends StatefulWidget {
  const MeusCreditosScreen({super.key});

  @override
  State<MeusCreditosScreen> createState() => _MeusCreditosScreenState();
}

class _MeusCreditosScreenState extends State<MeusCreditosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FinancialService _financialService = FinancialService();
  
  bool _isLoading = false;
  double _saldoAtual = 0.0;
  double _creditosPendentes = 0.0;
  List<TransacaoCredito> _transacoes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCreditos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCreditos() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _saldoAtual = 247.83;
        _creditosPendentes = 89.45;
        
        _transacoes = [
          TransacaoCredito(
            id: '1',
            tipo: TipoTransacao.corrida,
            valor: 25.50,
            data: DateTime.now().subtract(const Duration(hours: 2)),
            status: StatusTransacao.confirmada,
            descricao: 'Corrida Centro → Shopping',
            detalhes: 'Taxa de 15% já descontada',
          ),
          TransacaoCredito(
            id: '2',
            tipo: TipoTransacao.bonus,
            valor: 15.00,
            data: DateTime.now().subtract(const Duration(hours: 5)),
            status: StatusTransacao.confirmada,
            descricao: 'Bônus Meta Semanal',
            detalhes: 'Meta de 50 corridas atingida',
          ),
          TransacaoCredito(
            id: '3',
            tipo: TipoTransacao.corrida,
            valor: 18.75,
            data: DateTime.now().subtract(const Duration(days: 1)),
            status: StatusTransacao.pendente,
            descricao: 'Corrida Aeroporto → Centro',
            detalhes: 'Processamento em até 24h',
          ),
          TransacaoCredito(
            id: '4',
            tipo: TipoTransacao.saque,
            valor: -150.00,
            data: DateTime.now().subtract(const Duration(days: 2)),
            status: StatusTransacao.confirmada,
            descricao: 'Saque PIX',
            detalhes: 'Transferido para conta ****1234',
          ),
        ];
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar créditos: $e'),
            backgroundColor: VelloTokens.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.gray50,
      appBar: AppBar(
        title: const Text(
          'Meus Créditos',
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
            onPressed: _loadCreditos,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelloTokens.brand,
              ),
            )
          : Column(
              children: [
                _buildBalanceHeader(),
                _buildQuickActions(),
                _buildTabsSection(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTransacoesView(),
                      _buildExtractView(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBalanceHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: VelloCard.gradient(
        gradient: const LinearGradient(
          colors: [VelloTokens.success, Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
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
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
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
                          'Pronto para saque',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'R\$ ${_saldoAtual.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: VelloTokens.radiusSmall,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '+12.5%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (_creditosPendentes > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: VelloTokens.radiusMedium,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Créditos Pendentes',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'R\$ ${_creditosPendentes.toStringAsFixed(2).replaceAll('.', ',')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: VelloButton(
              text: 'Sacar Agora',
              onPressed: _saldoAtual >= 10.00 ? () => _showSaqueDialog() : null,
              type: VelloButtonType.primary,
              icon: Icons.monetization_on,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: VelloButton(
              text: 'Extrato Completo',
              onPressed: () => _tabController.animateTo(1),
              type: VelloButtonType.ghost,
              icon: Icons.receipt_long,
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
            Tab(text: 'Transações'),
            Tab(text: 'Extrato'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransacoesView() {
    if (_transacoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_outlined,
              size: 64,
              color: VelloTokens.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma transação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suas transações aparecerão aqui',
              style: TextStyle(
                fontSize: 14,
                color: VelloTokens.gray500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transacoes.length,
      itemBuilder: (context, index) {
        final transacao = _transacoes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTransacaoCard(transacao),
        );
      },
    );
  }

  Widget _buildTransacaoCard(TransacaoCredito transacao) {
    final isPositive = transacao.valor > 0;
    final color = isPositive ? VelloTokens.success : VelloTokens.danger;
    final icon = _getTransacaoIcon(transacao.tipo);

    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      onTap: () => _showTransacaoDetails(transacao),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          transacao.descricao,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: VelloTokens.gray700,
                          ),
                        ),
                      ),
                      StatusChip(
                        label: _getStatusLabel(transacao.status),
                        type: _getStatusChipType(transacao.status),
                        size: StatusChipSize.small,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateTime(transacao.data),
                    style: TextStyle(
                      fontSize: 12,
                      color: VelloTokens.gray500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isPositive ? '+' : ''}R\$ ${transacao.valor.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Icon(
                  Icons.chevron_right,
                  color: VelloTokens.gray400,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtractView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExtractSummary(),
          const SizedBox(height: 20),
          _buildExtractFilters(),
          const SizedBox(height: 20),
          _buildExtractChart(),
        ],
      ),
    );
  }

  Widget _buildExtractSummary() {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo dos Últimos 30 Dias',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSummaryMetric('Receitas', 1247.83, VelloTokens.success)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryMetric('Saques', 800.00, VelloTokens.danger)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildSummaryMetric('Bônus', 75.00, VelloTokens.warning)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryMetric('Líquido', 522.83, VelloTokens.info)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: VelloTokens.radiusMedium,
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: VelloTokens.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtractFilters() {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtros',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: VelloButton(
                    text: 'Últimos 7 dias',
                    onPressed: () {},
                    type: VelloButtonType.ghost,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: VelloButton(
                    text: 'Últimos 30 dias',
                    onPressed: () {},
                    type: VelloButtonType.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: VelloButton(
                    text: 'Personalizado',
                    onPressed: () {},
                    type: VelloButtonType.ghost,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExtractChart() {
    return VelloCard(
      borderRadius: VelloTokens.radiusLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolução dos Ganhos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: VelloTokens.gray700,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: VelloTokens.gray100,
                borderRadius: VelloTokens.radiusMedium,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 48,
                      color: VelloTokens.gray400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gráfico em desenvolvimento',
                      style: TextStyle(
                        color: VelloTokens.gray500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransacaoIcon(TipoTransacao tipo) {
    switch (tipo) {
      case TipoTransacao.corrida:
        return Icons.local_taxi;
      case TipoTransacao.bonus:
        return Icons.card_giftcard;
      case TipoTransacao.saque:
        return Icons.account_balance;
      case TipoTransacao.estorno:
        return Icons.undo;
    }
  }

  String _getStatusLabel(StatusTransacao status) {
    switch (status) {
      case StatusTransacao.pendente:
        return 'Pendente';
      case StatusTransacao.confirmada:
        return 'Confirmada';
      case StatusTransacao.cancelada:
        return 'Cancelada';
    }
  }

  StatusChipType _getStatusChipType(StatusTransacao status) {
    switch (status) {
      case StatusTransacao.pendente:
        return StatusChipType.warning;
      case StatusTransacao.confirmada:
        return StatusChipType.success;
      case StatusTransacao.cancelada:
        return StatusChipType.error;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}min atrás';
      }
      return '${difference.inHours}h atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    }
    
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  void _showSaqueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: const Text('Saque de Créditos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Saldo disponível: R\$ ${_saldoAtual.toStringAsFixed(2).replaceAll('.', ',')}'),
            const SizedBox(height: 16),
            const Text('O saque será processado em até 1 hora útil via PIX.'),
          ],
        ),
        actions: [
          VelloButton(
            text: 'Cancelar',
            onPressed: () => Navigator.pop(context),
            type: VelloButtonType.ghost,
          ),
          VelloButton(
            text: 'Sacar Tudo',
            onPressed: () {
              Navigator.pop(context);
              _processSaque(_saldoAtual);
            },
            type: VelloButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showTransacaoDetails(TransacaoCredito transacao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: VelloTokens.radiusLarge,
        ),
        title: Text(transacao.descricao),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valor: R\$ ${transacao.valor.abs().toStringAsFixed(2).replaceAll('.', ',')}'),
            const SizedBox(height: 8),
            Text('Data: ${_formatDateTime(transacao.data)}'),
            const SizedBox(height: 8),
            Text('Status: ${_getStatusLabel(transacao.status)}'),
            if (transacao.detalhes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Detalhes:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(transacao.detalhes),
            ],
          ],
        ),
        actions: [
          VelloButton(
            text: 'Fechar',
            onPressed: () => Navigator.pop(context),
            type: VelloButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _processSaque(double valor) {
    // TODO: Implementar saque real
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saque de R\$ ${valor.toStringAsFixed(2)} solicitado!'),
        backgroundColor: VelloTokens.success,
      ),
    );
  }
}

// Models para transações
class TransacaoCredito {
  final String id;
  final TipoTransacao tipo;
  final double valor;
  final DateTime data;
  final StatusTransacao status;
  final String descricao;
  final String detalhes;

  TransacaoCredito({
    required this.id,
    required this.tipo,
    required this.valor,
    required this.data,
    required this.status,
    required this.descricao,
    required this.detalhes,
  });
}

enum TipoTransacao {
  corrida,
  bonus,
  saque,
  estorno,
}

enum StatusTransacao {
  pendente,
  confirmada,
  cancelada,
}
