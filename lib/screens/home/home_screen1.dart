import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/sound_service.dart';
import '../../services/corrida_notification_service.dart';
import '../../services/motorista_online_service.dart';
import '../configuracoes/configuracoes_screen.dart';
import '../historico/historico_screen.dart';
import '../perfil/perfil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late MotoristaOnlineService _onlineService;
  
  // Variáveis para localização e nome do motorista
  Position? _currentPosition;
  String _motoristaName = 'Motorista'; // Valor padrão
  bool _isLoadingLocation = true;

  // Cores Vello
  static const Color velloOrange = Color(0xFFFF6B35);
  static const Color velloBlue = Color(0xFF2E3A59);
  static const Color velloGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    
    // Inicializar serviço de status online
    _onlineService = MotoristaOnlineService.instance;
    _onlineService.initialize();
    
    // Animação de pulso para status online
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Inicializar localização e dados do motorista
    _initializeData();
    
    // Som de boas-vindas ao entrar na home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundService.playLoginSound();
      // Inicializar serviço de notificações
      CorridaNotificationService.instance.initialize(context);
    });
  }

  // Função para inicializar localização e dados do motorista
  Future<void> _initializeData() async {
    await Future.wait([
      _getCurrentLocation(),
      _getMotoristaName(),
    ]);
  }

  // Função para obter localização atual automaticamente
  Future<void> _getCurrentLocation() async {
    try {
      // Verificar permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Obter localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      // Centralizar mapa na localização atual
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0,
      );

    } catch (e) {
      print('Erro ao obter localização: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // Função para obter nome do motorista do Firebase
  Future<void> _getMotoristaName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('motoristas')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            _motoristaName = data['nome'] ?? 'Motorista';
          });
        }
      }
    } catch (e) {
      print('Erro ao obter nome do motorista: $e');
      // Mantém o valor padrão "Motorista"
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    // Parar serviço de notificações
    CorridaNotificationService.instance.dispose();
    super.dispose();
  }

  void _toggleOnlineStatus() async {
    try {
      // Usar o serviço de status online
      await _onlineService.toggleOnlineStatus();
      
      // Som personalizado baseado no status
      if (_onlineService.isOnline) {
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
                _onlineService.isOnline ? Icons.radio_button_checked : Icons.radio_button_off,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                _onlineService.isOnline 
                    ? 'Você está online e pronto para corridas!' 
                    : 'Você está offline',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: _onlineService.isOnline ? velloGreen : Colors.grey[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      
    } catch (e) {
      // Mostrar erro se houver problema
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao alterar status: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
    
    // Se tiver localização atual, centralizar nela
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      );
    } else {
      // Senão, tentar obter localização novamente
      await _getCurrentLocation();
    }
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: velloOrange, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: velloBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _onlineService,
      child: Consumer<MotoristaOnlineService>(
        builder: (context, onlineService, child) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              backgroundColor: velloOrange,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                // Botão de status OFFLINE/ONLINE
                Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: ElevatedButton(
                    onPressed: _toggleOnlineStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onlineService.isOnline ? velloGreen : Colors.grey[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          onlineService.isOnline 
                              ? Icons.radio_button_checked 
                              : Icons.radio_button_off,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          onlineService.isOnline ? 'ONLINE' : 'OFFLINE',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Ícone Configurações
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white, size: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ConfiguracoesScreen(),
                      ),
                    );
                  },
                ),
                // Ícone Histórico
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.white, size: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoricoScreen(),
                      ),
                    );
                  },
                ),
                // Ícone Perfil
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white, size: 24),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PerfilScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    // Banner "Olá, [Nome do Motorista]!" com status em tempo real
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: velloBlue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Olá, $_motoristaName!',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  onlineService.isOnline 
                                      ? 'Você está online para receber corridas' 
                                      : 'Fique online para receber corridas',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                if (_currentPosition != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          size: 12,
                                          color: Colors.white60,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Localização detectada',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_isLoadingLocation)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white60),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Detectando localização...',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: onlineService.isOnline ? _pulseAnimation.value : 1.0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: onlineService.isOnline ? velloGreen : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    onlineService.isOnline 
                                        ? Icons.radio_button_checked 
                                        : Icons.radio_button_off,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Cards de ganhos
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    
                    const SizedBox(height: 16),
                    
                    // Mapa com localização em tempo real
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _currentPosition != null
                                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                                      : const LatLng(-23.5505, -46.6333),
                                  initialZoom: 13.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://maps.geoapify.com/v1/tile/osm-bright/{z}/{x}/{y}.png?apiKey=82e209c579e24e2cbb629e5fa679d352',
                                    userAgentPackageName: 'com.vello.motorista',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      if (_currentPosition != null)
                                        Marker(
                                          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                          width: 60,
                                          height: 60,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: onlineService.isOnline ? velloGreen : velloOrange,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 4),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (onlineService.isOnline ? velloGreen : velloOrange).withOpacity(0.3),
                                                  blurRadius: 10,
                                                  spreadRadius: 5,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.directions_car,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              // Botão para centralizar no mapa
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: FloatingActionButton(
                                  mini: true,
                                  backgroundColor: velloOrange,
                                  onPressed: _centerMap,
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              
                              // Indicador de carregamento de localização
                              if (_isLoadingLocation)
                                Positioned(
                                  top: 20,
                                  left: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Localizando...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

