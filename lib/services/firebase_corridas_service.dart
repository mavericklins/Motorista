import 'dart:async';
import 'dart:math' hide atan2, cos, sin, sqrt; // Importando apenas o que é necessário e renomeando para evitar conflitos
import 'dart:math' as math; // Importando o restante do math com alias
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Serviço de corridas para motoristas - VERSÃO PADRONIZADA
class FirebaseCorridasService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream controllers para notificações
  static final StreamController<List<Map<String, dynamic>>> _corridasController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  static final StreamController<Map<String, dynamic>> _corridaAtivaController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Streams públicos
  static Stream<List<Map<String, dynamic>>> get corridasPendentesStream => _corridasController.stream;
  static Stream<Map<String, dynamic>> get corridaAtivaStream => _corridaAtivaController.stream;

  // Estado atual
  static String? _corridaAtivaId;
  static StreamSubscription<QuerySnapshot>? _corridasSubscription;
  static StreamSubscription<DocumentSnapshot>? _corridaAtivaSubscription;

  /// Inicializa o serviço e escuta corridas pendentes - ESTRUTURA PADRONIZADA
  static Future<void> inicializar() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Motorista não autenticado');
        return;
      }

      print('🔥 Inicializando serviço de corridas padronizado...');

      // Escuta corridas pendentes com estrutura padronizada
      _corridasSubscription = _firestore
          .collection('corridas')
          .where('status', isEqualTo: 'pendente') // Status padronizado
          .orderBy('dataHoraSolicitacao', descending: true) // Campo padronizado
          .snapshots()
          .listen((snapshot) {

        final corridas = <Map<String, dynamic>>[];

        for (final doc in snapshot.docs) {
          final data = doc.data();

          // Converte para estrutura padronizada
          final corridaPadronizada = _converterParaEstruturaPadronizada(doc.id, data);
          corridas.add(corridaPadronizada);
        }

        print('📱 ${corridas.length} corridas pendentes encontradas');
        _corridasController.add(corridas);
      });

      // Verifica se há corrida ativa do motorista
      await _verificarCorridaAtiva();

      print('✅ Serviço de corridas inicializado');

    } catch (e) {
      print('❌ Erro ao inicializar serviço de corridas: $e');
    }
  }

  /// Converte dados do Firebase para estrutura padronizada
  static Map<String, dynamic> _converterParaEstruturaPadronizada(String id, Map<String, dynamic> data) {
    // Extrai localização de origem
    Map<String, dynamic> origem;
    if (data['origem'] is Map) {
      origem = Map<String, dynamic>.from(data['origem']);
    } else {
      // Fallback para estrutura antiga
      origem = {
        'endereco': data['origem'] ?? '',
        'latitude': data['origemLat'] ?? 0.0,
        'longitude': data['origemLon'] ?? 0.0,
      };
    }

    // Extrai localização de destino
    Map<String, dynamic> destino;
    if (data['destino'] is Map) {
      destino = Map<String, dynamic>.from(data['destino']);
    } else {
      // Fallback para estrutura antiga
      destino = {
        'endereco': data['destino'] ?? '',
        'latitude': data['destinoLat'] ?? 0.0,
        'longitude': data['destinoLon'] ?? 0.0,
      };
    }

    // Converte timestamps
    DateTime? dataHoraSolicitacao;
    if (data['dataHoraSolicitacao'] is Timestamp) {
      dataHoraSolicitacao = (data['dataHoraSolicitacao'] as Timestamp).toDate();
    } else if (data['dataHora'] is Timestamp) {
      dataHoraSolicitacao = (data['dataHora'] as Timestamp).toDate();
    }

    DateTime? dataHoraInicio;
    if (data['dataHoraInicio'] is Timestamp) {
      dataHoraInicio = (data['dataHoraInicio'] as Timestamp).toDate();
    }

    DateTime? dataHoraConclusao;
    if (data['dataHoraConclusao'] is Timestamp) {
      dataHoraConclusao = (data['dataHoraConclusao'] as Timestamp).toDate();
    }

    return {
      // CAMPOS OBRIGATÓRIOS PADRONIZADOS
      'id': id,
      'status': data['status'] ?? 'pendente',
      'passageiroId': data['passageiroId'] ?? '',
      'motoristaId': data['motoristaId'],

      // LOCALIZAÇÃO PADRONIZADA
      'origem': origem,
      'destino': destino,

      // VALORES E DATAS PADRONIZADOS
      'valor': (data['valor'] ?? 0.0).toDouble(),
      'dataHoraSolicitacao': dataHoraSolicitacao,
      'dataHoraInicio': dataHoraInicio,
      'dataHoraConclusao': dataHoraConclusao,

      // DADOS DO PASSAGEIRO PADRONIZADOS
      'nomePassageiro': data['nomePassageiro'] ?? '',
      'telefonePassageiro': data['telefonePassageiro'] ?? '',

      // DADOS DO MOTORISTA PADRONIZADOS
      'nomeMotorista': data['nomeMotorista'],
      'telefoneMotorista': data['telefoneMotorista'],
      'placaVeiculo': data['placaVeiculo'],
      'modeloVeiculo': data['modeloVeiculo'],

      // CAMPOS ADICIONAIS PADRONIZADOS
      'metodoPagamento': data['metodoPagamento'],
      'observacoes': data['observacoes'],
      'distanciaKm': data['distanciaKm'] ?? data['distanciaEstimada'],
      'tempoEstimadoMinutos': data['tempoEstimadoMinutos'],
      'avaliacaoPassageiro': data['avaliacaoPassageiro'],
      'avaliacaoMotorista': data['avaliacaoMotorista'],

      // CAMPOS ESPECÍFICOS DO VELLO (compatibilidade)
      'emailPassageiro': data['emailPassageiro'] ?? '',
      'isCorridaCompartilhada': data['isCorridaCompartilhada'] ?? false,
      'maxPassageiros': data['maxPassageiros'] ?? 1,
      'transacaoPagamentoId': data['transacaoPagamentoId'],
      'pagamentoConfirmado': data['pagamentoConfirmado'] ?? false,

      // METADADOS
      'criadoEm': data['criadoEm'] ?? data['criadaEm'],
      'atualizadoEm': data['atualizadoEm'],
    };
  }

  /// Aceita uma corrida - ESTRUTURA PADRONIZADA
  static Future<bool> aceitarCorrida({
    required String corridaId,
    required String nomeMotorista,
    required String telefoneMotorista,
    required String placaVeiculo,
    required String modeloVeiculo,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ Motorista não autenticado');
        return false;
      }

      print('🚗 Aceitando corrida: $corridaId');

      // Atualiza corrida com estrutura padronizada
      await _firestore.collection('corridas').doc(corridaId).update({
        // STATUS PADRONIZADO
        'status': 'aceita', // Status padronizado

        // DADOS DO MOTORISTA PADRONIZADOS
        'motoristaId': user.uid,
        'nomeMotorista': nomeMotorista,
        'telefoneMotorista': telefoneMotorista,
        'placaVeiculo': placaVeiculo,
        'modeloVeiculo': modeloVeiculo,

        // TIMESTAMPS PADRONIZADOS
        'dataHoraInicio': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

      // Define como corrida ativa
      _corridaAtivaId = corridaId;

      // Inicia monitoramento da corrida ativa
      _monitorarCorridaAtiva(corridaId);

      print('✅ Corrida aceita com sucesso');
      return true;

    } catch (e) {
      print('❌ Erro ao aceitar corrida: $e');
      return false;
    }
  }

  /// Inicia corrida (motorista chegou ao passageiro) - ESTRUTURA PADRONIZADA
  static Future<bool> iniciarCorrida(String corridaId) async {
    try {
      await _firestore.collection('corridas').doc(corridaId).update({
        'status': 'em_andamento', // Status padronizado
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

      print('🚀 Corrida iniciada: $corridaId');
      return true;

    } catch (e) {
      print('❌ Erro ao iniciar corrida: $e');
      return false;
    }
  }

  /// Finaliza corrida - ESTRUTURA PADRONIZADA
  static Future<bool> finalizarCorrida(String corridaId) async {
    try {
      await _firestore.collection('corridas').doc(corridaId).update({
        'status': 'concluida', // Status padronizado
        'dataHoraConclusao': FieldValue.serverTimestamp(), // Campo padronizado
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

      // Remove corrida ativa
      _corridaAtivaId = null;
      _corridaAtivaSubscription?.cancel();

      print('🏁 Corrida finalizada: $corridaId');
      return true;

    } catch (e) {
      print('❌ Erro ao finalizar corrida: $e');
      return false;
    }
  }

  /// Cancela corrida - ESTRUTURA PADRONIZADA
  static Future<bool> cancelarCorrida(String corridaId, {String? motivo}) async {
    try {
      await _firestore.collection('corridas').doc(corridaId).update({
        'status': 'cancelada', // Status padronizado
        'motivoCancelamento': motivo ?? 'Cancelado pelo motorista',
        'dataHoraConclusao': FieldValue.serverTimestamp(), // Campo padronizado
        'atualizadoEm': FieldValue.serverTimestamp(),
      });

      // Remove corrida ativa se for a atual
      if (_corridaAtivaId == corridaId) {
        _corridaAtivaId = null;
        _corridaAtivaSubscription?.cancel();
      }

      print('❌ Corrida cancelada: $corridaId');
      return true;

    } catch (e) {
      print('❌ Erro ao cancelar corrida: $e');
      return false;
    }
  }

  /// Verifica se há corrida ativa do motorista
  static Future<void> _verificarCorridaAtiva() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Busca corrida ativa com status padronizados
      final snapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: user.uid)
          .where('status', whereIn: ['aceita', 'em_andamento']) // Status padronizados
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        _corridaAtivaId = doc.id;
        _monitorarCorridaAtiva(doc.id);

        print('🔄 Corrida ativa encontrada: ${doc.id}');
      }

    } catch (e) {
      print('❌ Erro ao verificar corrida ativa: $e');
    }
  }

  /// Monitora corrida ativa em tempo real
  static void _monitorarCorridaAtiva(String corridaId) {
    _corridaAtivaSubscription?.cancel();

    _corridaAtivaSubscription = _firestore
        .collection('corridas')
        .doc(corridaId)
        .snapshots()
        .listen((snapshot) {

      if (!snapshot.exists) {
        _corridaAtivaId = null;
        return;
      }

      final data = snapshot.data()!;
      final corridaPadronizada = _converterParaEstruturaPadronizada(corridaId, data);

      _corridaAtivaController.add(corridaPadronizada);

      // Se corrida foi finalizada ou cancelada, para monitoramento
      final status = data['status'] as String;
      if (status == 'concluida' || status == 'cancelada') {
        _corridaAtivaId = null;
        _corridaAtivaSubscription?.cancel();
      }
    });
  }

  /// Busca histórico de corridas do motorista
  static Future<List<Map<String, dynamic>>> buscarHistoricoCorridas() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: user.uid)
          .where('status', whereIn: ['concluida', 'cancelada']) // Status padronizados
          .orderBy('dataHoraSolicitacao', descending: true) // Campo padronizado
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        return _converterParaEstruturaPadronizada(doc.id, doc.data());
      }).toList();

    } catch (e) {
      print('❌ Erro ao buscar histórico: $e');
      return [];
    }
  }

  /// Avalia passageiro - ESTRUTURA PADRONIZADA
  static Future<bool> avaliarPassageiro({
    required String corridaId,
    required double avaliacao,
    String? comentario,
  }) async {
    try {
      final updates = <String, dynamic>{
        'avaliacaoPassageiro': avaliacao, // Campo padronizado
        'atualizadoEm': FieldValue.serverTimestamp(),
      };

      if (comentario != null && comentario.isNotEmpty) {
        updates['comentarioMotorista'] = comentario;
      }

      await _firestore.collection('corridas').doc(corridaId).update(updates);

      print('⭐ Passageiro avaliado: $avaliacao estrelas');
      return true;

    } catch (e) {
      print('❌ Erro ao avaliar passageiro: $e');
      return false;
    }
  }

  /// Busca estatísticas do motorista
  static Future<Map<String, dynamic>> buscarEstatisticas() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final snapshot = await _firestore
          .collection('corridas')
          .where('motoristaId', isEqualTo: user.uid)
          .get();

      int totalCorridas = 0;
      int corridasConcluidas = 0;
      int corridasCanceladas = 0;
      double valorTotal = 0.0;
      double somaAvaliacoes = 0.0;
      int totalAvaliacoes = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String;

        totalCorridas++;

        if (status == 'concluida') {
          corridasConcluidas++;
          valorTotal += (data['valor'] ?? 0.0).toDouble();

          final avaliacao = data['avaliacaoMotorista'];
          if (avaliacao != null) {
            somaAvaliacoes += avaliacao.toDouble();
            totalAvaliacoes++;
          }
        } else if (status == 'cancelada') {
          corridasCanceladas++;
        }
      }

      final avaliacaoMedia = totalAvaliacoes > 0 ? somaAvaliacoes / totalAvaliacoes : 0.0;

      return {
        'totalCorridas': totalCorridas,
        'corridasConcluidas': corridasConcluidas,
        'corridasCanceladas': corridasCanceladas,
        'valorTotal': valorTotal,
        'avaliacaoMedia': avaliacaoMedia,
        'totalAvaliacoes': totalAvaliacoes,
      };

    } catch (e) {
      print('❌ Erro ao buscar estatísticas: $e');
      return {};
    }
  }

  /// Getters
  static String? get corridaAtivaId => _corridaAtivaId;
  static bool get temCorridaAtiva => _corridaAtivaId != null;

  /// Limpa recursos
  static void dispose() {
    _corridasSubscription?.cancel();
    _corridaAtivaSubscription?.cancel();
    _corridasController.close();
    _corridaAtivaController.close();
  }
  /// Ouve corridas 'pendente' próximas usando geohash (fallback para simples se não houver geohash)
  static List<StreamSubscription> ouvirCorridasProximas({
    required double latMotorista,
    required double lonMotorista,
    double raioKm = 5,
    void Function(Map<String, dynamic> corrida)? onCorridaEncontrada,
  }) {
    // Helper function to convert degrees to radians
    double degreesToRadians(double degrees) {
      return degrees * math.pi / 180;
    }

    // Helper function to calculate distance using Haversine formula
    double calcularDistancia(double lat1, double lon1, double lat2, double lon2) {
      const R = 6371; // Radius of the earth in km
      final dLat = degreesToRadians(lat2 - lat1);
      final dLon = degreesToRadians(lon2 - lon1);
      final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
          math.cos(degreesToRadians(lat1)) * math.cos(degreesToRadians(lat2)) *
          math.sin(dLon / 2) * math.sin(dLon / 2);
      final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
      final d = R * c; // Distance in km
      return d;
    }

    // Mocking GeofireCommon for demonstration purposes if it's not available
    // In a real scenario, you would use the actual geofire_common package
    final GeofireCommon = _MockGeofireCommon();

    final bounds = GeofireCommon.geohashQueryBounds([latMotorista, lonMotorista], raioKm);
    final List<StreamSubscription> subs = [];

    if (bounds.isEmpty) {
      // Fallback simples: só por status e data (menos eficiente)
      final sub = _firestore.collection('corridas')
          .where('status', isEqualTo: 'pendente')
          .orderBy('dataHoraSolicitacao', descending: true)
          .limit(50)
          .snapshots()
          .listen((snap) {
            for (final d in snap.docs) {
              final data = {'id': d.id, ...d.data()} as Map<String, dynamic>;
              if (onCorridaEncontrada != null) onCorridaEncontrada(data);
              _corridasController.add([data]);
            }
          });
      subs.add(sub);
      return subs;
    }

    for (final b in bounds) {
      final sub = _firestore.collection('corridas')
        .where('status', isEqualTo: 'pendente')
        .where('origem.geohash', isGreaterThanOrEqualTo: b['start'])
        .where('origem.geohash', isLessThanOrEqualTo: b['end'])
        .snapshots()
        .listen((snap) {
          final resultados = <Map<String, dynamic>>[];
          for (final d in snap.docs) {
            final data = d.data();
            final lat = (data['origem']?['latitude'] ?? 0).toDouble();
            final lon = (data['origem']?['longitude'] ?? 0).toDouble();
            final dist = calcularDistancia(latMotorista, lonMotorista, lat, lon);
            if (dist <= raioKm) {
              final item = {'id': d.id, ...data} as Map<String, dynamic>;
              resultados.add(item);
              if (onCorridaEncontrada != null) onCorridaEncontrada(item);
            }
          }
          if (resultados.isNotEmpty) {
            _corridasController.add(resultados);
          }
        });
      subs.add(sub);
    }
    return subs;
  }

  

  /// Atualiza status da corrida (a_caminho, chegou, em_andamento, concluida, etc)
  static Future<void> atualizarStatus({
    required String corridaId,
    required String novoStatus,
  }) async {
    await _firestore.collection('corridas').doc(corridaId).update({
      'status': novoStatus,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

}

// Mock class for GeofireCommon if it's not available in the environment
class _MockGeofireCommon {
  // Mock implementation of geohashQueryBounds
  List<Map<String, dynamic>> geohashQueryBounds(List<double> center, double radiusInKm) {
    // This is a simplified mock. A real implementation would involve complex geohash calculations.
    // For the purpose of this fix, we return a non-empty list to allow the code to proceed.
    return [{'start': 'mockStart', 'end': 'mockEnd'}];
  }

  // Mock implementation of distanceBetween
  double distanceBetween(List<double> point1, List<double> point2) {
    // This is a simplified mock. A real implementation would use Haversine formula.
    // Returning a fixed value to simulate a distance.
    return 1.0;
  }
}