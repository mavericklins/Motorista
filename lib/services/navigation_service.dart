import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

/// Serviço de navegação integrado para Vello Motorista
class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Chave da API Geoapify (reutilizada do app passageiro)
  static const String _geoapifyApiKey = 'YOUR_GEOAPIFY_API_KEY';
  
  // URLs das APIs
  static const String _geoapifyBaseUrl = 'https://api.geoapify.com/v1';
  static const String _openRouteServiceUrl = 'https://api.openrouteservice.org/v2';
  
  // Configurações de navegação
  static const double _routeUpdateThreshold = 50.0; // metros
  static const int _routeRecalculationInterval = 30; // segundos
  
  // Estado da navegação
  bool _isNavigating = false;
  Route? _currentRoute;
  LatLng? _currentLocation;
  LatLng? _destination;
  StreamSubscription<Position>? _locationSubscription;
  Timer? _routeUpdateTimer;
  
  // Callbacks
  Function(Route)? onRouteCalculated;
  Function(NavigationInstruction)? onNavigationUpdate;
  Function(double)? onDistanceUpdate;
  Function(Duration)? onETAUpdate;
  Function()? onDestinationReached;
  Function(String)? onNavigationError;

  /// Inicia navegação para um destino
  Future<bool> startNavigation({
    required LatLng destination,
    LatLng? origin,
    NavigationProfile profile = NavigationProfile.driving,
    bool avoidTolls = false,
    bool avoidHighways = false,
  }) async {
    try {
      _destination = destination;
      
      // Usa localização atual se origem não fornecida
      if (origin == null) {
        final position = await Geolocator.getCurrentPosition();
        origin = LatLng(position.latitude, position.longitude);
      }
      
      _currentLocation = origin;
      
      // Calcula rota inicial
      final route = await calculateRoute(
        origin: origin,
        destination: destination,
        profile: profile,
        avoidTolls: avoidTolls,
        avoidHighways: avoidHighways,
      );
      
      if (route == null) {
        onNavigationError?.call('Não foi possível calcular a rota');
        return false;
      }
      
      _currentRoute = route;
      _isNavigating = true;
      
      // Notifica rota calculada
      onRouteCalculated?.call(route);
      
      // Inicia monitoramento de localização
      await _startLocationTracking();
      
      // Inicia timer de atualização de rota
      _startRouteUpdateTimer();
      
      return true;
    } catch (e) {
      onNavigationError?.call('Erro ao iniciar navegação: $e');
      return false;
    }
  }

  /// Para a navegação
  void stopNavigation() {
    _isNavigating = false;
    _currentRoute = null;
    _destination = null;
    _locationSubscription?.cancel();
    _routeUpdateTimer?.cancel();
  }

  /// Calcula rota entre dois pontos
  Future<Route?> calculateRoute({
    required LatLng origin,
    required LatLng destination,
    NavigationProfile profile = NavigationProfile.driving,
    bool avoidTolls = false,
    bool avoidHighways = false,
    List<LatLng>? waypoints,
  }) async {
    try {
      // Monta parâmetros da requisição
      final params = {
        'waypoints': _formatWaypoints([origin, ...?waypoints, destination]),
        'mode': _getProfileString(profile),
        'apiKey': _geoapifyApiKey,
      };
      
      if (avoidTolls) params['avoid'] = 'tolls';
      if (avoidHighways) params['avoid'] = 'highways';
      
      final uri = Uri.parse('$_geoapifyBaseUrl/routing').replace(queryParameters: params);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseRouteResponse(data);
      } else {
        print('Erro na API de rota: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao calcular rota: $e');
      return null;
    }
  }

  /// Inicia rastreamento de localização
  Future<void> _startLocationTracking() async {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Atualiza a cada 5 metros
    );
    
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      _updateCurrentLocation(LatLng(position.latitude, position.longitude));
    });
  }

  /// Atualiza localização atual
  void _updateCurrentLocation(LatLng newLocation) {
    if (!_isNavigating || _currentRoute == null) return;
    
    final previousLocation = _currentLocation;
    _currentLocation = newLocation;
    
    // Verifica se precisa recalcular rota
    if (previousLocation != null) {
      final distanceFromRoute = _calculateDistanceFromRoute(newLocation);
      if (distanceFromRoute > _routeUpdateThreshold) {
        _recalculateRoute();
      }
    }
    
    // Atualiza instruções de navegação
    _updateNavigationInstructions();
    
    // Verifica se chegou ao destino
    if (_destination != null) {
      final distanceToDestination = Geolocator.distanceBetween(
        newLocation.latitude,
        newLocation.longitude,
        _destination!.latitude,
        _destination!.longitude,
      );
      
      if (distanceToDestination < 50) { // 50 metros do destino
        onDestinationReached?.call();
        stopNavigation();
      }
    }
  }

  /// Calcula distância da localização atual até a rota
  double _calculateDistanceFromRoute(LatLng location) {
    if (_currentRoute == null) return 0;
    
    double minDistance = double.infinity;
    
    for (int i = 0; i < _currentRoute!.coordinates.length - 1; i++) {
      final segmentStart = _currentRoute!.coordinates[i];
      final segmentEnd = _currentRoute!.coordinates[i + 1];
      
      final distance = _distanceToLineSegment(location, segmentStart, segmentEnd);
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    
    return minDistance;
  }

  /// Calcula distância de um ponto até um segmento de linha
  double _distanceToLineSegment(LatLng point, LatLng lineStart, LatLng lineEnd) {
    final A = point.latitude - lineStart.latitude;
    final B = point.longitude - lineStart.longitude;
    final C = lineEnd.latitude - lineStart.latitude;
    final D = lineEnd.longitude - lineStart.longitude;
    
    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    
    if (lenSq == 0) {
      return Geolocator.distanceBetween(
        point.latitude, point.longitude,
        lineStart.latitude, lineStart.longitude,
      );
    }
    
    final param = dot / lenSq;
    
    LatLng closestPoint;
    if (param < 0) {
      closestPoint = lineStart;
    } else if (param > 1) {
      closestPoint = lineEnd;
    } else {
      closestPoint = LatLng(
        lineStart.latitude + param * C,
        lineStart.longitude + param * D,
      );
    }
    
    return Geolocator.distanceBetween(
      point.latitude, point.longitude,
      closestPoint.latitude, closestPoint.longitude,
    );
  }

  /// Recalcula rota
  Future<void> _recalculateRoute() async {
    if (_currentLocation == null || _destination == null) return;
    
    final newRoute = await calculateRoute(
      origin: _currentLocation!,
      destination: _destination!,
    );
    
    if (newRoute != null) {
      _currentRoute = newRoute;
      onRouteCalculated?.call(newRoute);
    }
  }

  /// Inicia timer de atualização de rota
  void _startRouteUpdateTimer() {
    _routeUpdateTimer = Timer.periodic(
      Duration(seconds: _routeRecalculationInterval),
      (timer) {
        if (_isNavigating) {
          _recalculateRoute();
        } else {
          timer.cancel();
        }
      },
    );
  }

  /// Atualiza instruções de navegação
  void _updateNavigationInstructions() {
    if (_currentRoute == null || _currentLocation == null) return;
    
    final instruction = _getCurrentInstruction();
    if (instruction != null) {
      onNavigationUpdate?.call(instruction);
    }
    
    // Atualiza distância restante
    final remainingDistance = _calculateRemainingDistance();
    onDistanceUpdate?.call(remainingDistance);
    
    // Atualiza ETA
    final eta = _calculateETA(remainingDistance);
    onETAUpdate?.call(eta);
  }

  /// Obtém instrução atual de navegação
  NavigationInstruction? _getCurrentInstruction() {
    if (_currentRoute == null || _currentLocation == null) return null;
    
    // Encontra o próximo ponto de manobra
    final nextManeuver = _findNextManeuver();
    if (nextManeuver == null) return null;
    
    final distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      nextManeuver.location.latitude,
      nextManeuver.location.longitude,
    );
    
    return NavigationInstruction(
      text: nextManeuver.instruction,
      distance: distance,
      maneuverType: nextManeuver.type,
      streetName: nextManeuver.streetName,
    );
  }

  /// Encontra próxima manobra
  RouteManeuver? _findNextManeuver() {
    if (_currentRoute == null || _currentLocation == null) return null;
    
    // Implementação simplificada - encontra a manobra mais próxima à frente
    for (final maneuver in _currentRoute!.maneuvers) {
      final distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        maneuver.location.latitude,
        maneuver.location.longitude,
      );
      
      if (distance > 10) { // Manobra ainda não executada
        return maneuver;
      }
    }
    
    return null;
  }

  /// Calcula distância restante
  double _calculateRemainingDistance() {
    if (_currentRoute == null || _currentLocation == null) return 0;
    
    // Implementação simplificada - distância em linha reta até o destino
    if (_destination != null) {
      return Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _destination!.latitude,
        _destination!.longitude,
      );
    }
    
    return 0;
  }

  /// Calcula ETA
  Duration _calculateETA(double remainingDistance) {
    const averageSpeed = 30.0; // km/h - velocidade média estimada
    final timeInHours = (remainingDistance / 1000) / averageSpeed;
    return Duration(minutes: (timeInHours * 60).round());
  }

  /// Abre navegação em app externo
  Future<bool> openExternalNavigation({
    required LatLng destination,
    LatLng? origin,
    NavigationApp app = NavigationApp.googleMaps,
  }) async {
    try {
      String url;
      
      switch (app) {
        case NavigationApp.googleMaps:
          if (origin != null) {
            url = 'https://www.google.com/maps/dir/${origin.latitude},${origin.longitude}/${destination.latitude},${destination.longitude}';
          } else {
            url = 'https://www.google.com/maps/search/?api=1&query=${destination.latitude},${destination.longitude}';
          }
          break;
          
        case NavigationApp.waze:
          url = 'https://waze.com/ul?ll=${destination.latitude}%2C${destination.longitude}&navigate=yes';
          break;
          
        case NavigationApp.appleMaps:
          url = 'http://maps.apple.com/?daddr=${destination.latitude},${destination.longitude}';
          break;
      }
      
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Erro ao abrir navegação externa: $e');
      return false;
    }
  }

  /// Busca endereço por coordenadas (geocoding reverso)
  Future<String?> getAddressFromCoordinates(LatLng coordinates) async {
    try {
      final uri = Uri.parse('$_geoapifyBaseUrl/geocode/reverse').replace(
        queryParameters: {
          'lat': coordinates.latitude.toString(),
          'lon': coordinates.longitude.toString(),
          'apiKey': _geoapifyApiKey,
        },
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        if (features.isNotEmpty) {
          final properties = features.first['properties'];
          return properties['formatted'] ?? properties['name'];
        }
      }
      
      return null;
    } catch (e) {
      print('Erro no geocoding reverso: $e');
      return null;
    }
  }

  /// Busca coordenadas por endereço (geocoding)
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final uri = Uri.parse('$_geoapifyBaseUrl/geocode/search').replace(
        queryParameters: {
          'text': address,
          'apiKey': _geoapifyApiKey,
        },
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;
        
        if (features.isNotEmpty) {
          final geometry = features.first['geometry'];
          final coordinates = geometry['coordinates'] as List;
          return LatLng(coordinates[1], coordinates[0]); // lat, lon
        }
      }
      
      return null;
    } catch (e) {
      print('Erro no geocoding: $e');
      return null;
    }
  }

  /// Formata waypoints para API
  String _formatWaypoints(List<LatLng> waypoints) {
    return waypoints
        .map((point) => '${point.longitude},${point.latitude}')
        .join('|');
  }

  /// Converte perfil de navegação para string da API
  String _getProfileString(NavigationProfile profile) {
    switch (profile) {
      case NavigationProfile.driving:
        return 'drive';
      case NavigationProfile.walking:
        return 'walk';
      case NavigationProfile.cycling:
        return 'bike';
    }
  }

  /// Parseia resposta da API de rota
  Route? _parseRouteResponse(Map<String, dynamic> data) {
    try {
      final features = data['features'] as List;
      if (features.isEmpty) return null;
      
      final feature = features.first;
      final geometry = feature['geometry'];
      final properties = feature['properties'];
      
      // Extrai coordenadas
      final coordinates = (geometry['coordinates'] as List)
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList();
      
      // Extrai informações da rota
      final distance = properties['distance']?.toDouble() ?? 0.0;
      final duration = Duration(seconds: properties['time']?.toInt() ?? 0);
      
      // Extrai manobras (simplificado)
      final maneuvers = <RouteManeuver>[];
      final segments = properties['segments'] as List? ?? [];
      
      for (final segment in segments) {
        final steps = segment['steps'] as List? ?? [];
        for (final step in steps) {
          final instruction = step['instruction']['text'] ?? '';
          final stepDistance = step['distance']?.toDouble() ?? 0.0;
          final maneuverType = step['maneuver']['type'] ?? 'straight';
          
          if (instruction.isNotEmpty) {
            maneuvers.add(RouteManeuver(
              instruction: instruction,
              location: coordinates.first, // Simplificado
              distance: stepDistance,
              type: maneuverType,
              streetName: '',
            ));
          }
        }
      }
      
      return Route(
        coordinates: coordinates,
        distance: distance,
        duration: duration,
        maneuvers: maneuvers,
      );
    } catch (e) {
      print('Erro ao parsear resposta da rota: $e');
      return null;
    }
  }

  /// Getters
  bool get isNavigating => _isNavigating;
  Route? get currentRoute => _currentRoute;
  LatLng? get currentLocation => _currentLocation;
  LatLng? get destination => _destination;
}

/// Perfis de navegação
enum NavigationProfile {
  driving,
  walking,
  cycling,
}

/// Apps de navegação externos
enum NavigationApp {
  googleMaps,
  waze,
  appleMaps,
}

/// Modelo de rota
class Route {
  final List<LatLng> coordinates;
  final double distance; // em metros
  final Duration duration;
  final List<RouteManeuver> maneuvers;

  Route({
    required this.coordinates,
    required this.distance,
    required this.duration,
    required this.maneuvers,
  });
}

/// Modelo de manobra
class RouteManeuver {
  final String instruction;
  final LatLng location;
  final double distance;
  final String type;
  final String streetName;

  RouteManeuver({
    required this.instruction,
    required this.location,
    required this.distance,
    required this.type,
    required this.streetName,
  });
}

/// Instrução de navegação
class NavigationInstruction {
  final String text;
  final double distance; // em metros
  final String maneuverType;
  final String streetName;

  NavigationInstruction({
    required this.text,
    required this.distance,
    required this.maneuverType,
    required this.streetName,
  });
}

