import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  // Cores Vello
  static const Color velloOrange = Color(0xFFFF6B35);
  static const Color velloBlue = Color(0xFF2E3A59);
  static const Color velloGreen = Color(0xFF10B981);

  final List<Widget> _screens = [
    const HomeScreen(),
    const GanhosTabScreen(),
    const CorridasTabScreen(), 
    const MaisTabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: velloOrange,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Ganhos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              activeIcon: Icon(Icons.directions_car),
              label: 'Corridas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              activeIcon: Icon(Icons.more_horiz),
              label: 'Mais',
            ),
          ],
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
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Ganhos',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Créditos', icon: Icon(Icons.account_balance_wallet, size: 20)),
              Tab(text: 'Carteira', icon: Icon(Icons.credit_card, size: 20)),
              Tab(text: 'Metas', icon: Icon(Icons.flag, size: 20)),
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
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Corridas',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Programadas', icon: Icon(Icons.schedule, size: 20)),
              Tab(text: 'Insights', icon: Icon(Icons.insights, size: 20)),
              Tab(text: 'Analytics', icon: Icon(Icons.analytics, size: 20)),
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

  static const Color velloOrange = Color(0xFFFF6B35);
  static const Color velloBlue = Color(0xFF2E3A59);
  static const Color velloLightGray = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        title: const Text(
          'Mais Funcionalidades',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: velloOrange,
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
            icon: Icons.security,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.emergency,
                title: 'SOS Emergência',
                subtitle: 'Sistema de emergência e segurança',
                color: Colors.red,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SOSScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SEÇÃO GAMIFICAÇÃO
          _buildSectionCard(
            context: context,
            title: 'Gamificação',
            icon: Icons.emoji_events,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.emoji_events,
                title: 'Conquistas',
                subtitle: 'Badges, ranking e desafios',
                color: Colors.amber,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConquistasScreen()),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SEÇÃO CONFIGURAÇÕES
          _buildSectionCard(
            context: context,
            title: 'Configurações',
            icon: Icons.settings,
            children: [
              _buildMenuItem(
                context: context,
                icon: Icons.settings,
                title: 'Configurações',
                subtitle: 'Conta, veículo e preferências',
                color: velloBlue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConfiguracoesScreen()),
                ),
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
                    color: velloOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: velloOrange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: velloBlue,
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
              color: velloBlue,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF6B7280),
          ),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        ),
        if (!isLast)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: const Color(0xFFE5E7EB),
          ),
        if (isLast) const SizedBox(height: 12),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'historico/historico_screen.dart';
import 'perfil/perfil_screen.dart';
import '../constants/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoricoScreen(),
    const PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: VelloColors.laranja,
        unselectedItemColor: VelloColors.cinza,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
