import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:vello_motorista/constants/app_colors.dart';
import 'package:vello_motorista/services/auth_service.dart';

// Banner de boas-vindas (adaptado para motorista)
class WelcomeBanner extends StatelessWidget {
  final String userName;
  final bool isOnline;

  const WelcomeBanner({
    super.key, 
    required this.userName,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B3A57), Color(0xFF2A4A6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, $userName!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isOnline ? 'Você está online e pronto!' : 'Fique online para receber corridas',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOnline ? const Color(0xFF10B981) : const Color(0xFFFF8C42),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isOnline ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOnline = false;
  LatLng? currentLocation;
  MapController? _mapController; // Mudança: nullable inicialmente
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isLoadingLocation = true;
  String _locationError = '';

  // Cores da identidade visual Vello
  static const Color velloBlue = Color(0xFF1B3A57);
  static const Color velloOrange = Color(0xFFFF8C42);
  static const Color velloLightGray = Color(0xFFF8F9FA);
  static const Color velloCardBackground = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    // Inicializar MapController apenas quando necessário
    _initializeLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // Verificar se o serviço de localização está habilitado
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Serviço de localização desabilitado. Ative o GPS nas configurações.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Verificar permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = 'Permissão de localização negada. Permita o acesso nas configurações.';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Permissão de localização negada permanentemente. Vá em Configurações > Apps > Vello Motorista > Permissões e ative a localização.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Obter localização atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _locationError = '';
        // Inicializar MapController apenas quando temos localização
        _mapController = MapController();
      });

      // Aguardar um frame antes de mover o mapa
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapController != null && currentLocation != null) {
          _mapController!.move(currentLocation!, 16);
        }
      });

      // Iniciar rastreamento de localização em tempo real
      _startLocationTracking();

    } catch (e) {
      setState(() {
        _locationError = 'Erro ao obter localização: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  void _startLocationTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Atualizar a cada 10 metros
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        if (mounted) {
          setState(() {
            currentLocation = LatLng(position.latitude, position.longitude);
          });
        }
      },
      onError: (error) {
        print('Erro no rastreamento de localização: $error');
      },
    );
  }

  void _centralizarMapa() {
    if (_mapController != null && currentLocation != null) {
      _mapController!.move(currentLocation!, 16);
    }
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOnline ? 'Você está online e pronto para receber corridas!' : 'Você está offline',
        ),
        backgroundColor: _isOnline ? const Color(0xFF10B981) : const Color(0xFF6B7280),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _retryLocation() {
    setState(() {
      _isLoadingLocation = true;
      _locationError = '';
      currentLocation = null;
      _mapController = null; // Reset do MapController
    });
    _initializeLocation();
  }

  @override
  Widget build(BuildContext context) {
    // TESTE - CONFIRMAR SE CÓDIGO NOVO ESTÁ SENDO EXECUTADO
    print("🗺️ NOVO CÓDIGO CARREGADO - MAPA ATIVO");
    
    return Scaffold(
      backgroundColor: velloLightGray,
      
      appBar: AppBar(
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Status badge
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isOnline ? const Color(0xFF10B981) : const Color(0xFF6B7280),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isOnline ? 'ONLINE' : 'OFFLINE',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/perfil'),
            tooltip: 'Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () => Navigator.pushNamed(context, '/historico'),
            tooltip: 'Histórico',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/configuracoes'),
            tooltip: 'Configurações',
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Stack(
        children: [
          Column(
            children: [
              // Banner de boas-vindas
              WelcomeBanner(
                userName: 'Motorista',
                isOnline: _isOnline,
              ),
              
              // Cards de ganhos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _buildEarningsCard('Hoje', 'R\$ 0,00', Icons.today)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildEarningsCard('Semana', 'R\$ 0,00', Icons.date_range)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildEarningsCard('Mês', 'R\$ 0,00', Icons.calendar_month)),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Mapa
              Expanded(
                child: _buildMapSection(),
              ),
              
              // Botão Online/Offline
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _toggleOnlineStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOnline ? const Color(0xFFEF4444) : velloOrange,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: _isOnline 
                        ? const Color(0xFFEF4444).withOpacity(0.3)
                        : velloOrange.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isOnline ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOnline ? 'FICAR OFFLINE' : 'FICAR ONLINE',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Botão de centralizar mapa
          if (currentLocation != null && _mapController != null)
            Positioned(
              bottom: 100,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  heroTag: "btnCentralizar",
                  onPressed: _centralizarMapa,
                  backgroundColor: velloOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  child: const Icon(Icons.my_location, size: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    if (_isLoadingLocation) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: velloCardBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: velloOrange,
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Obtendo sua localização...',
                style: TextStyle(
                  fontSize: 16,
                  color: velloBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Certifique-se de que o GPS está ativado',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_locationError.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: velloCardBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 48,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro de Localização',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _locationError,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: velloBlue,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _retryLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: velloOrange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Só renderizar o mapa se temos localização E MapController inicializado
    if (currentLocation == null || _mapController == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: velloCardBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: velloOrange),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        child: FlutterMap(
          mapController: _mapController!,
          options: MapOptions(
            center: currentLocation!,
            zoom: 16,
            minZoom: 10.0,
            maxZoom: 18.0,
            interactiveFlags: InteractiveFlag.all,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.vello.motorista',
              maxZoom: 18,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: currentLocation!,
                  width: 60,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _isOnline ? const Color(0xFF10B981) : velloOrange,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_taxi,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            // Círculo indicando área de cobertura
            CircleLayer(
              circles: [
                CircleMarker(
                  point: currentLocation!,
                  radius: 100,
                  useRadiusInMeter: true,
                  color: (_isOnline ? const Color(0xFF10B981) : velloOrange).withOpacity(0.1),
                  borderColor: (_isOnline ? const Color(0xFF10B981) : velloOrange).withOpacity(0.3),
                  borderStrokeWidth: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: velloCardBackground,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: velloOrange,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: velloBlue,
            ),
          ),
        ],
      ),
    );
  }
}

