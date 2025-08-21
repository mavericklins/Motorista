import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/admin/pontos_apoio_screen.dart';

class SupportPointsServiceGeoapify {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Chave da API Geoapify (mesma que você já usa)
  static const String _geoapifyApiKey = '203ba4a0a4304d349299a8aa22e1dcae';

  /// Obter pontos de apoio próximos usando Geoapify
  static Future<List<SupportPoint>> obterPontosApoio({
    double? latitude,
    double? longitude,
    double raioKm = 50.0,
    String? tipo,
  }) async {
    try {
      // Primeiro busca pontos salvos no Firebase
      final pontosSalvos = await _obterPontosSalvos(
        latitude: latitude,
        longitude: longitude,
        raioKm: raioKm,
        tipo: tipo,
      );

      // Se tem coordenadas, busca também no Geoapify
      if (latitude != null && longitude != null) {
        final pontosGeoapify = await _buscarPontosGeoapify(
          latitude: latitude,
          longitude: longitude,
          raioKm: raioKm,
          tipo: tipo,
        );
        
        // Combina e remove duplicatas
        final todosPontos = [...pontosSalvos, ...pontosGeoapify];
        return _removerDuplicatas(todosPontos);
      }

      return pontosSalvos;
    } catch (e) {
      print('❌ Erro ao obter pontos de apoio: $e');
      return [];
    }
  }

  /// Buscar pontos salvos no Firebase
  static Future<List<SupportPoint>> _obterPontosSalvos({
    double? latitude,
    double? longitude,
    double raioKm = 50.0,
    String? tipo,
  }) async {
    try {
      Query query = _firestore.collection('pontos_apoio');

      if (tipo != null && tipo != 'todos') {
        query = query.where('tipo', isEqualTo: tipo);
      }

      final snapshot = await query.get();
      final pontos = <SupportPoint>[];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        final ponto = SupportPoint(
          id: doc.id,
          nome: data['nome'] ?? '',
          tipo: data['tipo'] ?? '',
          endereco: data['endereco'] ?? '',
          latitude: (data['latitude'] ?? 0).toDouble(),
          longitude: (data['longitude'] ?? 0).toDouble(),
          telefone: data['telefone'] ?? '',
          aberto24h: data['aberto24h'] ?? false,
          horarioFuncionamento: data['horarioFuncionamento'] ?? '',
          servicos: List<String>.from(data['servicos'] ?? []),
          avaliacao: data['avaliacao']?.toDouble(),
        );

        // Filtrar por distância se coordenadas foram fornecidas
        if (latitude != null && longitude != null) {
          final distancia = Geolocator.distanceBetween(
            latitude,
            longitude,
            ponto.latitude,
            ponto.longitude,
          ) / 1000; // Converter para km

          if (distancia <= raioKm) {
            pontos.add(ponto);
          }
        } else {
          pontos.add(ponto);
        }
      }

      return pontos;
    } catch (e) {
      print('❌ Erro ao buscar pontos salvos: $e');
      return [];
    }
  }

  /// Buscar pontos usando API Geoapify
  static Future<List<SupportPoint>> _buscarPontosGeoapify({
    required double latitude,
    required double longitude,
    double raioKm = 50.0,
    String? tipo,
  }) async {
    try {
      final pontos = <SupportPoint>[];
      
      // Mapear tipos para categorias Geoapify
      final categorias = _obterCategoriasGeoapify(tipo);
      
      for (final categoria in categorias) {
        final pontosCategoria = await _buscarCategoria(
          latitude: latitude,
          longitude: longitude,
          raioKm: raioKm,
          categoria: categoria,
        );
        pontos.addAll(pontosCategoria);
      }

      return pontos;
    } catch (e) {
      print('❌ Erro ao buscar no Geoapify: $e');
      return [];
    }
  }

  /// Buscar uma categoria específica no Geoapify
  static Future<List<SupportPoint>> _buscarCategoria({
    required double latitude,
    required double longitude,
    required double raioKm,
    required String categoria,
  }) async {
    try {
      final raioMetros = (raioKm * 1000).toInt();
      final url = 'https://api.geoapify.com/v2/places'
          '?categories=$categoria'
          '&filter=circle:$longitude,$latitude,$raioMetros'
          '&bias=proximity:$longitude,$latitude'
          '&limit=20'
          '&apiKey=$_geoapifyApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List;

        return features.map((feature) {
          final properties = feature['properties'];
          final geometry = feature['geometry'];
          final coordinates = geometry['coordinates'] as List;

          return SupportPoint(
            id: 'geoapify_${properties['place_id'] ?? DateTime.now().millisecondsSinceEpoch}',
            nome: properties['name'] ?? properties['address_line1'] ?? 'Local',
            tipo: _mapearTipoGeoapify(categoria),
            endereco: properties['formatted'] ?? '',
            latitude: coordinates[1].toDouble(),
            longitude: coordinates[0].toDouble(),
            telefone: properties['contact']?['phone'] ?? '',
            aberto24h: false,
            horarioFuncionamento: _formatarHorario(properties['opening_hours']),
            servicos: _obterServicos(categoria),
            avaliacao: null,
            fonte: 'geoapify',
          );
        }).toList();
      }

      return [];
    } catch (e) {
      print('❌ Erro ao buscar categoria $categoria: $e');
      return [];
    }
  }

  /// Obter categorias Geoapify baseadas no tipo
  static List<String> _obterCategoriasGeoapify(String? tipo) {
    switch (tipo) {
      case 'combustivel':
        return ['automotive.gas_station'];
      case 'mecanica':
        return ['automotive.car_repair', 'automotive.car_dealer'];
      case 'alimentacao':
        return ['catering.restaurant', 'catering.fast_food', 'catering.cafe'];
      case 'descanso':
        return ['accommodation.hotel', 'accommodation.motel'];
      case 'saude':
        return ['healthcare.hospital', 'healthcare.pharmacy'];
      case 'banco':
        return ['commercial.bank', 'commercial.money_transfer'];
      default:
        return [
          'automotive.gas_station',
          'automotive.car_repair',
          'catering.restaurant',
          'catering.fast_food',
          'accommodation.hotel',
        ];
    }
  }

  /// Mapear categoria Geoapify para tipo local
  static String _mapearTipoGeoapify(String categoria) {
    if (categoria.contains('gas_station')) return 'combustivel';
    if (categoria.contains('car_repair') || categoria.contains('car_dealer')) return 'mecanica';
    if (categoria.contains('restaurant') || categoria.contains('fast_food') || categoria.contains('cafe')) return 'alimentacao';
    if (categoria.contains('hotel') || categoria.contains('motel')) return 'descanso';
    if (categoria.contains('hospital') || categoria.contains('pharmacy')) return 'saude';
    if (categoria.contains('bank') || categoria.contains('money_transfer')) return 'banco';
    return 'outros';
  }

  /// Formatar horário de funcionamento
  static String _formatarHorario(dynamic openingHours) {
    if (openingHours == null) return 'Horário não informado';
    if (openingHours is String) return openingHours;
    return 'Consultar horário';
  }

  /// Obter serviços baseados na categoria
  static List<String> _obterServicos(String categoria) {
    if (categoria.contains('gas_station')) {
      return ['Combustível', 'Conveniência', 'Lavagem'];
    } else if (categoria.contains('car_repair')) {
      return ['Mecânica', 'Elétrica', 'Pneus'];
    } else if (categoria.contains('restaurant')) {
      return ['Refeições', 'Bebidas', 'Wi-Fi'];
    } else if (categoria.contains('hotel')) {
      return ['Hospedagem', 'Estacionamento', 'Wi-Fi'];
    }
    return ['Serviços gerais'];
  }

  /// Remover pontos duplicados
  static List<SupportPoint> _removerDuplicatas(List<SupportPoint> pontos) {
    final pontosUnicos = <String, SupportPoint>{};
    
    for (final ponto in pontos) {
      final chave = '${ponto.latitude.toStringAsFixed(4)}_${ponto.longitude.toStringAsFixed(4)}';
      
      // Prioriza pontos salvos no Firebase sobre Geoapify
      if (!pontosUnicos.containsKey(chave) || ponto.fonte != 'geoapify') {
        pontosUnicos[chave] = ponto;
      }
    }
    
    return pontosUnicos.values.toList();
  }

  /// Salvar ponto de apoio no Firebase
  static Future<void> salvarPontoApoio(SupportPoint ponto) async {
    try {
      await _firestore.collection('pontos_apoio').add({
        'nome': ponto.nome,
        'tipo': ponto.tipo,
        'endereco': ponto.endereco,
        'latitude': ponto.latitude,
        'longitude': ponto.longitude,
        'telefone': ponto.telefone,
        'aberto24h': ponto.aberto24h,
        'horarioFuncionamento': ponto.horarioFuncionamento,
        'servicos': ponto.servicos,
        'avaliacao': ponto.avaliacao,
        'criadoEm': FieldValue.serverTimestamp(),
      });
      
      print('✅ Ponto de apoio salvo com sucesso');
    } catch (e) {
      print('❌ Erro ao salvar ponto de apoio: $e');
    }
  }

  /// Avaliar ponto de apoio
  static Future<void> avaliarPonto(String pontoId, double avaliacao) async {
    try {
      await _firestore.collection('pontos_apoio').doc(pontoId).update({
        'avaliacao': avaliacao,
        'avaliadoEm': FieldValue.serverTimestamp(),
      });
      
      print('✅ Avaliação salva com sucesso');
    } catch (e) {
      print('❌ Erro ao salvar avaliação: $e');
    }
  }

  /// Abrir navegação usando Geoapify/OpenStreetMap
  static Future<void> abrirNavegacao({
    required double latitude,
    required double longitude,
    String? nome,
  }) async {
    try {
      // Usar OpenStreetMap para navegação (compatível com Geoapify)
      final url = 'https://www.openstreetmap.org/directions?'
          'to=$latitude,$longitude'
          '${nome != null ? '&query=$nome' : ''}';
      
      // Em um app real, usar url_launcher
      print('🗺️ Abrindo navegação para: $url');
      
      // Alternativa: usar app de mapas do sistema
      // final mapsUrl = 'geo:$latitude,$longitude?q=$latitude,$longitude${nome != null ? '($nome)' : ''}';
      
    } catch (e) {
      print('❌ Erro ao abrir navegação: $e');
    }
  }

  /// Obter tipos de pontos disponíveis
  static List<Map<String, dynamic>> obterTiposPontos() {
    return [
      {
        'id': 'todos',
        'nome': 'Todos',
        'icone': 'location_on',
        'cor': 'blue',
      },
      {
        'id': 'combustivel',
        'nome': 'Postos de Combustível',
        'icone': 'local_gas_station',
        'cor': 'red',
      },
      {
        'id': 'mecanica',
        'nome': 'Oficinas Mecânicas',
        'icone': 'build',
        'cor': 'orange',
      },
      {
        'id': 'alimentacao',
        'nome': 'Restaurantes',
        'icone': 'restaurant',
        'cor': 'green',
      },
      {
        'id': 'descanso',
        'nome': 'Hotéis/Pousadas',
        'icone': 'hotel',
        'cor': 'purple',
      },
      {
        'id': 'saude',
        'nome': 'Saúde',
        'icone': 'local_hospital',
        'cor': 'pink',
      },
      {
        'id': 'banco',
        'nome': 'Bancos/ATM',
        'icone': 'account_balance',
        'cor': 'indigo',
      },
    ];
  }
}

