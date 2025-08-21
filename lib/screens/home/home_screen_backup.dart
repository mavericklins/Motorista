import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';
import '../../widgets/corridas_disponiveis_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isOnline = false;
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late TabController _tabController;

  // Cores Vello
  static const Color velloOrange = Color(0xFFFF6B35);
  static const Color velloBlue = Color(0xFF2E3A59);
  static const Color velloGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    
    // Tab Controller
    _tabController = TabController(length: 2, vsync: this);
    
    // Animação de pulso para status online
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Som de boas-vindas ao entrar na home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundService.playLoginSound();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleOnlineStatus() async {
    setState(() {
      _isOnline = !_isOnline;
    });
    
    // Som personalizado baseado no status
    if (_isOnline) {
      await SoundService.playOnlineSound();
      _pulseController.repeat(reverse: true);
    } else {
      await SoundService.playOfflineSound();
      _pulseController.stop();
      _pulseController.reset();
    }
    
    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isOnline ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _isOnline ? 'Você está online e pronto para corridas!' : 'Você está offline',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: _isOnline ? velloGreen : Colors.grey[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onEarningsCardTap(String period) async {
    await SoundService.playEarningsSound();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.attach_money, color: velloOrange),
            const SizedBox(width: 8),
            Text('Ganhos - $period'),
          ],
        ),
        content: Text('Seus ganhos de $period serão exibidos aqui.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SoundService.playNotificationSound();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _centerMap() async {
    await SoundService.playLocationSound();
    _mapController.move(const LatLng(-23.5505, -46.6333), 15.0);
  }

  void _simulateNewRide() async {
    await SoundService.playNewRideSound();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.directions_car, color: velloOrange),
            const SizedBox(width: 8),
            const Text('Nova Corrida!'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🚗 Corrida disponível'),
            SizedBox(height: 8),
            Text('📍 Origem: Av. Paulista, 1000'),
            Text('📍 Destino: Shopping Ibirapuera'),
            SizedBox(height: 8),
            Text('💰 Valor estimado: R\$ 15,50'),
            Text('⏱️ Tempo estimado: 12 min'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SoundService.playCancelSound();
            },
            child: const Text('Recusar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              SoundService.playRideAcceptedSound();
              _showRideAccepted();
            },
            style: ElevatedButton.styleFrom(backgroundColor: velloOrange),
            child: const Text('Aceitar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRideAccepted() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Corrida aceita! Indo buscar o passageiro...'),
          ],
        ),
        backgroundColor: velloGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Finalizar',
          textColor: Colors.white,
          onPressed: () async {
            await SoundService.playRideCompletedSound();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Corrida finalizada! +R\$ 15,50'),
                backgroundColor: velloGreen,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vello Motorista',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Status indicator com animação
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isOnline ? _pulseAnimation.value : 1.0,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isOnline ? velloGreen : Colors.grey[600],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _isOnline ? [
                      BoxShadow(
                        color: velloGreen.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isOnline ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isOnline ? 'ONLINE' : 'OFFLINE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              icon: Icon(Icons.map),
              text: 'Mapa',
            ),
            Tab(
              icon: Icon(Icons.local_taxi),
              text: 'Corridas',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba do Mapa
          _buildMapTab(),
          // Aba das Corridas
          _buildCorridasTab(),
        ],
      ),
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(-23.5505, -46.6333), // São Paulo
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=82e209c579e24e2cbb629e5fa679d352',
                userAgentPackageName: 'com.vello.motorista',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: const LatLng(-23.5505, -46.6333),
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isOnline ? velloGreen : velloOrange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: (_isOnline ? velloGreen : velloOrange).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_taxi,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Cards de ganhos com sons
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: _buildEarningsCard('Hoje', 'R\$ 0,00', Icons.today, () => _onEarningsCardTap('Hoje')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEarningsCard('Semana', 'R\$ 0,00', Icons.date_range, () => _onEarningsCardTap('Semana')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildEarningsCard('Mês', 'R\$ 0,00', Icons.calendar_month, () => _onEarningsCardTap('Mês')),
                ),
              ],
            ),
          ),
          
          // Botões flutuantes
          Positioned(
            bottom: 100,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botão simular nova corrida (apenas para demo)
                FloatingActionButton(
                  heroTag: "newRide",
                  onPressed: _isOnline ? _simulateNewRide : null,
                  backgroundColor: _isOnline ? velloBlue : Colors.grey,
                  child: const Icon(Icons.add_alert, color: Colors.white),
                ),
                const SizedBox(height: 12),
                // Botão centralizar mapa
                FloatingActionButton(
                  heroTag: "center",
                  onPressed: _centerMap,
                  backgroundColor: velloOrange,
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Botão Online/Offline
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _toggleOnlineStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isOnline ? Colors.red[600] : velloGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: Text(
                _isOnline ? 'FICAR OFFLINE' : 'FICAR ONLINE',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(),
    );
  }

  Widget _buildEarningsCard(String title, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: velloOrange, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: velloBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [velloBlue, velloOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 30, color: velloOrange),
                ),
                SizedBox(height: 16),
                Text(
                  'Motorista Vello',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  'motorista@vello.com',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up, color: velloBlue),
            title: const Text('Testar Sons'),
            onTap: () async {
              Navigator.pop(context);
              await SoundService.testSounds();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: velloBlue),
            title: const Text('Configurações'),
            onTap: () {
              Navigator.pop(context);
              SoundService.playNotificationSound();
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sair'),
            onTap: () async {
              await SoundService.playLogoutSound();
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Método para construir a aba do mapa
  Widget _buildMapTab() {
    return Stack(
      children: [
        // Mapa
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(-23.5505, -46.6333), // São Paulo
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.vello.motorista',
            ),
          ],
        ),

        // Botão de status online/offline
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _toggleOnlineStatus,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isOnline ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: _isOnline ? velloGreen : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOnline ? 'ONLINE' : 'OFFLINE',
                        style: TextStyle(
                          color: _isOnline ? velloGreen : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Botão de centralizar mapa
        Positioned(
          bottom: 100,
          right: 20,
          child: FloatingActionButton(
            onPressed: _centerMap,
            backgroundColor: velloOrange,
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        ),

        // Cards de ganhos
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Row(
            children: [
              Expanded(
                child: _buildEarningsCard('Hoje', 'R\$ 45,30', Icons.today),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEarningsCard('Semana', 'R\$ 312,80', Icons.date_range),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildEarningsCard('Mês', 'R\$ 1.245,60', Icons.calendar_month),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Método para construir a aba de corridas
  Widget _buildCorridasTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Erro de autenticação',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              'Faça login novamente',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (!_isOnline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              'Você está offline',
              style: TextStyle(
                fontSize: 18, 
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ative o status online para receber corridas',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleOnlineStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: velloOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.power_settings_new),
                  SizedBox(width: 8),
                  Text('Ficar Online'),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return CorridasDisponiveisWidget(motoristaId: user.uid);
  }

  Widget _buildEarningsCard(String period, String amount, IconData icon) {
    return GestureDetector(
      onTap: () => _onEarningsCardTap(period),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: velloOrange, size: 20),
            const SizedBox(height: 4),
            Text(
              period,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: velloBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

