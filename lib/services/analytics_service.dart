import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

class AnalyticsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  static final FirebasePerformance _performance = FirebasePerformance.instance;

  /// Inicializar serviço de analytics
  static Future<void> inicializar() async {
    try {
      print('📊 Inicializando serviço de analytics...');

      // Configurar Crashlytics
      await _configurarCrashlytics();

      // Configurar Analytics
      await _configurarAnalytics();

      // Configurar Performance Monitoring
      await _configurarPerformance();

      // Registrar informações do dispositivo
      await _registrarInfoDispositivo();

      // Iniciar monitoramento de sessão
      await _iniciarSessao();

      print('✅ Serviço de analytics inicializado');
    } catch (e) {
      print('❌ Erro ao inicializar analytics: $e');
      await registrarErro('analytics_init_error', e);
    }
  }

  /// Configurar Crashlytics
  static Future<void> _configurarCrashlytics() async {
    // Habilitar coleta de crash reports
    await _crashlytics.setCrashlyticsCollectionEnabled(true);

    // Configurar usuário
    final user = _auth.currentUser;
    if (user != null) {
      await _crashlytics.setUserIdentifier(user.uid);
    }

    // Configurar handler de erros Flutter
    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
    };

    // Configurar handler de erros assíncronos
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Configurar Analytics
  static Future<void> _configurarAnalytics() async {
    // Habilitar coleta de dados
    await _analytics.setAnalyticsCollectionEnabled(true);

    // Configurar propriedades de usuário
    final user = _auth.currentUser;
    if (user != null) {
      await _analytics.setUserId(id: user.uid);
      await _analytics.setUserProperty(name: 'user_type', value: 'motorista');
    }

    // Configurar propriedades do app
    final packageInfo = await PackageInfo.fromPlatform();
    await _analytics.setUserProperty(name: 'app_version', value: packageInfo.version);
    await _analytics.setUserProperty(name: 'app_build', value: packageInfo.buildNumber);
  }

  /// Configurar Performance Monitoring
  static Future<void> _configurarPerformance() async {
    // Habilitar coleta de performance
    await _performance.setPerformanceCollectionEnabled(true);
  }

  /// Registrar informações do dispositivo
  static Future<void> _registrarInfoDispositivo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      Map<String, dynamic> infoDispositivo = {
        'app_version': packageInfo.version,
        'app_build': packageInfo.buildNumber,
        'platform': Platform.operatingSystem,
      };

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        infoDispositivo.addAll({
          'device_model': androidInfo.model,
          'device_brand': androidInfo.brand,
          'android_version': androidInfo.version.release,
          'api_level': androidInfo.version.sdkInt,
          'is_physical_device': androidInfo.isPhysicalDevice,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        infoDispositivo.addAll({
          'device_model': iosInfo.model,
          'ios_version': iosInfo.systemVersion,
          'is_physical_device': iosInfo.isPhysicalDevice,
        });
      }

      // Salvar no Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('analytics_dispositivos').doc(user.uid).set({
          ...infoDispositivo,
          'ultima_atualizacao': Timestamp.now(),
        }, SetOptions(merge: true));
      }

      // Configurar propriedades no Analytics
      for (final entry in infoDispositivo.entries) {
        if (entry.value is String) {
          await _analytics.setUserProperty(name: entry.key, value: entry.value);
        }
      }
    } catch (e) {
      print('❌ Erro ao registrar info do dispositivo: $e');
    }
  }

  /// Iniciar sessão
  static Future<void> _iniciarSessao() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final posicao = await _obterPosicaoAtual();

      await _firestore.collection('analytics_sessoes').add({
        'motoristaId': user.uid,
        'inicio_sessao': Timestamp.now(),
        'posicao_inicial': posicao != null ? {
          'latitude': posicao.latitude,
          'longitude': posicao.longitude,
        } : null,
        'ativa': true,
      });

      // Registrar evento no Analytics
      await _analytics.logEvent(
        name: 'session_start',
        parameters: {
          'user_id': user.uid,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    } catch (e) {
      print('❌ Erro ao iniciar sessão: $e');
    }
  }

  /// Finalizar sessão
  static Future<void> finalizarSessao() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Buscar sessão ativa
      final sessaoQuery = await _firestore
          .collection('analytics_sessoes')
          .where('motoristaId', isEqualTo: user.uid)
          .where('ativa', isEqualTo: true)
          .orderBy('inicio_sessao', descending: true)
          .limit(1)
          .get();

      if (sessaoQuery.docs.isNotEmpty) {
        final sessaoDoc = sessaoQuery.docs.first;
        final inicioSessao = (sessaoDoc.data()['inicio_sessao'] as Timestamp).toDate();
        final duracaoMinutos = DateTime.now().difference(inicioSessao).inMinutes;

        final posicao = await _obterPosicaoAtual();

        await sessaoDoc.reference.update({
          'fim_sessao': Timestamp.now(),
          'duracao_minutos': duracaoMinutos,
          'posicao_final': posicao != null ? {
            'latitude': posicao.latitude,
            'longitude': posicao.longitude,
          } : null,
          'ativa': false,
        });

        // Registrar evento no Analytics
        await _analytics.logEvent(
          name: 'session_end',
          parameters: {
            'user_id': user.uid,
            'duration_minutes': duracaoMinutos,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          },
        );
      }
    } catch (e) {
      print('❌ Erro ao finalizar sessão: $e');
    }
  }

  /// Registrar evento de corrida
  static Future<void> registrarEventoCorrida({
    required String evento,
    required String corridaId,
    Map<String, dynamic>? parametrosAdicionais,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final parametros = {
        'user_id': user.uid,
        'ride_id': corridaId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?parametrosAdicionais,
      };

      // Registrar no Analytics
      await _analytics.logEvent(name: evento, parameters: Map<String, Object>.from(parametros));

      // Salvar no Firestore para análise detalhada
      await _firestore.collection('analytics_eventos').add({
        'motoristaId': user.uid,
        'evento': evento,
        'corridaId': corridaId,
        'parametros': parametros,
        'timestamp': Timestamp.now(),
      });

      print('📊 Evento registrado: $evento');
    } catch (e) {
      print('❌ Erro ao registrar evento de corrida: $e');
    }
  }

  /// Registrar evento personalizado
  static Future<void> registrarEvento({
    required String nomeEvento,
    Map<String, dynamic>? parametros,
  }) async {
    try {
      final user = _auth.currentUser;

      final parametrosCompletos = {
        'user_id': user?.uid,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?parametros,
      };

      // Registrar no Analytics
      await _analytics.logEvent(name: nomeEvento, parameters: Map<String, Object>.from(parametrosCompletos));

      // Salvar no Firestore
      await _firestore.collection('analytics_eventos').add({
        'motoristaId': user?.uid,
        'evento': nomeEvento,
        'parametros': parametrosCompletos,
        'timestamp': Timestamp.now(),
      });

      print('📊 Evento personalizado registrado: $nomeEvento');
    } catch (e) {
      print('❌ Erro ao registrar evento personalizado: $e');
    }
  }

  /// Registrar erro
  static Future<void> registrarErro(String erro, dynamic exception, [StackTrace? stackTrace]) async {
    try {
      // Registrar no Crashlytics
      await _crashlytics.recordError(exception, stackTrace, fatal: false);

      // Registrar no Analytics
      await _analytics.logEvent(
        name: 'app_error',
        parameters: {
          'error_type': erro,
          'error_message': exception.toString(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Salvar no Firestore
      final user = _auth.currentUser;
      await _firestore.collection('analytics_erros').add({
        'motoristaId': user?.uid,
        'tipo_erro': erro,
        'mensagem': exception.toString(),
        'stack_trace': stackTrace?.toString(),
        'timestamp': Timestamp.now(),
      });

      print('🚨 Erro registrado: $erro');
    } catch (e) {
      print('❌ Erro ao registrar erro: $e');
    }
  }

  /// Monitorar performance de operação
  static Future<T> monitorarPerformance<T>(
    String nomeOperacao,
    Future<T> Function() operacao,
  ) async {
    final trace = _performance.newTrace(nomeOperacao);
    await trace.start();

    try {
      final resultado = await operacao();
      trace.setMetric('success', 1);
      return resultado;
    } catch (e) {
      trace.setMetric('error', 1);
      await registrarErro('performance_error_$nomeOperacao', e);
      rethrow;
    } finally {
      await trace.stop();
    }
  }

  /// Registrar métricas de uso
  static Future<void> registrarMetricasUso({
    required String categoria,
    required String acao,
    String? valor,
    int? valorNumerico,
  }) async {
    try {
      final user = _auth.currentUser;

      // Registrar no Analytics
      await _analytics.logEvent(
        name: 'user_action',
        parameters: {
          'category': categoria,
          'action': acao,
          'value': valor ?? '',
          'numeric_value': valorNumerico ?? 0,
          'user_id': user?.uid ?? '',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Salvar métricas detalhadas
      await _firestore.collection('analytics_metricas').add({
        'motoristaId': user?.uid,
        'categoria': categoria,
        'acao': acao,
        'valor': valor,
        'valor_numerico': valorNumerico,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('❌ Erro ao registrar métricas de uso: $e');
    }
  }

  /// Obter relatório de analytics
  static Future<Map<String, dynamic>> obterRelatorioAnalytics({
    DateTime? dataInicio,
    DateTime? dataFim,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final inicio = dataInicio ?? DateTime.now().subtract(Duration(days: 30));
      final fim = dataFim ?? DateTime.now();

      // Buscar eventos
      final eventosQuery = _firestore
          .collection('analytics_eventos')
          .where('motoristaId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(fim));

      final eventosSnapshot = await eventosQuery.get();

      // Buscar sessões
      final sessoesQuery = _firestore
          .collection('analytics_sessoes')
          .where('motoristaId', isEqualTo: user.uid)
          .where('inicio_sessao', isGreaterThanOrEqualTo: Timestamp.fromDate(inicio))
          .where('inicio_sessao', isLessThanOrEqualTo: Timestamp.fromDate(fim));

      final sessoesSnapshot = await sessoesQuery.get();

      // Processar dados
      final eventos = eventosSnapshot.docs.map((doc) => doc.data()).toList();
      final sessoes = sessoesSnapshot.docs.map((doc) => doc.data()).toList();

      // Calcular estatísticas
      final totalEventos = eventos.length;
      final totalSessoes = sessoes.length;
      final duracaoMediaSessao = sessoes.isNotEmpty
          ? sessoes
              .where((s) => s['duracao_minutos'] != null)
              .map((s) => s['duracao_minutos'] as int)
              .reduce((a, b) => a + b) / sessoes.length
          : 0.0;

      // Eventos por tipo
      final eventosPorTipo = <String, int>{};
      for (final evento in eventos) {
        final tipo = evento['evento'] as String;
        eventosPorTipo[tipo] = (eventosPorTipo[tipo] ?? 0) + 1;
      }

      return {
        'periodo': {
          'inicio': inicio.toIso8601String(),
          'fim': fim.toIso8601String(),
        },
        'resumo': {
          'total_eventos': totalEventos,
          'total_sessoes': totalSessoes,
          'duracao_media_sessao_minutos': duracaoMediaSessao,
        },
        'eventos_por_tipo': eventosPorTipo,
        'eventos_detalhados': eventos,
        'sessoes': sessoes,
      };
    } catch (e) {
      print('❌ Erro ao obter relatório de analytics: $e');
      return {};
    }
  }

  /// Configurar propriedades de usuário
  static Future<void> configurarPropriedadesUsuario(Map<String, String> propriedades) async {
    try {
      for (final entry in propriedades.entries) {
        await _analytics.setUserProperty(name: entry.key, value: entry.value);
      }

      // Salvar no Firestore também
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('analytics_usuarios').doc(user.uid).set({
          ...propriedades,
          'ultima_atualizacao': Timestamp.now(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('❌ Erro ao configurar propriedades de usuário: $e');
    }
  }

  /// Registrar conversão
  static Future<void> registrarConversao({
    required String tipoConversao,
    required double valor,
    String? moeda = 'BRL',
  }) async {
    try {
      await _analytics.logEvent(
        name: 'conversion',
        parameters: {
          'conversion_type': tipoConversao,
          'value': valor,
          'currency': moeda ?? 'BRL',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // Salvar conversão detalhada
      final user = _auth.currentUser;
      await _firestore.collection('analytics_conversoes').add({
        'motoristaId': user?.uid,
        'tipo': tipoConversao,
        'valor': valor,
        'moeda': moeda,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('❌ Erro ao registrar conversão: $e');
    }
  }

  /// Métodos auxiliares privados
  static Future<Position?> _obterPosicaoAtual() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  /// Registrar eventos específicos do motorista
  static Future<void> registrarInicioTurno() async {
    await registrarEvento(nomeEvento: 'driver_shift_start');
  }

  static Future<void> registrarFimTurno() async {
    await registrarEvento(nomeEvento: 'driver_shift_end');
  }

  static Future<void> registrarCorridaAceita(String corridaId, double valor) async {
    await registrarEventoCorrida(
      evento: 'ride_accepted',
      corridaId: corridaId,
      parametrosAdicionais: {'ride_value': valor},
    );
  }

  static Future<void> registrarCorridaConcluida(String corridaId, double valor, int duracaoMinutos) async {
    await registrarEventoCorrida(
      evento: 'ride_completed',
      corridaId: corridaId,
      parametrosAdicionais: {
        'ride_value': valor,
        'duration_minutes': duracaoMinutos,
      },
    );

    // Registrar como conversão também
    await registrarConversao(tipoConversao: 'ride_completed', valor: valor);
  }

  static Future<void> registrarCorridaCancelada(String corridaId, String motivo) async {
    await registrarEventoCorrida(
      evento: 'ride_cancelled',
      corridaId: corridaId,
      parametrosAdicionais: {'cancellation_reason': motivo},
    );
  }

  static Future<void> registrarPagamentoRecebido(double valor, String metodo) async {
    await registrarEvento(
      nomeEvento: 'payment_received',
      parametros: {
        'amount': valor,
        'payment_method': metodo,
      },
    );

    // Registrar como conversão
    await registrarConversao(tipoConversao: 'payment_received', valor: valor);
  }
}