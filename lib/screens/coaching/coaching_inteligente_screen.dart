
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/coaching_inteligente_service.dart';
import '../../constants/app_colors.dart';

class CoachingInteligenteScreen extends StatefulWidget {
  @override
  _CoachingInteligenteScreenState createState() => _CoachingInteligenteScreenState();
}

class _CoachingInteligenteScreenState extends State<CoachingInteligenteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachingInteligenteService>().inicializarCoaching();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coaching Inteligente'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              context.read<CoachingInteligenteService>().inicializarCoaching();
            },
          ),
        ],
      ),
      body: Consumer<CoachingInteligenteService>(
        builder: (context, coachingService, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPerformanceCard(coachingService),
                SizedBox(height: 16),
                _buildDicasSection(coachingService),
                SizedBox(height: 16),
                _buildMetasSection(coachingService),
                SizedBox(height: 16),
                _buildConquistasSection(coachingService),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerformanceCard(CoachingInteligenteService service) {
    final performance = service.performanceAtual;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Sua Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceItem(
                    'Corridas',
                    '${performance['totalCorridas'] ?? 0}',
                    Icons.directions_car,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceItem(
                    'Ganhos',
                    'R\$ ${(performance['totalGanhos'] ?? 0).toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceItem(
                    'Avaliação',
                    '${(performance['avaliacaoMedia'] ?? 0).toStringAsFixed(1)} ⭐',
                    Icons.star,
                  ),
                ),
                Expanded(
                  child: _buildPerformanceItem(
                    'Média/Dia',
                    'R\$ ${(performance['mediaDiaria'] ?? 0).toStringAsFixed(2)}',
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDicasSection(CoachingInteligenteService service) {
    final dicas = service.dicasAtivas;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Dicas Personalizadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (dicas.isEmpty)
              Text('Nenhuma dica disponível no momento.')
            else
              ...dicas.asMap().entries.map((entry) {
                final index = entry.key;
                final dica = entry.value;
                return _buildDicaItem(dica, index, service);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDicaItem(Map<String, dynamic> dica, int index, CoachingInteligenteService service) {
    final prioridade = dica['prioridade'] as String;
    Color corPrioridade = Colors.grey;
    
    switch (prioridade) {
      case 'alta':
        corPrioridade = Colors.red;
        break;
      case 'media':
        corPrioridade = Colors.orange;
        break;
      case 'baixa':
        corPrioridade = Colors.blue;
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.left(
          color: corPrioridade,
          width: 4,
        ),
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dica['icone'] ?? '💡',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  dica['titulo'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Chip(
                label: Text(
                  prioridade.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
                backgroundColor: corPrioridade,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            dica['descricao'] ?? '',
            style: TextStyle(fontSize: 12),
          ),
          if (dica['acao'] != null) ...[
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                service.marcarDicaComoVista(index);
                // Implementar ação específica
              },
              child: Text(dica['acao']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetasSection(CoachingInteligenteService service) {
    final metas = service.metasPersonalizadas;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, color: AppColors.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Metas Personalizadas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _mostrarDialogNovaMeta(service),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (metas.isEmpty)
              Text('Nenhuma meta criada. Toque em + para adicionar.')
            else
              ...metas.entries.map((entry) {
                return _buildMetaItem(entry.key, entry.value);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(String tipo, Map<String, dynamic> meta) {
    final progresso = (meta['progresso'] ?? 0.0) as double;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _obterTituloMeta(tipo),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${progresso.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: progresso >= 100 ? Colors.green : AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progresso / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progresso >= 100 ? Colors.green : AppColors.primaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Meta: ${meta['valor']} - Prazo: ${_formatarData(meta['prazo'])}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildConquistasSection(CoachingInteligenteService service) {
    final conquistas = service.conquistasDesbloqueadas;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Conquistas Recentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (conquistas.isEmpty)
              Text('Continue dirigindo para desbloquear conquistas!')
            else
              ...conquistas.take(3).map((conquista) {
                return _buildConquistaItem(conquista);
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildConquistaItem(Map<String, dynamic> conquista) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[50]!, Colors.orange[50]!],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Text(
            conquista['icone'] ?? '🏆',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conquista['titulo'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  conquista['descricao'] ?? '',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${conquista['pontos']} pts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogNovaMeta(CoachingInteligenteService service) {
    showDialog(
      context: context,
      builder: (context) {
        String tipoSelecionado = 'ganhos_diarios';
        double valor = 150;
        
        return AlertDialog(
          title: Text('Nova Meta'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: tipoSelecionado,
                    items: [
                      DropdownMenuItem(
                        value: 'ganhos_diarios',
                        child: Text('Ganhos Diários'),
                      ),
                      DropdownMenuItem(
                        value: 'corridas_diarias',
                        child: Text('Corridas por Dia'),
                      ),
                      DropdownMenuItem(
                        value: 'avaliacao_media',
                        child: Text('Avaliação Média'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        tipoSelecionado = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: valor.toString(),
                    decoration: InputDecoration(
                      labelText: 'Valor da Meta',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      valor = double.tryParse(value) ?? 150;
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                service.criarMetaPersonalizada(
                  tipoSelecionado,
                  valor,
                  DateTime.now().add(Duration(days: 30)),
                );
                Navigator.pop(context);
              },
              child: Text('Criar Meta'),
            ),
          ],
        );
      },
    );
  }

  String _obterTituloMeta(String tipo) {
    switch (tipo) {
      case 'ganhos_diarios': return 'Ganhos Diários';
      case 'corridas_diarias': return 'Corridas por Dia';
      case 'avaliacao_media': return 'Avaliação Média';
      default: return 'Meta';
    }
  }

  String _formatarData(dynamic data) {
    if (data is DateTime) {
      return '${data.day}/${data.month}/${data.year}';
    }
    return 'N/A';
  }
}
