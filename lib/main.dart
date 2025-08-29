import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/sound_service.dart';
import 'services/coaching_inteligente_service.dart';
import 'services/metas_inteligentes_service.dart';
import 'services/gamification_service.dart';
import 'services/demand_prediction_service.dart';
import 'services/scheduled_rides_service.dart'; // ADICIONADO: Import do service ausente
import 'constants/app_colors.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Erro ao inicializar Firebase: $e');
  }

  runApp(const VelloMotoristaApp());
}

class VelloMotoristaApp extends StatelessWidget {
  const VelloMotoristaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<LocationService>(create: (_) => LocationService()),
        ChangeNotifierProvider<NotificationService>(create: (_) => NotificationService()),
        ChangeNotifierProvider<SoundService>(create: (_) => SoundService()),
        ChangeNotifierProvider<CoachingInteligenteService>(create: (_) => CoachingInteligenteService()),
        ChangeNotifierProvider<MetasInteligentesService>(create: (_) => MetasInteligentesService()),
        ChangeNotifierProvider<GamificationService>(create: (_) => GamificationService()),
        ChangeNotifierProvider<DemandPredictionService>(create: (_) => DemandPredictionService()),
        ChangeNotifierProvider<ScheduledRidesService>(create: (_) => ScheduledRidesService()), // ADICIONADO: Provider ausente
      ],
      child: MaterialApp(
        title: 'Vello Motorista',
        debugShowCheckedModeBanner: false,
        theme: VelloTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}