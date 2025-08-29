
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../models/meta_ganhos.dart';
import '../../../services/analise_preditiva_service.dart';

class MetasGanhosScreen extends StatefulWidget {
  const MetasGanhosScreen({super.key});

  @override
  State<MetasGanhosScreen> createState() => _MetasGanhosScreenState();
}

class _MetasGanhosScreenState extends State<MetasGanhosScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _metaDiariaController = TextEditingController(text: '150.00');
  final _metaSemanalController = TextEditingController(text: '800.00');
  final _metaMensalController = TextEditingController(text: '3000.00');

  late TabController _tabController;

  // Cores Vello
  static const Color velloOrange = Color(0xFFFF6B35);
  static const Color velloBlue = Color(0xFF2E3A59);
  static const Color velloGreen = Color(0xFF10B981);

  Map<String, dynamic> _analisePerformance = {};
  Map<String, dynamic> _horariosMaisLucrativos = {};
  bool _carregandoAnalises = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _carregarAnalises();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _metaDiariaController.dispose();
    _metaSemanalController.dispose();
    _metaMensalController.dispose();
    super.dispose();
  }

  Future<void> _carregarAnalises() async {
    setState(() => _carregandoAnalises = true);

    try {
      final service = AnalisePreditivaService();

      final performance = await service.analisarPerformancePessoal('user_id'); // Substituir pelo ID real
      final horarios = await service.analisarHorariosMaisLucrativos('user_id');

      setState(() {
        _analisePerformance = performance;
        _horariosMaisLucrativos = horarios;
        _carregandoAnalises = false;
      });
    } catch (e) {
      print('Erro ao carregar análises: $e');
      setState(() => _carregandoAnalises = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: velloOrange,
        title: const Text('Metas de Ganhos', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Configurar', icon: Icon(Icons.track_changes)),
            Tab(text: 'Análises', icon: Icon(Icons.analytics)),
            Tab(text: 'Dicas', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConfigurarTab(),
          _buildAnalisesTab(),
          _buildDicasTab(),
        ],
      ),
    );
  }

  Widget _buildConfigurarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card de progresso atual
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [velloBlue, velloBlue.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Progresso de Hoje',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildProgressCircular('R\$ 45,00', 'R\$ 150,00', 0.3, 'Hoje'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMiniProgress('Semana', 0.5),
                    _buildMiniProgress('Mês', 0.7),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Formulário de metas
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Configurar Suas Metas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: velloBlue),
                  ),
                  const SizedBox(height: 20),

                  _buildMetaField('Meta Diária', _metaDiariaController, Icons.today, 'Ex: 150.00'),
                  const SizedBox(height: 16),
                  _buildMetaField('Meta Semanal', _metaSemanalController, Icons.date_range, 'Ex: 800.00'),
                  const SizedBox(height: 16),
                  _buildMetaField('Meta Mensal', _metaMensalController, Icons.calendar_month, 'Ex: 3000.00'),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _salvarMetas,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: velloOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Salvar Metas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sugestões inteligentes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: velloGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: velloGreen.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: velloGreen),
                    const SizedBox(width: 8),
                    const Text('Sugestões Inteligentes',
                        style: TextStyle(fontWeight: FontWeight.bold, color: velloBlue)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('• Baseado no seu histórico, uma meta de R\$ 120-180/dia é realista'),
                const Text('• Trabalhe 6-8 horas nos horários de pico para máximo rendimento'),
                const Text('• Foque nas terças, quartas e sextas para melhores resultados'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalisesTab() {
    if (_carregandoAnalises) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Performance mensal
          _buildAnaliseCard(
            'Performance Mensal',
            Icons.trending_up,
            [
              _buildAnaliseItem('Ganho este mês', 'R\$ ${_analisePerformance['ganhoAtual']?.toStringAsFixed(2) ?? '0,00'}'),
              _buildAnaliseItem('Mês anterior', 'R\$ ${_analisePerformance['ganhoAnterior']?.toStringAsFixed(2) ?? '0,00'}'),
              _buildAnaliseItem('Crescimento', '${_analisePerformance['crescimentoGanhos']?.toStringAsFixed(1) ?? '0,0'}%'),
              _buildAnaliseItem('Tendência', _analisePerformance['tendencia'] ?? 'Estável'),
            ],
          ),

          const SizedBox(height: 16),

          // Horários mais lucrativos
          _buildAnaliseCard(
            'Horários Mais Lucrativos',
            Icons.schedule,
            _horariosMaisLucrativos['horariosMaisLucrativos']?.map<Widget>((horario) =>
                _buildHorarioItem(
                    '${horario['hora']}h - ${horario['hora'] + 1}h',
                    'R\$ ${horario['ganho'].toStringAsFixed(2)}',
                    '${horario['corridas']} corridas'
                )
            )?.toList() ?? [const Text('Dados insuficientes')],
          ),

          const SizedBox(height: 16),

          // Estatísticas gerais
          _buildAnaliseCard(
            'Estatísticas Gerais',
            Icons.bar_chart,
            [
              _buildAnaliseItem('Total de corridas', '${_analisePerformance['corridasAtual'] ?? 0}'),
              _buildAnaliseItem('Ganho médio/corrida', 'R\$ ${_analisePerformance['ganhoMedioPorCorrida']?.toStringAsFixed(2) ?? '0,00'}'),
              _buildAnaliseItem('Crescimento corridas', '${_analisePerformance['crescimentoCorridas']?.toStringAsFixed(1) ?? '0,0'}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDicasTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDicaCard(
            'Maximize Seus Ganhos',
            Icons.monetization_on,
            Colors.green,
            [
              'Trabalhe durante os horários de pico (7h-9h e 17h-19h)',
              'Posicione-se em áreas de alta demanda',
              'Mantenha uma avaliação alta para receber mais corridas',
              'Use o modo eco para reduzir gastos com combustível',
            ],
          ),

          const SizedBox(height: 16),

          _buildDicaCard(
            'Gestão de Tempo',
            Icons.schedule,
            Colors.blue,
            [
              'Defina horários fixos de trabalho',
              'Faça pausas regulares para descanso',
              'Monitore seu tempo online vs offline',
              'Evite horários de baixa demanda',
            ],
          ),

          const SizedBox(height: 16),

          _buildDicaCard(
            'Economia e Eficiência',
            Icons.eco,
            Colors.orange,
            [
              'Monitore seus gastos com combustível',
              'Mantenha o veículo sempre em bom estado',
              'Planeje rotas para evitar trânsito',
              'Use aplicativos de trânsito para otimizar tempo',
            ],
          ),

          const SizedBox(height: 16),

          _buildDicaCard(
            'Atendimento ao Cliente',
            Icons.star,
            Colors.purple,
            [
              'Seja sempre cordial e profissional',
              'Mantenha o veículo limpo e organizado',
              'Ofereça água e balas para passageiros',
              'Seja pontual e cumpra horários combinados',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircular(String atual, String meta, double progress, String periodo) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(atual, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('de $meta', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 2),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniProgress(String periodo, double progress) {
    return Column(
      children: [
        Text(periodo, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMetaField(String label, TextEditingController controller, IconData icon, String hint) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: velloOrange),
        prefixText: 'R\$ ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: velloOrange, width: 2),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Campo obrigatório';
        final numero = double.tryParse(value!);
        if (numero == null || numero <= 0) return 'Valor inválido';
        return null;
      },
    );
  }

  Widget _buildAnaliseCard(String titulo, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: velloOrange),
              const SizedBox(width: 8),
              Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: velloBlue)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAnaliseItem(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildHorarioItem(String horario, String ganho, String corridas) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(horario, style: const TextStyle(fontWeight: FontWeight.w500)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(ganho, style: const TextStyle(fontWeight: FontWeight.bold, color: velloGreen)),
              Text(corridas, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDicaCard(String titulo, IconData icon, Color cor, List<String> dicas) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: cor),
              const SizedBox(width: 8),
              Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          ...dicas.map((dica) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
                ),
                Expanded(child: Text(dica, style: const TextStyle(height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _salvarMetas() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Metas salvas com sucesso!'),
          backgroundColor: velloGreen,
        ),
      );
    }
  }
}
