import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// +++ ADICIONE ESTA LINHA +++
import 'firebase_options.dart';

// Importa as telas e serviços originais do seu app
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'constants/app_colors.dart';
import 'services/presence_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Inicializa Firebase com as opções geradas pelo FlutterFire
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // ignore: avoid_print
    print("🔥 Firebase inicializado com sucesso!");
  } catch (e) {
    // ignore: avoid_print
    print("❌ Erro ao inicializar Firebase: $e");
  }

  runApp(const VelloMotoristaApp());
}

// Mantive seu Stateful + observer
class VelloMotoristaApp extends StatefulWidget {
  const VelloMotoristaApp({super.key});

  @override
  State<VelloMotoristaApp> createState() => _VelloMotoristaAppState();
}

class _VelloMotoristaAppState extends State<VelloMotoristaApp>
    with WidgetsBindingObserver {
  final PresenceService _presenceService = PresenceService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePresence();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // ignore: avoid_print
    print('📱 App state changed to: $state');
    // PresenceService já trata transições
  }

  Future<void> _initializePresence() async {
    // Dá um pequeno delay pra garantir Auth pronto (se necessário)
    await Future.delayed(const Duration(seconds: 2));
    await _presenceService.initializePresence();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Vello Motorista',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: const MaterialColor(
            0xFFFF6B35,
            <int, Color>{
              50: Color(0xFFFFF3F0),
              100: Color(0xFFFFE4DC),
              200: Color(0xFFFFCBB8),
              300: Color(0xFFFFB094),
              400: Color(0xFFFF8B5A),
              500: Color(0xFFFF6B35),
              600: Color(0xFFE55A2B),
              700: Color(0xFFCC4A21),
              800: Color(0xFFB23A17),
              900: Color(0xFF992A0D),
            },
          ),
          primaryColor: VelloColors.laranja,
          scaffoldBackgroundColor: VelloColors.creme,
          appBarTheme: const AppBarTheme(
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
              borderSide:
              BorderSide(color: VelloColors.laranja, width: 2),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              color: VelloColors.azulEscuro,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: TextStyle(
              color: VelloColors.azulEscuro,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(color: VelloColors.cinzaEscuro),
            bodyMedium: TextStyle(color: VelloColors.cinza),
          ),
        ),
        // mantém sua tela inicial atual
        home: const LoginScreen(),
        // ou se sua splash gerencia auth: home: const SplashScreen(),
      ),
    );
  }
}
