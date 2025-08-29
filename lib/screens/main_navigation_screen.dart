import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'ganhos/meus_creditos_screen.dart';
import 'carteira/carteira_digital_screen.dart';
import 'gamification/conquistas_screen.dart';
import 'gamification/goals_screen.dart';
import 'corridas_programadas/corridas_programadas_screen.dart';
import 'security/sos_screen.dart';
import 'insights/demand_prediction_screen.dart';
import 'analytics/analytics_dashboard_screen.dart';
import 'configuracoes/configuracoes_screen.dart';
import '../constants/app_colors.dart';
import '../theme/vello_tokens.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Cores Vello (definidas em VelloTokens, mas mantidas aqui para referência rápida se necessário)
  // static const Color velloOrange = Color(0xFFFF6B35);
  // static const Color velloBlue = Color(0xFF2E3A59);
  // static const Color velloGreen = Color(0xFF10B981);

  final List<Widget> _screens = [
    const HomeScreen(),
    const GanhosTabScreen(),
    const CorridasTabScreen(),
    const MaisTabScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Início',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_rounded),
                label: 'Ganhos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.directions_car_rounded),
                label: 'Corridas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz_rounded),
                label: 'Mais',
              ),
            ],
            backgroundColor: Colors.transparent,
            selectedItemColor: VelloTokens.brand,
            unselectedItemColor: VelloTokens.gray500,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

// Tab de Ganhos
class GanhosTabScreen extends StatelessWidget {
  const GanhosTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: VelloTokens.surfaceBackground,
        appBar: AppBar(
          title: const Text(
            'Ganhos',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: VelloTokens.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Créditos', icon: Icon(Icons.account_balance_wallet_rounded, size: 20)),
              Tab(text: 'Carteira', icon: Icon(Icons.credit_card_rounded, size: 20)),
              Tab(text: 'Metas', icon: Icon(Icons.flag_rounded, size: 20)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MeusCreditosScreen(),
            CarteiraDigitalScreen(),
            GoalsScreen(),
          ],
        ),
      ),
    );
  }
}

// Tab de Corridas
class CorridasTabScreen extends StatelessWidget {
  const CorridasTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: VelloTokens.surfaceBackground,
        appBar: AppBar(
          title: const Text(
            'Corridas',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: VelloTokens.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Programadas', icon: Icon(Icons.schedule_rounded, size: 20)),
              Tab(text: 'Insights', icon: Icon(Icons.insights_rounded, size: 20)),
              Tab(text: 'Analytics', icon: Icon(Icons.analytics_rounded, size: 20)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CorridasProgramadasScreen(),
            DemandPredictionScreen(),
            AnalyticsDashboardScreen(),
          ],
        ),
      ),
    );
  }
}

// Tab "Mais" com menu de funcionalidades
class MaisTabScreen extends StatelessWidget {
  const MaisTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VelloTokens.surfaceBackground,
      appBar: AppBar(
        title: const Text(
          'Mais Funcionalidades',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: VelloTokens.brand,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SEÇÃO SEGURANÇA
          _buildSectionCard(
            context: context,
            title: 'Segurança',
            icon: Icons.security_rounded,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.emergency_rounded,
                title: 'SOS Emergência',
                subtitle: 'Sistema de emergência e segurança',
                color: Colors.red,
                onTap: () => Navigator.pushNamed(context, '/sos'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SEÇÃO GAMIFICAÇÃO
          _buildSectionCard(
            context: context,
            title: 'Gamificação',
            icon: Icons.emoji_events_rounded,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.emoji_events_rounded,
                title: 'Conquistas',
                subtitle: 'Badges, ranking e desafios',
                color: VelloTokens.brand,
                onTap: () => Navigator.pushNamed(context, '/conquistas'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SEÇÃO CONFIGURAÇÕES
          _buildSectionCard(
            context: context,
            title: 'Configurações',
            icon: Icons.settings_rounded,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.settings_rounded,
                title: 'Configurações',
                subtitle: 'Conta, veículo e preferências',
                color: VelloTokens.gray700,
                onTap: () => Navigator.pushNamed(context, '/configuracoes'),
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Cabeçalho da seção
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VelloTokens.brand.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: VelloTokens.brand,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: VelloTokens.brand,
                  ),
                ),
              ],
            ),
          ),

          // Itens da seção
          ...children,
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: VelloTokens.brand,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: VelloTokens.gray500,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: VelloTokens.gray500,
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: VelloTokens.gray200,
          ),
        if (isLast) const SizedBox(height: 12),
      ],
    );
  }
}