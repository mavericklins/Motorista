import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../services/geolocation_service.dart';
import '../../services/firebase_corridas_service.dart';
import '../../services/sound_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/corrida_popup_widget.dart';
import '../../widgets/corridas_disponiveis_widget.dart';
import '../../widgets/common/vello_card.dart';
import '../../widgets/common/vello_button.dart';
import '../../widgets/common/status_chip.dart';
import '../../theme/vello_tokens.dart';
import '../../constants/app_colors.dart';

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
    return Scaffold(
      backgroundColor: velloLightGray,
      appBar: AppBar(
        backgroundColor: velloOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // Status chip
          StatusChip(
            label: _isOnline ? 'ONLINE' : 'OFFLINE',
            color: _isOnline ? VelloTokens.colorGreen : VelloTokens.colorOrange,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            borderRadius: BorderRadius.circular(20),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
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
      body: SafeArea(
        child: Column(
          children: [
            // Banner de boas-vindas
            WelcomeBanner(
              userName: 'Motorista',
              isOnline: _isOnline,
            ),
            const SizedBox(height: 12),
            // Botões rápidos restaurados
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickButton(
                  icon: Icons.emoji_events,
                  label: 'Conquistas',
                  route: '/conquistas',
                  color: Colors.amber,
                ),
                _buildQuickButton(
                  icon: Icons.warning,
                  label: 'SOS',
                  route: '/sos',
                  color: Colors.red,
                ),
                _buildQuickButton(
                  icon: Icons.account_balance_wallet,
                  label: 'Carteira',
                  route: '/carteira',
                  color: Colors.green,
                ),
                _buildQuickButton(
                  icon: Icons.schedule,
                  label: 'Corridas',
                  route: '/corridas-programadas',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
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
              child: VelloButton(
                onPressed: _toggleOnlineStatus,
                text: _isOnline ? 'FICAR OFFLINE' : 'FICAR ONLINE',
                icon: _isOnline ? Icons.pause_circle_filled : Icons.play_circle_filled,
                backgroundColor: _isOnline ? VelloTokens.colorRed : VelloTokens.colorOrange,
                foregroundColor: Colors.white,
                borderRadius: BorderRadius.circular(30),
                elevation: 4,
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    if (_isLoadingLocation) {
      return VelloCard(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
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
      return VelloCard(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
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
              VelloButton.icon(
                onPressed: _retryLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
                backgroundColor: velloOrange,
                foregroundColor: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    // Só renderizar o mapa se temos localização E MapController inicializado
    if (currentLocation == null || _mapController == null) {
      return VelloCard(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
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
            initialCenter: currentLocation!,
            initialZoom: 16,
            minZoom: 10.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.vello.motorista', // CORRIGIDO: Warning do flutter_map
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
    return VelloCard(
      padding: const EdgeInsets.all(16),
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

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required String route,
    required Color color,
  }) {
    return Column(
      children: [
        Material(
          color: color.withOpacity(0.15),
          shape: const CircleBorder(),
          child: IconButton(
            icon: Icon(icon, color: color, size: 28),
            onPressed: () => Navigator.pushNamed(context, route),
            tooltip: label,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}