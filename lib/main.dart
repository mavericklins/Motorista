import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/sound_service.dart';
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
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        Provider<SoundService>(create: (_) => SoundService()),
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