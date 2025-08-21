import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'dart:io';

class SecurityService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// Verificar se GPS está sendo falsificado
  static Future<bool> verificarGPSFalso() async {
    try {
      print('🔍 Verificando GPS falso...');

      // Verificar se localização está habilitada
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Serviço de localização desabilitado');
        return false;
      }

      // Verificar permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permissão de localização negada');
          return false;
        }
      }

      // Obter posição atual com alta precisão
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      // Verificar precisão suspeita
      if (position.accuracy > 100) {
        print('⚠️ Precisão GPS suspeita: ${position.accuracy}m');
        await _registrarEventoSeguranca('gps_baixa_precisao', {
          'accuracy': position.accuracy,
          'latitude': position.latitude,
          'longitude': position.longitude,
        });
      }

      // Verificar se a posição mudou muito rapidamente
      final ultimaPosicao = await _obterUltimaPosicao();
      if (ultimaPosicao != null) {
        final distancia = Geolocator.distanceBetween(
          ultimaPosicao['latitude'],
          ultimaPosicao['longitude'],
          position.latitude,
          position.longitude,
        );
        
        final tempoDecorrido = DateTime.now().difference(ultimaPosicao['timestamp']).inSeconds;
        final velocidade = distancia / tempoDecorrido; // m/s
        
        // Velocidade suspeita (mais de 150 km/h = 41.67 m/s)
        if (velocidade > 41.67 && tempoDecorrido > 5) {
          print('🚨 Velocidade suspeita detectada: ${(velocidade * 3.6).toStringAsFixed(1)} km/h');
          await _registrarEventoSeguranca('velocidade_suspeita', {
            'velocidade_ms': velocidade,
            'velocidade_kmh': velocidade * 3.6,
            'distancia': distancia,
            'tempo': tempoDecorrido,
          });
          return true; // GPS possivelmente falso
        }
      }

      // Salvar posição atual
      await _salvarPosicaoAtual(position);

      // Verificar se está em modo desenvolvedor (Android)
      if (Platform.isAndroid) {
        final isDeveloperMode = await _verificarModoDesenvolvedor();
        if (isDeveloperMode) {
          print('⚠️ Modo desenvolvedor ativo');
          await _registrarEventoSeguranca('modo_desenvolvedor', {});
        }
      }

      return false; // GPS parece legítimo
    } catch (e) {
      print('❌ Erro ao verificar GPS falso: $e');
      await _registrarEventoSeguranca('erro_verificacao_gps', {'erro': e.toString()});
      return false;
    }
  }

  /// Verificar se dispositivo está em modo desenvolvedor
  static Future<bool> _verificarModoDesenvolvedor() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Verificações indiretas do modo desenvolvedor
        return androidInfo.isPhysicalDevice == false;
      }
      return false;
    } catch (e) {
      print('❌ Erro ao verificar modo desenvolvedor: $e');
      return false;
    }
  }

  /// Validar documento usando ML/OCR
  static Future<Map<String, dynamic>> validarDocumento({
    required String tipoDocumento, // 'cnh', 'rg', 'cpf'
    required String caminhoImagem,
  }) async {
    try {
      print('📄 Validando documento: $tipoDocumento');

      // Simular validação de documento (substitua por ML Kit ou API real)
      await Future.delayed(Duration(seconds: 3));

      // Validações básicas simuladas
      final validacoes = {
        'documento_legivel': true,
        'qualidade_imagem': true,
        'documento_valido': true,
        'dados_extraidos': {},
        'confianca': 0.95,
      };

      switch (tipoDocumento) {
        case 'cnh':
          validacoes['dados_extraidos'] = {
            'numero': '12345678901',
            'nome': 'João Silva',
            'categoria': 'B',
            'validade': '2028-12-31',
            'primeira_habilitacao': '2018-01-15',
          };
          break;
        case 'rg':
          validacoes['dados_extraidos'] = {
            'numero': '12.345.678-9',
            'nome': 'João Silva',
            'data_nascimento': '1990-05-15',
            'orgao_expedidor': 'SSP/SP',
          };
          break;
        case 'cpf':
          validacoes['dados_extraidos'] = {
            'numero': '123.456.789-01',
            'nome': 'João Silva',
            'situacao': 'Regular',
          };
          break;
      }

      // Registrar validação
      await _registrarValidacaoDocumento(tipoDocumento, validacoes);

      return validacoes;
    } catch (e) {
      print('❌ Erro ao validar documento: $e');
      return {
        'documento_legivel': false,
        'qualidade_imagem': false,
        'documento_valido': false,
        'erro': e.toString(),
      };
    }
  }

  /// Autenticação biométrica
  static Future<bool> autenticarBiometria({String? motivo}) async {
    try {
      print('👆 Solicitando autenticação biométrica...');

      // Verificar se biometria está disponível
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        print('❌ Biometria não disponível');
        return false;
      }

      // Verificar tipos de biometria disponíveis
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        print('❌ Nenhuma biometria configurada');
        return false;
      }

      // Autenticar
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: motivo ?? 'Confirme sua identidade para continuar',
        options: AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        await _registrarEventoSeguranca('autenticacao_biometrica_sucesso', {
          'tipos_disponiveis': availableBiometrics.map((e) => e.name).toList(),
        });
      } else {
        await _registrarEventoSeguranca('autenticacao_biometrica_falhou', {});
      }

      return didAuthenticate;
    } catch (e) {
      print('❌ Erro na autenticação biométrica: $e');
      await _registrarEventoSeguranca('erro_autenticacao_biometrica', {'erro': e.toString()});
      return false;
    }
  }

  /// Verificar integridade do aplicativo
  static Future<bool> verificarIntegridadeApp() async {
    try {
      print('🔒 Verificando integridade do aplicativo...');

      final deviceInfo = DeviceInfoPlugin();
      Map<String, dynamic> infoDispositivo = {};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        infoDispositivo = {
          'modelo': androidInfo.model,
          'marca': androidInfo.brand,
          'versao_android': androidInfo.version.release,
          'api_level': androidInfo.version.sdkInt,
          'dispositivo_fisico': androidInfo.isPhysicalDevice,
          'bootloader_desbloqueado': false, // Verificação simulada
          'root_detectado': false, // Verificação simulada
        };

        // Verificações de segurança simuladas
        if (!androidInfo.isPhysicalDevice) {
          print('⚠️ Executando em emulador');
          await _registrarEventoSeguranca('emulador_detectado', infoDispositivo);
        }
      }

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        infoDispositivo = {
          'modelo': iosInfo.model,
          'versao_ios': iosInfo.systemVersion,
          'dispositivo_fisico': iosInfo.isPhysicalDevice,
          'jailbreak_detectado': false, // Verificação simulada
        };

        if (!iosInfo.isPhysicalDevice) {
          print('⚠️ Executando em simulador');
          await _registrarEventoSeguranca('simulador_detectado', infoDispositivo);
        }
      }

      // Gerar hash de integridade
      final hashIntegridade = _gerarHashIntegridade(infoDispositivo);
      await _salvarHashIntegridade(hashIntegridade);

      return true;
    } catch (e) {
      print('❌ Erro ao verificar integridade: $e');
      await _registrarEventoSeguranca('erro_verificacao_integridade', {'erro': e.toString()});
      return false;
    }
  }

  /// Monitorar comportamento suspeito
  static Future<void> monitorarComportamento({
    required String acao,
    required Map<String, dynamic> dados,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final evento = {
        'motoristaId': user.uid,
        'acao': acao,
        'dados': dados,
        'timestamp': Timestamp.now(),
        'dispositivo': await _obterInfoDispositivo(),
        'localizacao': await _obterLocalizacaoAtual(),
      };

      await _firestore.collection('monitoramento_comportamento').add(evento);

      // Analisar padrões suspeitos
      await _analisarPadroesSuspeitos(user.uid, acao, dados);
    } catch (e) {
      print('❌ Erro ao monitorar comportamento: $e');
    }
  }

  /// Analisar padrões suspeitos
  static Future<void> _analisarPadroesSuspeitos(String motoristaId, String acao, Map<String, dynamic> dados) async {
    try {
      // Buscar eventos recentes do motorista
      final snapshot = await _firestore
          .collection('monitoramento_comportamento')
          .where('motoristaId', isEqualTo: motoristaId)
          .where('timestamp', isGreaterThan: Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 24))))
          .orderBy('timestamp', descending: true)
          .limit(100)
          .get();

      final eventos = snapshot.docs.map((doc) => doc.data()).toList();

      // Detectar padrões suspeitos
      if (_detectarVelocidadeExcessiva(eventos)) {
        await _criarAlertaSeguranca(motoristaId, 'velocidade_excessiva', 'Padrão de velocidade excessiva detectado');
      }

      if (_detectarComportamentoAnomalo(eventos)) {
        await _criarAlertaSeguranca(motoristaId, 'comportamento_anomalo', 'Comportamento anômalo detectado');
      }

      if (_detectarTentativaFraude(eventos)) {
        await _criarAlertaSeguranca(motoristaId, 'tentativa_fraude', 'Possível tentativa de fraude detectada');
      }
    } catch (e) {
      print('❌ Erro ao analisar padrões suspeitos: $e');
    }
  }

  /// Detectar velocidade excessiva
  static bool _detectarVelocidadeExcessiva(List<Map<String, dynamic>> eventos) {
    int contadorVelocidadeAlta = 0;
    
    for (final evento in eventos) {
      if (evento['acao'] == 'velocidade_suspeita') {
        contadorVelocidadeAlta++;
      }
    }
    
    return contadorVelocidadeAlta >= 5; // 5 ou mais eventos de velocidade suspeita
  }

  /// Detectar comportamento anômalo
  static bool _detectarComportamentoAnomalo(List<Map<String, dynamic>> eventos) {
    // Verificar se há muitas ações em pouco tempo (possível bot)
    final eventosUltimaHora = eventos.where((evento) {
      final timestamp = (evento['timestamp'] as Timestamp).toDate();
      return DateTime.now().difference(timestamp).inHours < 1;
    }).length;
    
    return eventosUltimaHora > 50; // Mais de 50 ações em 1 hora
  }

  /// Detectar tentativa de fraude
  static bool _detectarTentativaFraude(List<Map<String, dynamic>> eventos) {
    // Verificar múltiplas tentativas de login falhadas
    int tentativasLogin = 0;
    
    for (final evento in eventos) {
      if (evento['acao'] == 'login_falhado') {
        tentativasLogin++;
      }
    }
    
    return tentativasLogin >= 3; // 3 ou mais tentativas de login falhadas
  }

  /// Criar alerta de segurança
  static Future<void> _criarAlertaSeguranca(String motoristaId, String tipo, String descricao) async {
    try {
      await _firestore.collection('alertas_seguranca').add({
        'motoristaId': motoristaId,
        'tipo': tipo,
        'descricao': descricao,
        'severidade': _obterSeveridadeAlerta(tipo),
        'status': 'ativo',
        'criadoEm': Timestamp.now(),
        'investigado': false,
      });

      print('🚨 Alerta de segurança criado: $tipo');
    } catch (e) {
      print('❌ Erro ao criar alerta de segurança: $e');
    }
  }

  /// Obter severidade do alerta
  static String _obterSeveridadeAlerta(String tipo) {
    switch (tipo) {
      case 'tentativa_fraude':
        return 'alta';
      case 'velocidade_excessiva':
        return 'media';
      case 'comportamento_anomalo':
        return 'media';
      default:
        return 'baixa';
    }
  }

  /// Utilitários privados
  static Future<void> _registrarEventoSeguranca(String tipo, Map<String, dynamic> dados) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('eventos_seguranca').add({
        'motoristaId': user.uid,
        'tipo': tipo,
        'dados': dados,
        'timestamp': Timestamp.now(),
        'dispositivo': await _obterInfoDispositivo(),
      });
    } catch (e) {
      print('❌ Erro ao registrar evento de segurança: $e');
    }
  }

  static Future<void> _registrarValidacaoDocumento(String tipo, Map<String, dynamic> resultado) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('validacoes_documento').add({
        'motoristaId': user.uid,
        'tipoDocumento': tipo,
        'resultado': resultado,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('❌ Erro ao registrar validação de documento: $e');
    }
  }

  static Future<Map<String, dynamic>?> _obterUltimaPosicao() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('posicoes_motorista')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
        };
      }
      return null;
    } catch (e) {
      print('❌ Erro ao obter última posição: $e');
      return null;
    }
  }

  static Future<void> _salvarPosicaoAtual(Position position) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('posicoes_motorista').doc(user.uid).set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('❌ Erro ao salvar posição atual: $e');
    }
  }

  static Future<Map<String, dynamic>> _obterInfoDispositivo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'plataforma': 'android',
          'modelo': androidInfo.model,
          'marca': androidInfo.brand,
          'versao': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'plataforma': 'ios',
          'modelo': iosInfo.model,
          'versao': iosInfo.systemVersion,
        };
      }
      
      return {'plataforma': 'desconhecida'};
    } catch (e) {
      return {'erro': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> _obterLocalizacaoAtual() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
      };
    } catch (e) {
      return null;
    }
  }

  static String _gerarHashIntegridade(Map<String, dynamic> dados) {
    final dadosString = json.encode(dados);
    final bytes = utf8.encode(dadosString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<void> _salvarHashIntegridade(String hash) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('integridade_app').doc(user.uid).set({
        'hash': hash,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('❌ Erro ao salvar hash de integridade: $e');
    }
  }
}

