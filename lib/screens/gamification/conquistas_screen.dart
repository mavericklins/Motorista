import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/gamification_service.dart';
import '../../constants/app_colors.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';

class ConquistasScreen extends StatefulWidget {
  @override
  _ConquistasScreenState createState() => _ConquistasScreenState();
}

class _ConquistasScreenState extends State<ConquistasScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<ConquistaModel> _conquistas = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadConquistas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadConquistas() async {
    setState(() {
      _isLoading = true;
    });

    // Simula o carregamento de conquistas
    await Future.delayed(const Duration(milliseconds: 500));

    // Exemplo de dados de conquistas (substitua com dados reais do serviço)
    final mockConquistas = [
      ConquistaModel(
        id: '1',
        title: 'Primeira Corrida',
        description: 'Complete sua primeira corrida para desbloquear.',
        icon: Icons.directions_run,
        color: Colors.blue,
        isCompleted: true,
        progress: 1.0,
      ),
      ConquistaModel(
        id: '2',
        title: '500km Percorridos',
        description: 'Percorra 500km para ganhar esta conquista.',
        icon: Icons.map,
        color: Colors.green,
        isCompleted: false,
        progress: 0.75,
      ),
      ConquistaModel(
        id: '3',
        title: 'Motorista Estrela',
        description: 'Receba 5 avaliações 5 estrelas.',
        icon: Icons.star,
        color: Colors.amber,
        isCompleted: false,
        progress: 0.4,
      ),
      ConquistaModel(
        id: '4',
        title: 'Semana Perfeita',
        description: 'Complete 10 corridas em uma semana.',
        icon: Icons.calendar_today,
        color: Colors.purple,
        isCompleted: true,
        progress: 1.0,
      ),
    ];

    setState(() {
      _conquistas = mockConquistas;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.gray50,
      appBar: AppBar(
        title: const Text(
          'Conquistas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: VelloTokens.warning,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConquistas,
            tooltip: 'Atualizar conquistas',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: VelloTokens.warning,
              ),
            )
          : Column(
              children: [
                _buildStatsHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _conquistas.length,
                    itemBuilder: (context, index) {
                      final conquista = _conquistas[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildConquistaCard(conquista),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsHeader() {
    final completedCount = _conquistas.where((c) => c.isCompleted).length;
    final totalCount = _conquistas.length;
    final completionRate = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      child: VelloCard.gradient(
        gradient: const LinearGradient(
          colors: [VelloTokens.warning, Color(0xFFFCD34D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$completedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '/$totalCount',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suas Conquistas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(completionRate * 100).toInt()}% concluído',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completionRate,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConquistaCard(ConquistaModel conquista) {
    return VelloCard(
      borderRadius: VelloTokens.radiusXLarge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: conquista.isCompleted
                        ? VelloTokens.warning.withOpacity(0.1)
                        : VelloTokens.gray200,
                    borderRadius: VelloTokens.radiusMedium,
                  ),
                  child: Icon(
                    conquista.icon,
                    color: conquista.isCompleted
                        ? VelloTokens.warning
                        : VelloTokens.gray400,
                    size: 32,
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
                              conquista.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: conquista.isCompleted
                                    ? VelloTokens.gray700
                                    : VelloTokens.gray500,
                              ),
                            ),
                          ),
                          if (conquista.isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: VelloTokens.success,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Concluída',
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
                      const SizedBox(height: 8),
                      Text(
                        conquista.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: VelloTokens.gray600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!conquista.isCompleted) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progresso',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: VelloTokens.gray600,
                        ),
                      ),
                      Text(
                        '${(conquista.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: VelloTokens.brand,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: VelloTokens.radiusSmall,
                    child: LinearProgressIndicator(
                      value: conquista.progress,
                      backgroundColor: VelloTokens.gray200,
                      valueColor: AlwaysStoppedAnimation<Color>(VelloTokens.brand),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesTab(GamificationService service) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Progresso do nível
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nível ${service.currentLevel}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${service.currentXP} XP',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: service.levelProgress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  'Faltam ${service.xpToNextLevel} XP para o próximo nível',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Badges conquistados
          Text(
            'Badges Conquistados',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: service.achievements.length,
            itemBuilder: (context, index) {
              final achievement = service.achievements[index];
              return _buildBadgeCard(achievement);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> achievement) {
    final isUnlocked = achievement['unlocked'] ?? false;

    return GestureDetector(
      onTap: () => _showBadgeDetails(achievement),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              IconData(achievement['icon'], fontFamily: 'MaterialIcons'),
              size: 32,
              color: isUnlocked ? achievement['color'] : Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              achievement['title'],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.black : Colors.grey,
              ),
            ),
            if (achievement['progress'] != null)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: LinearProgressIndicator(
                  value: achievement['progress'],
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUnlocked ? achievement['color'] : Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingTab(GamificationService service) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Posição atual
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Sua Posição',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '#${service.currentRank}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'de ${service.totalDrivers} motoristas',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Top 10
          Text(
            'Top 10 Motoristas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: service.topDrivers.length,
            itemBuilder: (context, index) {
              final driver = service.topDrivers[index];
              return _buildRankingCard(driver, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(Map<String, dynamic> driver, int position) {
    Color? rankColor;
    IconData? rankIcon;

    switch (position) {
      case 1:
        rankColor = Colors.amber;
        rankIcon = Icons.emoji_events;
        break;
      case 2:
        rankColor = Colors.grey[400];
        rankIcon = Icons.workspace_premium;
        break;
      case 3:
        rankColor = Colors.orange[300];
        rankIcon = Icons.military_tech;
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: rankColor ?? AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: rankIcon != null
                ? Icon(rankIcon, color: Colors.white, size: 20)
                : Text(
                    '$position',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        title: Text(
          driver['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${driver['rides']} corridas'),
        trailing: Text(
          '${driver['xp']} XP',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildChallengesTab(GamificationService service) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Desafio diário
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
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
                    Icon(Icons.today, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Desafio Diário',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  service.dailyChallenge['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: service.dailyChallenge['progress'],
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${service.dailyChallenge['current']}/${service.dailyChallenge['target']}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '+${service.dailyChallenge['reward']} XP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Desafios semanais
          Text(
            'Desafios Semanais',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: service.weeklyChallenges.length,
            itemBuilder: (context, index) {
              final challenge = service.weeklyChallenges[index];
              return _buildChallengeCard(challenge);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  IconData(challenge['icon'], fontFamily: 'MaterialIcons'),
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge['title'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${challenge['reward']} XP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              challenge['description'],
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: challenge['progress'],
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge['current']}/${challenge['target']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Termina em ${challenge['timeLeft']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              IconData(achievement['icon'], fontFamily: 'MaterialIcons'),
              color: achievement['color'],
            ),
            SizedBox(width: 8),
            Text(achievement['title']),
          ],
        ),
        content: Text(achievement['description']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

// Dummy model for achievements, replace with your actual model
class ConquistaModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final double progress;

  ConquistaModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isCompleted,
    required this.progress,
  });
}