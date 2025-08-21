import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/vello_integration_service.dart';
import '../../constants/app_colors.dart';

class FuncionalidadesExtrasScreen extends StatefulWidget {
  const FuncionalidadesExtrasScreen({Key? key}) : super(key: key);

  @override
  State<FuncionalidadesExtrasScreen> createState() => _FuncionalidadesExtrasScreenState();
}

class _FuncionalidadesExtrasScreenState extends State<FuncionalidadesExtrasScreen> {
  bool _analyticsAtivado = false;
  bool _segurancaAvancadaAtivada = false;
  bool _pontosApoioAtivados = false;
  bool _relatoriosFinanceirosAtivados = false;
  bool _notificacoesAvancadasAtivadas = false;
  
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarConfiguracoes();
  }

  Future<void> _carregarConfiguracoes() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _analyticsAtivado = prefs.getBool('analytics_ativado') ?? false;
      _segurancaAvancadaAtivada = prefs.getBool('seguranca_avancada_ativada') ?? false;
      _pontosApoioAtivados = prefs.getBool('pontos_apoio_ativados') ?? false;
      _relatoriosFinanceirosAtivados = prefs.getBool('relatorios_financeiros_ativados') ?? false;
      _notificacoesAvancadasAtivadas = prefs.getBool('notificacoes_avancadas_ativadas') ?? false;
      _loading = false;
    });
  }

  Future<void> _salvarConfiguracao(String chave, bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(chave, valor);
  }

  Future<void> _ativarFuncionalidadesExtras() async {
    try {
      setState(() => _loading = true);
      
      await VelloIntegrationService.inicializar();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Funcionalidades extras ativadas com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao ativar funcionalidades: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Funcionalidades Extras',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: VelloColors.laranja,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildFuncionalidadeCard(
                    titulo: 'Analytics Avançado',
                    descricao: 'Relatórios detalhados de performance e uso do app',
                    icone: Icons.analytics,
                    cor: Colors.blue,
                    ativo: _analyticsAtivado,
                    onChanged: (valor) async {
                      setState(() => _analyticsAtivado = valor);
                      await _salvarConfiguracao('analytics_ativado', valor);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFuncionalidadeCard(
                    titulo: 'Segurança Avançada',
                    descricao: 'Detecção de GPS falso e validação de documentos',
                    icone: Icons.security,
                    cor: Colors.red,
                    ativo: _segurancaAvancadaAtivada,
                    onChanged: (valor) async {
                      setState(() => _segurancaAvancadaAtivada = valor);
                      await _salvarConfiguracao('seguranca_avancada_ativada', valor);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFuncionalidadeCard(
                    titulo: 'Pontos de Apoio',
                    descricao: 'Mapa com postos, oficinas e restaurantes próximos',
                    icone: Icons.location_on,
                    cor: Colors.green,
                    ativo: _pontosApoioAtivados,
                    onChanged: (valor) async {
                      setState(() => _pontosApoioAtivados = valor);
                      await _salvarConfiguracao('pontos_apoio_ativados', valor);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFuncionalidadeCard(
                    titulo: 'Relatórios Financeiros',
                    descricao: 'Tela "Meus Créditos" com ganhos detalhados',
                    icone: Icons.account_balance_wallet,
                    cor: Colors.orange,
                    ativo: _relatoriosFinanceirosAtivados,
                    onChanged: (valor) async {
                      setState(() => _relatoriosFinanceirosAtivados = valor);
                      await _salvarConfiguracao('relatorios_financeiros_ativados', valor);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildFuncionalidadeCard(
                    titulo: 'Notificações Avançadas',
                    descricao: 'Notificações ricas com ações rápidas',
                    icone: Icons.notifications_active,
                    cor: Colors.purple,
                    ativo: _notificacoesAvancadasAtivadas,
                    onChanged: (valor) async {
                      setState(() => _notificacoesAvancadasAtivadas = valor);
                      await _salvarConfiguracao('notificacoes_avancadas_ativadas', valor);
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildBotaoAtivar(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [VelloColors.laranja, VelloColors.azul],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Funcionalidades Extras',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Ative funcionalidades adicionais que complementam seu app Vello sem afetar o funcionamento atual.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = VelloIntegrationService.statusServicos;
    final ativo = VelloIntegrationService.funcionalidadesDisponveis;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: ativo ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                ativo ? 'Funcionalidades Ativas' : 'Funcionalidades Inativas',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ativo 
                ? 'As funcionalidades extras estão funcionando normalmente.'
                : 'Ative as funcionalidades extras para ter acesso a recursos avançados.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuncionalidadeCard({
    required String titulo,
    required String descricao,
    required IconData icone,
    required Color cor,
    required bool ativo,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ativo ? cor.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icone, color: cor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: ativo,
            onChanged: onChanged,
            activeColor: cor,
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoAtivar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _ativarFuncionalidadesExtras,
        style: ElevatedButton.styleFrom(
          backgroundColor: VelloColors.laranja,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Ativar Funcionalidades Selecionadas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

