import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/driver_goals.dart';
import '../../services/gamification_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GamificationService _gamificationService = GamificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text('Metas e Conquistas', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF16213E),
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Hoje', icon: Icon(Icons.today)),
            Tab(text: 'Semana', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'Mês', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Conquistas', icon: Icon(Icons.emoji_events)),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF0F3460),
        ),
      ),
      body: StreamBuilder<DriverGoals?>(
        stream: _gamificationService.getDriverGoals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final goals = snapshot.data;
          if (goals == null) {
            return _buildEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDailyGoals(goals),
              _buildWeeklyGoals(goals),
              _buildMonthlyGoals(goals),
              _buildAchievements(goals),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Suas metas serão criadas\napós a primeira corrida',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoals(DriverGoals goals) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLevelCard(goals),
          SizedBox(height: 16),
          Text(
            'Metas de Hoje',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...goals.metasDiarias.entries.map((entry) =>
              _buildGoalCard(entry.key, entry.value)),
          SizedBox(height: 16),
          _buildDailyStats(goals),
        ],
      ),
    );
  }

  Widget _buildWeeklyGoals(DriverGoals goals) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metas da Semana',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...goals.metasSemanais.entries.map((entry) =>
              _buildGoalCard(entry.key, entry.value)),
          SizedBox(height: 16),
          _buildWeeklyRanking(),
        ],
      ),
    );
  }

  Widget _buildMonthlyGoals(DriverGoals goals) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metas do Mês',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...goals.metasMensais.entries.map((entry) =>
              _buildGoalCard(entry.key, entry.value)),
          SizedBox(height: 16),
          _buildMonthlyStats(goals),
        ],
      ),
    );
  }

  Widget _buildAchievements(DriverGoals goals) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Suas Conquistas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${goals.conquistas.length} conquistas',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (goals.conquistas.isEmpty)
            _buildEmptyAchievements()
          else
            ...goals.conquistas.map((achievement) =>
                _buildAchievementCard(achievement)),
          SizedBox(height: 16),
          _buildAvailableAchievements(goals),
        ],
      ),
    );
  }

  Widget _buildLevelCard(DriverGoals goals) {
    final nextLevelPoints = _getNextLevelPoints(goals.nivel);
    final progressToNext = goals.pontuacao / nextLevelPoints;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F3460), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nível ${goals.nivel}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${goals.pontuacao} pontos',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${goals.nivel}',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressToNext.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          SizedBox(height: 8),
          Text(
            'Próximo nível: ${nextLevelPoints - goals.pontuacao} pontos',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String tipo, GoalTarget meta) {
    final progress = meta.progresso;
    final isCompleted = meta.concluida;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
            ? Border.all(color: Colors.green, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getGoalIcon(tipo),
                    color: isCompleted ? Colors.green : Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    _getGoalTitle(tipo),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (isCompleted)
                Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${meta.atual.toStringAsFixed(tipo == 'corridas' ? 0 : 2)} / ${meta.objetivo.toStringAsFixed(tipo == 'corridas' ? 0 : 2)} ${_getGoalUnit(tipo)}',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? Colors.green : Colors.blue,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% completo',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              if (meta.bonus != null)
                Text(
                  'Bônus: R\$ ${meta.bonus!.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              achievement.icone,
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.titulo,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  achievement.descricao,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  '${achievement.pontos} pontos • ${_formatDate(achievement.conquistadoEm)}',
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAchievements() {
    return Container(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Nenhuma conquista ainda',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Complete corridas para desbloquear conquistas',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableAchievements(DriverGoals goals) {
    final conquistadas = goals.conquistas.map((c) => c.id).toSet();
    final disponiveis = GamificationService.availableAchievements.entries
        .where((entry) => !conquistadas.contains(entry.key))
        .toList();

    if (disponiveis.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conquistas Disponíveis',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ...disponiveis.take(5).map((entry) {
          final achievement = entry.value;
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF16213E).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Text(achievement['icone'], style: TextStyle(fontSize: 20)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement['titulo'],
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        achievement['descricao'],
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${achievement['pontos']} pts',
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDailyStats(DriverGoals goals) {
    final stats = goals.estatisticas;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estatísticas Gerais',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Total Corridas',
                '${stats['totalCorridas'] ?? 0}',
                Icons.directions_car,
              ),
              _buildStatItem(
                'Total Ganhos',
                'R\$ ${(stats['totalGanhos'] ?? 0.0).toStringAsFixed(2)}',
                Icons.attach_money,
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Avaliação',
                '${(stats['avaliacaoMedia'] ?? 0.0).toStringAsFixed(1)} ⭐',
                Icons.star,
              ),
              _buildStatItem(
                'Noturnas',
                '${stats['corridasNoturnas'] ?? 0}',
                Icons.nightlight_round,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildWeeklyRanking() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _gamificationService.getWeeklyRanking(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final ranking = snapshot.data ?? [];
        if (ranking.isEmpty) {
          return SizedBox();
        }

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF16213E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ranking Semanal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              ...ranking.take(5).map((driver) => _buildRankingItem(driver)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> driver) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getRankingColor(driver['posicao']),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${driver['posicao']}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver['nome'],
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  'Nível ${driver['nivel']} • ${driver['corridas']} corridas',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            'R\$ ${driver['ganhos'].toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(DriverGoals goals) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Mês',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          _buildMonthlyChart(goals),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(DriverGoals goals) {
    // Simular gráfico mensal
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Gráfico de Performance Mensal',
              style: TextStyle(color: Colors.grey),
            ),
            Text(
              '(Em desenvolvimento)',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGoalIcon(String tipo) {
    switch (tipo) {
      case 'corridas':
        return Icons.directions_car;
      case 'ganhos':
        return Icons.attach_money;
      case 'tempo_online':
        return Icons.access_time;
      default:
        return Icons.flag;
    }
  }

  String _getGoalTitle(String tipo) {
    switch (tipo) {
      case 'corridas':
        return 'Corridas';
      case 'ganhos':
        return 'Ganhos';
      case 'tempo_online':
        return 'Tempo Online';
      default:
        return tipo;
    }
  }

  String _getGoalUnit(String tipo) {
    switch (tipo) {
      case 'corridas':
        return 'corridas';
      case 'ganhos':
        return 'reais';
      case 'tempo_online':
        return 'horas';
      default:
        return '';
    }
  }

  Color _getRankingColor(int posicao) {
    switch (posicao) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  int _getNextLevelPoints(int nivel) {
    if (nivel == 1) return 100;
    if (nivel == 2) return 300;
    if (nivel == 3) return 600;
    if (nivel == 4) return 1000;
    if (nivel == 5) return 1500;
    return 1500 + ((nivel - 5) * 500);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}