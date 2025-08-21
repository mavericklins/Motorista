import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Importa as telas originais do seu app
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'constants/app_colors.dart';
import 'services/presence_service.dart'; // LINHA ADICIONADA

void main() async {
  // Garante que o Flutter está inicializado antes de executar código assíncrono
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inicializa o Firebase
    await Firebase.initializeApp();
    print("🔥 Firebase inicializado com sucesso!");
  } catch (e) {
    print("❌ Erro ao inicializar Firebase: $e");
  }
  
  // Executa o app
  runApp(VelloMotoristaApp());
}

// MODIFICADO: Adicionado WidgetsBindingObserver
class VelloMotoristaApp extends StatefulWidget {
  @override
  _VelloMotoristaAppState createState() => _VelloMotoristaAppState();
}

class _VelloMotoristaAppState extends State<VelloMotoristaApp> with WidgetsBindingObserver {
  final PresenceService _presenceService = PresenceService(); // LINHA ADICIONADA

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // LINHA ADICIONADA
    
    // ADICIONADO: Inicializar presença quando o app iniciar
    _initializePresence();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // LINHA ADICIONADA
    super.dispose();
  }

  // ADICIONADO: Detectar mudanças no ciclo de vida do app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('📱 App state changed to: $state');
    // O PresenceService já trata isso automaticamente
  }

  // ADICIONADO: Função para inicializar presença
  void _initializePresence() async {
    // Aguardar um pouco para garantir que o Firebase Auth está pronto
    await Future.delayed(Duration(seconds: 2));
    await _presenceService.initializePresence();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provê o serviço de autenticação para toda a árvore de widgets
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Vello Motorista',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Usa as cores originais do seu app
          primarySwatch: MaterialColor(
            0xFFFF6B35, // Cor laranja principal do Vello
            <int, Color>{
              50: Color(0xFFFFF3F0),
              100: Color(0xFFFFE4DC),
              200: Color(0xFFFFCBB8),
              300: Color(0xFFFFB094),
              400: Color(0xFFFF8B5A),
              500: Color(0xFFFF6B35), // Cor principal
              600: Color(0xFFE55A2B),
              700: Color(0xFFCC4A21),
              800: Color(0xFFB23A17),
              900: Color(0xFF992A0D),
            },
          ),
          primaryColor: VelloColors.laranja,
          scaffoldBackgroundColor: VelloColors.creme,
          appBarTheme: AppBarTheme(
            backgroundColor: VelloColors.azul,
            foregroundColor: VelloColors.branco,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: VelloColors.laranja,
              foregroundColor: VelloColors.branco,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: VelloColors.branco,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: VelloColors.cinzaClaro),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: VelloColors.cinzaClaro),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: VelloColors.laranja, width: 2),
            ),
          ),
          textTheme: TextTheme(
            headlineLarge: TextStyle(
              color: VelloColors.azulEscuro,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: TextStyle(
              color: VelloColors.azulEscuro,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(
              color: VelloColors.cinzaEscuro,
            ),
            bodyMedium: TextStyle(
              color: VelloColors.cinza,
            ),
          ),
        ),
        // Usa sua splash screen original
        home: LoginScreen(),
      ),
    );
  }
}

